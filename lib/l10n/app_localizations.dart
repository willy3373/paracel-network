import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pick Pack'**
  String get appName;

  /// No description provided for @agencyParcelManagement.
  ///
  /// In en, this message translates to:
  /// **'Agency Parcel Management'**
  String get agencyParcelManagement;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get usernameOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logOutOfAccount.
  ///
  /// In en, this message translates to:
  /// **'Log out of your account'**
  String get logOutOfAccount;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @initializationError.
  ///
  /// In en, this message translates to:
  /// **'Initialization Error'**
  String get initializationError;

  /// No description provided for @signOutAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign Out & Try Again'**
  String get signOutAndTryAgain;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @buses.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get buses;

  /// No description provided for @checkSeats.
  ///
  /// In en, this message translates to:
  /// **'Check Seats'**
  String get checkSeats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @parcel.
  ///
  /// In en, this message translates to:
  /// **'Parcel'**
  String get parcel;

  /// No description provided for @myAgencies.
  ///
  /// In en, this message translates to:
  /// **'My Agencies'**
  String get myAgencies;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @totalParcels.
  ///
  /// In en, this message translates to:
  /// **'Total Parcels'**
  String get totalParcels;

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get inTransit;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @recentParcels.
  ///
  /// In en, this message translates to:
  /// **'Recent Parcels'**
  String get recentParcels;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @toDestination.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get toDestination;

  /// No description provided for @sendNewParcel.
  ///
  /// In en, this message translates to:
  /// **'Send New Parcel'**
  String get sendNewParcel;

  /// No description provided for @senderInformation.
  ///
  /// In en, this message translates to:
  /// **'Sender Information'**
  String get senderInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @receiverInformation.
  ///
  /// In en, this message translates to:
  /// **'Receiver Information'**
  String get receiverInformation;

  /// No description provided for @parcelDetails.
  ///
  /// In en, this message translates to:
  /// **'Parcel Details'**
  String get parcelDetails;

  /// No description provided for @destinationAgency.
  ///
  /// In en, this message translates to:
  /// **'Destination Agency'**
  String get destinationAgency;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (MRU)'**
  String get amount;

  /// No description provided for @labelDetails.
  ///
  /// In en, this message translates to:
  /// **'Label / Details'**
  String get labelDetails;

  /// No description provided for @trackingCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Tracking Code (Optional)'**
  String get trackingCodeOptional;

  /// No description provided for @leaveBlankToAutoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to auto-generate'**
  String get leaveBlankToAutoGenerate;

  /// No description provided for @payOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pay on Delivery'**
  String get payOnDelivery;

  /// No description provided for @receiverPaysForShipment.
  ///
  /// In en, this message translates to:
  /// **'Receiver pays for shipment amount upon arrival'**
  String get receiverPaysForShipment;

  /// No description provided for @createShipment.
  ///
  /// In en, this message translates to:
  /// **'Create Shipment'**
  String get createShipment;

  /// No description provided for @parcelCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Parcel created successfully!'**
  String get parcelCreatedSuccessfully;

  /// No description provided for @pleaseSelectDestinationAgency.
  ///
  /// In en, this message translates to:
  /// **'Please select a destination agency.'**
  String get pleaseSelectDestinationAgency;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @sendParcel.
  ///
  /// In en, this message translates to:
  /// **'Send Parcel'**
  String get sendParcel;

  /// No description provided for @registerNewShipment.
  ///
  /// In en, this message translates to:
  /// **'Register a new shipment'**
  String get registerNewShipment;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @bookTicket.
  ///
  /// In en, this message translates to:
  /// **'Book Ticket'**
  String get bookTicket;

  /// No description provided for @reserveBusSeat.
  ///
  /// In en, this message translates to:
  /// **'Reserve a bus seat'**
  String get reserveBusSeat;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @noParcelsToday.
  ///
  /// In en, this message translates to:
  /// **'No parcels today'**
  String get noParcelsToday;

  /// No description provided for @availableBuses.
  ///
  /// In en, this message translates to:
  /// **'Available Buses'**
  String get availableBuses;

  /// No description provided for @selectBusToBook.
  ///
  /// In en, this message translates to:
  /// **'Select a bus to book a seat'**
  String get selectBusToBook;

  /// No description provided for @noBusesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No buses available.\nAsk your manager to add buses.'**
  String get noBusesAvailable;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'DRIVER'**
  String get driver;

  /// No description provided for @fullyBooked.
  ///
  /// In en, this message translates to:
  /// **'FULLY BOOKED'**
  String get fullyBooked;

  /// No description provided for @selectSeat.
  ///
  /// In en, this message translates to:
  /// **'Select a Seat'**
  String get selectSeat;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @passengerDetails.
  ///
  /// In en, this message translates to:
  /// **'Passenger Details'**
  String get passengerDetails;

  /// No description provided for @passengerName.
  ///
  /// In en, this message translates to:
  /// **'Passenger Name'**
  String get passengerName;

  /// No description provided for @enterPassengerName.
  ///
  /// In en, this message translates to:
  /// **'Enter passenger name'**
  String get enterPassengerName;

  /// No description provided for @ticketPrice.
  ///
  /// In en, this message translates to:
  /// **'Ticket Price (MRU)'**
  String get ticketPrice;

  /// No description provided for @enterTicketPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter ticket price'**
  String get enterTicketPrice;

  /// No description provided for @mustBeValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid number'**
  String get mustBeValidNumber;

  /// No description provided for @pleaseSelectASeat.
  ///
  /// In en, this message translates to:
  /// **'Please select a seat'**
  String get pleaseSelectASeat;

  /// No description provided for @trackParcel.
  ///
  /// In en, this message translates to:
  /// **'Track a Parcel'**
  String get trackParcel;

  /// No description provided for @enterTrackingOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter tracking number or phone'**
  String get enterTrackingOrPhone;

  /// No description provided for @trackingCodeOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Tracking code or Phone...'**
  String get trackingCodeOrPhone;

  /// No description provided for @noParcelFound.
  ///
  /// In en, this message translates to:
  /// **'No parcel found matching \"{query}\"'**
  String noParcelFound(String query);

  /// No description provided for @noPermissionToTrack.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to track this parcel.'**
  String get noPermissionToTrack;

  /// No description provided for @errorLookingUpParcel.
  ///
  /// In en, this message translates to:
  /// **'Error looking up parcel. Please try again.'**
  String get errorLookingUpParcel;

  /// No description provided for @parcelSent.
  ///
  /// In en, this message translates to:
  /// **'Parcel Sent'**
  String get parcelSent;

  /// No description provided for @receivedAtDestination.
  ///
  /// In en, this message translates to:
  /// **'Received at Destination'**
  String get receivedAtDestination;

  /// No description provided for @deliveredToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delivered to Customer'**
  String get deliveredToCustomer;

  /// No description provided for @markAsReceived.
  ///
  /// In en, this message translates to:
  /// **'Mark as Received'**
  String get markAsReceived;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @parcelStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Parcel status updated successfully!'**
  String get parcelStatusUpdated;

  /// No description provided for @agencyStatistics.
  ///
  /// In en, this message translates to:
  /// **'Agency Statistics'**
  String get agencyStatistics;

  /// No description provided for @totalMoneyCollected.
  ///
  /// In en, this message translates to:
  /// **'Total Money Collected'**
  String get totalMoneyCollected;

  /// No description provided for @sentParcels.
  ///
  /// In en, this message translates to:
  /// **'Sent Parcels'**
  String get sentParcels;

  /// No description provided for @receivedParcels.
  ///
  /// In en, this message translates to:
  /// **'Received Parcels'**
  String get receivedParcels;

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading stats'**
  String get errorLoadingStats;

  /// No description provided for @busesTitle.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get busesTitle;

  /// No description provided for @manageBuses.
  ///
  /// In en, this message translates to:
  /// **'Manage departing buses for your agency'**
  String get manageBuses;

  /// No description provided for @addBus.
  ///
  /// In en, this message translates to:
  /// **'Add Bus'**
  String get addBus;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noBusesYet.
  ///
  /// In en, this message translates to:
  /// **'No buses added yet.\nTap \"Add Bus\" to get started.'**
  String get noBusesYet;

  /// No description provided for @newBus.
  ///
  /// In en, this message translates to:
  /// **'New Bus'**
  String get newBus;

  /// No description provided for @busName.
  ///
  /// In en, this message translates to:
  /// **'Bus Name'**
  String get busName;

  /// No description provided for @destinationAgencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination Agency'**
  String get destinationAgencyLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @departureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// No description provided for @numberOfSeats.
  ///
  /// In en, this message translates to:
  /// **'Number of Seats'**
  String get numberOfSeats;

  /// No description provided for @enterBusName.
  ///
  /// In en, this message translates to:
  /// **'Enter bus name'**
  String get enterBusName;

  /// No description provided for @enterSeatCount.
  ///
  /// In en, this message translates to:
  /// **'Enter seat count'**
  String get enterSeatCount;

  /// No description provided for @mustBeWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a whole number'**
  String get mustBeWholeNumber;

  /// No description provided for @mustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get mustBeGreaterThanZero;

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get selectDestination;

  /// No description provided for @pleaseSelectDepartureDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a departure date.'**
  String get pleaseSelectDepartureDate;

  /// No description provided for @pleaseSelectDepartureTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a departure time.'**
  String get pleaseSelectDepartureTime;

  /// No description provided for @busAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bus added successfully!'**
  String get busAddedSuccessfully;

  /// No description provided for @errorSavingBus.
  ///
  /// In en, this message translates to:
  /// **'Error saving bus: {error}'**
  String errorSavingBus(String error);

  /// No description provided for @saveBus.
  ///
  /// In en, this message translates to:
  /// **'Save Bus'**
  String get saveBus;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @toCity.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get toCity;

  /// No description provided for @seatsLabel.
  ///
  /// In en, this message translates to:
  /// **'seats'**
  String get seatsLabel;

  /// No description provided for @checkSeatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Seats'**
  String get checkSeatsTitle;

  /// No description provided for @browseSeats.
  ///
  /// In en, this message translates to:
  /// **'Browse buses and check seat availability'**
  String get browseSeats;

  /// No description provided for @showAllLineAgencies.
  ///
  /// In en, this message translates to:
  /// **'Show All Line Agencies'**
  String get showAllLineAgencies;

  /// No description provided for @fromCity.
  ///
  /// In en, this message translates to:
  /// **'FROM CITY'**
  String get fromCity;

  /// No description provided for @toCityLabel.
  ///
  /// In en, this message translates to:
  /// **'TO CITY'**
  String get toCityLabel;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @noRouteBusesFound.
  ///
  /// In en, this message translates to:
  /// **'No buses found for this route.'**
  String get noRouteBusesFound;

  /// No description provided for @selectCityToSeeResults.
  ///
  /// In en, this message translates to:
  /// **'Please select a city to see results.'**
  String get selectCityToSeeResults;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get free;

  /// No description provided for @bookedOf.
  ///
  /// In en, this message translates to:
  /// **'booked'**
  String get bookedOf;

  /// No description provided for @seatBooked.
  ///
  /// In en, this message translates to:
  /// **'Seat {num} – Booked'**
  String seatBooked(int num);

  /// No description provided for @seatAvailable.
  ///
  /// In en, this message translates to:
  /// **'Seat {num} – Available'**
  String seatAvailable(int num);

  /// No description provided for @receivedParcelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Received Parcels'**
  String get receivedParcelsTitle;

  /// No description provided for @allParcelsSentToAgency.
  ///
  /// In en, this message translates to:
  /// **'All parcels sent to your agency'**
  String get allParcelsSentToAgency;

  /// No description provided for @noAgencyAssigned.
  ///
  /// In en, this message translates to:
  /// **'No agency assigned.'**
  String get noAgencyAssigned;

  /// No description provided for @noParcelsToday2.
  ///
  /// In en, this message translates to:
  /// **'No parcels today'**
  String get noParcelsToday2;

  /// No description provided for @parcelsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Parcels sent to you today will appear here.'**
  String get parcelsWillAppearHere;

  /// No description provided for @todaysOverview.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Overview'**
  String get todaysOverview;

  /// No description provided for @ofReceived.
  ///
  /// In en, this message translates to:
  /// **'of {total} received'**
  String ofReceived(int total);

  /// No description provided for @markAsReceivedBtn.
  ///
  /// In en, this message translates to:
  /// **'Mark as Received'**
  String get markAsReceivedBtn;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @receiverLabel.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiverLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
