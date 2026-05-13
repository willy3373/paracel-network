// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Pick Pack';

  @override
  String get agencyParcelManagement => 'Gestion des Colis d\'Agence';

  @override
  String get usernameOrEmail => 'Nom d\'utilisateur ou Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get theme => 'Thème';

  @override
  String get appearance => 'Apparence';

  @override
  String get account => 'Compte';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get logOutOfAccount => 'Se déconnecter de votre compte';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get english => 'Anglais';

  @override
  String get arabic => 'Arabe';

  @override
  String get french => 'Français';

  @override
  String get welcomeBack => 'Bon retour,';

  @override
  String get initializationError => 'Erreur d\'initialisation';

  @override
  String get signOutAndTryAgain => 'Se déconnecter et réessayer';

  @override
  String get adminPanel => 'Panneau d\'administration';

  @override
  String get home => 'Accueil';

  @override
  String get track => 'Suivre';

  @override
  String get stats => 'Statistiques';

  @override
  String get buses => 'Bus';

  @override
  String get checkSeats => 'Vérifier les Sièges';

  @override
  String get settings => 'Paramètres';

  @override
  String get parcel => 'Colis';

  @override
  String get myAgencies => 'Mes Agences';

  @override
  String get users => 'Utilisateurs';

  @override
  String get fees => 'Frais';

  @override
  String get totalParcels => 'Total des Colis';

  @override
  String get inTransit => 'En Transit';

  @override
  String get delivered => 'Livré';

  @override
  String get pending => 'En attente';

  @override
  String get recentParcels => 'Colis Récents';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get toDestination => 'À:';

  @override
  String get sendNewParcel => 'Envoyer un Nouveau Colis';

  @override
  String get senderInformation => 'Informations de l\'Expéditeur';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get phoneNumber => 'Numéro de Téléphone';

  @override
  String get receiverInformation => 'Informations du Destinataire';

  @override
  String get parcelDetails => 'Détails du Colis';

  @override
  String get destinationAgency => 'Agence de Destination';

  @override
  String get amount => 'Montant (MRU)';

  @override
  String get labelDetails => 'Étiquette / Détails';

  @override
  String get trackingCodeOptional => 'Code de Suivi (Optionnel)';

  @override
  String get leaveBlankToAutoGenerate =>
      'Laissez vide pour générer automatiquement';

  @override
  String get payOnDelivery => 'Payer à la Livraison';

  @override
  String get receiverPaysForShipment =>
      'Le destinataire paie le montant de l\'expédition à l\'arrivée';

  @override
  String get createShipment => 'Créer l\'Expédition';

  @override
  String get parcelCreatedSuccessfully => 'Colis créé avec succès !';

  @override
  String get pleaseSelectDestinationAgency =>
      'Veuillez sélectionner une agence de destination.';

  @override
  String get requiredField => 'Requis';

  @override
  String get sendParcel => 'Envoyer un colis';

  @override
  String get registerNewShipment => 'Enregistrer un nouvel envoi';

  @override
  String get start => 'Démarrer';

  @override
  String get bookTicket => 'Réserver un billet';

  @override
  String get reserveBusSeat => 'Réserver un siège de bus';

  @override
  String get book => 'Réserver';

  @override
  String get noParcelsToday => 'Aucun colis aujourd\'hui';

  @override
  String get availableBuses => 'Bus disponibles';

  @override
  String get selectBusToBook => 'Sélectionnez un bus pour réserver un siège';

  @override
  String get noBusesAvailable =>
      'Aucun bus disponible.\nDemandez à votre responsable d\'ajouter des bus.';

  @override
  String get driver => 'CHAUFFEUR';

  @override
  String get fullyBooked => 'COMPLET';

  @override
  String get selectSeat => 'Sélectionnez un siège';

  @override
  String get available => 'Disponible';

  @override
  String get booked => 'Réservé';

  @override
  String get selected => 'Sélectionné';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get passengerDetails => 'Détails du passager';

  @override
  String get passengerName => 'Nom du passager';

  @override
  String get enterPassengerName => 'Entrez le nom du passager';

  @override
  String get ticketPrice => 'Prix du billet (MRU)';

  @override
  String get enterTicketPrice => 'Entrez le prix du billet';

  @override
  String get mustBeValidNumber => 'Doit être un nombre valide';

  @override
  String get pleaseSelectASeat => 'Veuillez sélectionner un siège';

  @override
  String get trackParcel => 'Suivre un colis';

  @override
  String get enterTrackingOrPhone =>
      'Entrez le numéro de suivi ou le téléphone';

  @override
  String get trackingCodeOrPhone => 'Code de suivi ou téléphone...';

  @override
  String noParcelFound(String query) {
    return 'Aucun colis trouvé pour \"$query\"';
  }

  @override
  String get noPermissionToTrack =>
      'Vous n\'avez pas la permission de suivre ce colis.';

  @override
  String get errorLookingUpParcel =>
      'Erreur lors de la recherche du colis. Veuillez réessayer.';

  @override
  String get parcelSent => 'Colis envoyé';

  @override
  String get receivedAtDestination => 'Reçu à destination';

  @override
  String get deliveredToCustomer => 'Livré au client';

  @override
  String get markAsReceived => 'Marquer comme reçu';

  @override
  String get received => 'Reçu';

  @override
  String get parcelStatusUpdated => 'Statut du colis mis à jour avec succès !';

  @override
  String get agencyStatistics => 'Statistiques de l\'agence';

  @override
  String get totalMoneyCollected => 'Total des fonds collectés';

  @override
  String get sentParcels => 'Colis envoyés';

  @override
  String get receivedParcels => 'Colis reçus';

  @override
  String get errorLoadingStats => 'Erreur lors du chargement des statistiques';

  @override
  String get busesTitle => 'Bus';

  @override
  String get manageBuses => 'Gérer les bus au départ de votre agence';

  @override
  String get addBus => 'Ajouter un bus';

  @override
  String get cancel => 'Annuler';

  @override
  String get noBusesYet =>
      'Aucun bus ajouté pour l\'instant.\nAppuyez sur \"Ajouter un bus\" pour commencer.';

  @override
  String get newBus => 'Nouveau bus';

  @override
  String get busName => 'Nom du bus';

  @override
  String get destinationAgencyLabel => 'Agence de destination';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get departureTime => 'Heure de départ';

  @override
  String get numberOfSeats => 'Nombre de sièges';

  @override
  String get enterBusName => 'Entrez le nom du bus';

  @override
  String get enterSeatCount => 'Entrez le nombre de sièges';

  @override
  String get mustBeWholeNumber => 'Doit être un nombre entier';

  @override
  String get mustBeGreaterThanZero => 'Doit être supérieur à 0';

  @override
  String get selectDestination => 'Sélectionner la destination';

  @override
  String get pleaseSelectDepartureDate =>
      'Veuillez sélectionner une date de départ.';

  @override
  String get pleaseSelectDepartureTime =>
      'Veuillez sélectionner une heure de départ.';

  @override
  String get busAddedSuccessfully => 'Bus ajouté avec succès !';

  @override
  String errorSavingBus(String error) {
    return 'Erreur lors de l\'enregistrement du bus : $error';
  }

  @override
  String get saveBus => 'Enregistrer le bus';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get active => 'ACTIF';

  @override
  String get toCity => 'Vers :';

  @override
  String get seatsLabel => 'sièges';

  @override
  String get checkSeatsTitle => 'Vérifier les sièges';

  @override
  String get browseSeats =>
      'Parcourir les bus et vérifier la disponibilité des sièges';

  @override
  String get showAllLineAgencies => 'Afficher toutes les agences de la ligne';

  @override
  String get fromCity => 'VILLE DE DÉPART';

  @override
  String get toCityLabel => 'VILLE D\'ARRIVÉE';

  @override
  String get selectCity => 'Sélectionner la ville';

  @override
  String get noRouteBusesFound => 'Aucun bus trouvé pour cet itinéraire.';

  @override
  String get selectCityToSeeResults =>
      'Veuillez sélectionner une ville pour voir les résultats.';

  @override
  String get free => 'libre';

  @override
  String get bookedOf => 'réservé';

  @override
  String seatBooked(int num) {
    return 'Siège $num – Réservé';
  }

  @override
  String seatAvailable(int num) {
    return 'Siège $num – Disponible';
  }

  @override
  String get receivedParcelsTitle => 'Colis reçus';

  @override
  String get allParcelsSentToAgency => 'Tous les colis envoyés à votre agence';

  @override
  String get noAgencyAssigned => 'Aucune agence assignée.';

  @override
  String get noParcelsToday2 => 'Aucun colis aujourd\'hui';

  @override
  String get parcelsWillAppearHere =>
      'Les colis qui vous sont envoyés aujourd\'hui apparaîtront ici.';

  @override
  String get todaysOverview => 'Aperçu du jour';

  @override
  String ofReceived(int total) {
    return 'de $total reçus';
  }

  @override
  String get markAsReceivedBtn => 'Marquer comme reçu';

  @override
  String get codeLabel => 'Code';

  @override
  String get fromLabel => 'De';

  @override
  String get receiverLabel => 'Destinataire';

  @override
  String get amountLabel => 'Montant';
}
