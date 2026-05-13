const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// Set the region closest to your users
setGlobalOptions({ region: "us-central1" });

exports.adminCreateUser = onCall(async (request) => {
  // 1. Verify caller is authenticated
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to create users."
    );
  }

  const callerUid = request.auth.uid;

  // 2. Verify caller is an admin by reading their Firestore document
  let callerDoc;
  try {
    callerDoc = await admin.firestore().collection("users").doc(callerUid).get();
  } catch (error) {
    console.error("Error reading caller document:", error);
    throw new HttpsError("internal", "Could not verify your account.");
  }

  if (!callerDoc.exists || callerDoc.data().role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only administrators can create new users."
    );
  }

  // 3. Extract and validate data
  const { email, password, name, role, agencyId, gangId } = request.data;

  if (!email || !password || !name || !role) {
    throw new HttpsError(
      "invalid-argument",
      "Missing required fields: email, password, name, role."
    );
  }

  const validRoles = ["owner", "agent", "helper"];
  if (!validRoles.includes(role)) {
    throw new HttpsError(
      "invalid-argument",
      `Invalid role. Must be one of: ${validRoles.join(", ")}.`
    );
  }

  try {
    // 4. Create the user in Firebase Auth using Admin SDK (admin stays logged in!)
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: name,
    });

    // 5. Set Custom Claims — embeds the role directly in the auth token
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: role });

    // 6. Create the user profile document in Firestore
    await admin.firestore().collection("users").doc(userRecord.uid).set({
      uid: userRecord.uid,
      email: email,
      name: name,
      role: role,
      agencyId: agencyId || null,
      gangId: gangId || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Admin ${callerUid} created new user ${userRecord.uid} with role: ${role}`);

    return {
      message: "User created successfully",
      uid: userRecord.uid,
    };
  } catch (error) {
    console.error("Error creating user:", error);

    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "This email address is already registered."
      );
    }

    throw new HttpsError("internal", error.message);
  }
});

/**
 * Triggered when a new parcel is created.
 * Notifies all agents and helpers at the destination agency.
 */
exports.onParcelCreated = onDocumentCreated("parcels/{parcelId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }

  const parcel = snapshot.data();
  const destAgencyId = parcel.destinationAgencyId;

  if (!destAgencyId) {
    console.log("Parcel has no destinationAgencyId");
    return;
  }

  try {
    // 1. Fetch all users associated with the destination agency
    const usersSnap = await admin.firestore()
      .collection("users")
      .where("agencyId", "==", destAgencyId)
      .get();

    const tokens = [];
    const notificationPromises = [];
    
    usersSnap.forEach((doc) => {
      const data = doc.data();
      const userId = doc.id;

      // 1a. Collect tokens for push notifications
      if (data.fcmToken && !data.isBlocked) {
        tokens.push(data.fcmToken);
      }

      // 1b. Save in-app notification to Firestore
      notificationPromises.push(
        admin.firestore().collection("notifications").add({
          userId: userId,
          title: "📦 New Parcel Arriving!",
          body: `From: ${parcel.originAgencyId}\nReceiver: ${parcel.receiverName}`,
          type: "new_parcel",
          data: {
            parcelId: event.params.parcelId,
          },
          createdAt: new Date().toISOString(),
          isRead: false,
        })
      );
    });

    // Run all Firestore saves in parallel
    await Promise.all(notificationPromises);

    if (tokens.length === 0) {
      console.log(`No active FCM tokens found for agency: ${destAgencyId}. In-app notifications saved.`);
      return;
    }

    // 2. Prepare the notification message
    const message = {
      notification: {
        title: "📦 New Parcel Arriving!",
        body: `From: ${parcel.originAgencyId}\nReceiver: ${parcel.receiverName}`,
      },
      data: {
        parcelId: event.params.parcelId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        type: "new_parcel",
      },
      tokens: tokens,
    };

    // 3. Send notifications
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`${response.successCount} notifications sent successfully to agency ${destAgencyId}`);
    
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
        }
      });
      console.log("Failed tokens:", failedTokens);
    }
  } catch (error) {
    console.error("Error in onParcelCreated trigger:", error);
  }
});
