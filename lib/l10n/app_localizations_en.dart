// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pick Pack';

  @override
  String get agencyParcelManagement => 'Agency Parcel Management';

  @override
  String get usernameOrEmail => 'Username or Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get theme => 'Theme';

  @override
  String get appearance => 'Appearance';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get logOutOfAccount => 'Log out of your account';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get french => 'French';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get initializationError => 'Initialization Error';

  @override
  String get signOutAndTryAgain => 'Sign Out & Try Again';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get home => 'Home';

  @override
  String get track => 'Track';

  @override
  String get stats => 'Stats';

  @override
  String get buses => 'Buses';

  @override
  String get checkSeats => 'Check Seats';

  @override
  String get settings => 'Settings';

  @override
  String get parcel => 'Parcel';

  @override
  String get myAgencies => 'My Agencies';

  @override
  String get users => 'Users';

  @override
  String get fees => 'Fees';

  @override
  String get totalParcels => 'Total Parcels';

  @override
  String get inTransit => 'In Transit';

  @override
  String get delivered => 'Delivered';

  @override
  String get pending => 'Pending';

  @override
  String get recentParcels => 'Recent Parcels';

  @override
  String get viewAll => 'View All';

  @override
  String get toDestination => 'To:';

  @override
  String get sendNewParcel => 'Send New Parcel';

  @override
  String get senderInformation => 'Sender Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get receiverInformation => 'Receiver Information';

  @override
  String get parcelDetails => 'Parcel Details';

  @override
  String get destinationAgency => 'Destination Agency';

  @override
  String get amount => 'Amount (MRU)';

  @override
  String get labelDetails => 'Label / Details';

  @override
  String get trackingCodeOptional => 'Tracking Code (Optional)';

  @override
  String get leaveBlankToAutoGenerate => 'Leave blank to auto-generate';

  @override
  String get payOnDelivery => 'Pay on Delivery';

  @override
  String get receiverPaysForShipment =>
      'Receiver pays for shipment amount upon arrival';

  @override
  String get createShipment => 'Create Shipment';

  @override
  String get parcelCreatedSuccessfully => 'Parcel created successfully!';

  @override
  String get pleaseSelectDestinationAgency =>
      'Please select a destination agency.';

  @override
  String get requiredField => 'Required';

  @override
  String get sendParcel => 'Send Parcel';

  @override
  String get registerNewShipment => 'Register a new shipment';

  @override
  String get start => 'Start';

  @override
  String get bookTicket => 'Book Ticket';

  @override
  String get reserveBusSeat => 'Reserve a bus seat';

  @override
  String get book => 'Book';

  @override
  String get noParcelsToday => 'No parcels today';

  @override
  String get availableBuses => 'Available Buses';

  @override
  String get selectBusToBook => 'Select a bus to book a seat';

  @override
  String get noBusesAvailable =>
      'No buses available.\nAsk your manager to add buses.';

  @override
  String get driver => 'DRIVER';

  @override
  String get fullyBooked => 'FULLY BOOKED';

  @override
  String get selectSeat => 'Select a Seat';

  @override
  String get available => 'Available';

  @override
  String get booked => 'Booked';

  @override
  String get selected => 'Selected';

  @override
  String get continueBtn => 'Continue';

  @override
  String get passengerDetails => 'Passenger Details';

  @override
  String get passengerName => 'Passenger Name';

  @override
  String get enterPassengerName => 'Enter passenger name';

  @override
  String get ticketPrice => 'Ticket Price (MRU)';

  @override
  String get enterTicketPrice => 'Enter ticket price';

  @override
  String get mustBeValidNumber => 'Must be a valid number';

  @override
  String get pleaseSelectASeat => 'Please select a seat';

  @override
  String get trackParcel => 'Track a Parcel';

  @override
  String get enterTrackingOrPhone => 'Enter tracking number or phone';

  @override
  String get trackingCodeOrPhone => 'Tracking code or Phone...';

  @override
  String noParcelFound(String query) {
    return 'No parcel found matching \"$query\"';
  }

  @override
  String get noPermissionToTrack =>
      'You do not have permission to track this parcel.';

  @override
  String get errorLookingUpParcel =>
      'Error looking up parcel. Please try again.';

  @override
  String get parcelSent => 'Parcel Sent';

  @override
  String get receivedAtDestination => 'Received at Destination';

  @override
  String get deliveredToCustomer => 'Delivered to Customer';

  @override
  String get markAsReceived => 'Mark as Received';

  @override
  String get received => 'Received';

  @override
  String get parcelStatusUpdated => 'Parcel status updated successfully!';

  @override
  String get agencyStatistics => 'Agency Statistics';

  @override
  String get totalMoneyCollected => 'Total Money Collected';

  @override
  String get sentParcels => 'Sent Parcels';

  @override
  String get receivedParcels => 'Received Parcels';

  @override
  String get errorLoadingStats => 'Error loading stats';

  @override
  String get busesTitle => 'Buses';

  @override
  String get manageBuses => 'Manage departing buses for your agency';

  @override
  String get addBus => 'Add Bus';

  @override
  String get cancel => 'Cancel';

  @override
  String get noBusesYet =>
      'No buses added yet.\nTap \"Add Bus\" to get started.';

  @override
  String get newBus => 'New Bus';

  @override
  String get busName => 'Bus Name';

  @override
  String get destinationAgencyLabel => 'Destination Agency';

  @override
  String get selectDate => 'Select Date';

  @override
  String get departureTime => 'Departure Time';

  @override
  String get numberOfSeats => 'Number of Seats';

  @override
  String get enterBusName => 'Enter bus name';

  @override
  String get enterSeatCount => 'Enter seat count';

  @override
  String get mustBeWholeNumber => 'Must be a whole number';

  @override
  String get mustBeGreaterThanZero => 'Must be greater than 0';

  @override
  String get selectDestination => 'Select destination';

  @override
  String get pleaseSelectDepartureDate => 'Please select a departure date.';

  @override
  String get pleaseSelectDepartureTime => 'Please select a departure time.';

  @override
  String get busAddedSuccessfully => 'Bus added successfully!';

  @override
  String errorSavingBus(String error) {
    return 'Error saving bus: $error';
  }

  @override
  String get saveBus => 'Save Bus';

  @override
  String get saving => 'Saving...';

  @override
  String get active => 'ACTIVE';

  @override
  String get toCity => 'To:';

  @override
  String get seatsLabel => 'seats';

  @override
  String get checkSeatsTitle => 'Check Seats';

  @override
  String get browseSeats => 'Browse buses and check seat availability';

  @override
  String get showAllLineAgencies => 'Show All Line Agencies';

  @override
  String get fromCity => 'FROM CITY';

  @override
  String get toCityLabel => 'TO CITY';

  @override
  String get selectCity => 'Select City';

  @override
  String get noRouteBusesFound => 'No buses found for this route.';

  @override
  String get selectCityToSeeResults => 'Please select a city to see results.';

  @override
  String get free => 'free';

  @override
  String get bookedOf => 'booked';

  @override
  String seatBooked(int num) {
    return 'Seat $num – Booked';
  }

  @override
  String seatAvailable(int num) {
    return 'Seat $num – Available';
  }

  @override
  String get receivedParcelsTitle => 'Received Parcels';

  @override
  String get allParcelsSentToAgency => 'All parcels sent to your agency';

  @override
  String get noAgencyAssigned => 'No agency assigned.';

  @override
  String get noParcelsToday2 => 'No parcels today';

  @override
  String get parcelsWillAppearHere =>
      'Parcels sent to you today will appear here.';

  @override
  String get todaysOverview => 'Today\'s Overview';

  @override
  String ofReceived(int total) {
    return 'of $total received';
  }

  @override
  String get markAsReceivedBtn => 'Mark as Received';

  @override
  String get codeLabel => 'Code';

  @override
  String get fromLabel => 'From';

  @override
  String get receiverLabel => 'Receiver';

  @override
  String get amountLabel => 'Amount';
}
