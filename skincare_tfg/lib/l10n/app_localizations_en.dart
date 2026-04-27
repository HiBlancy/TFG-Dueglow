// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DueGlow';

  @override
  String helloUser(String name) {
    return 'Hello $name!';
  }

  @override
  String get login => 'Login';

  @override
  String get createAcount => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get userEmailExample => 'user@example.com';

  @override
  String get enterEmailAddress => 'Enter your email';

  @override
  String get invalidAddress => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get enterPass => 'Enter your password';

  @override
  String get pass6Char => 'At least 6 characters';

  @override
  String get myProducts => 'My products';

  @override
  String get seeAll => 'VIEW ALL';

  @override
  String get routines => 'Routines';

  @override
  String get categories => 'Categories';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get days => 'days';

  @override
  String get allFine => 'All is fine!';

  @override
  String get noProdExpiring => 'No products are about to expire';

  @override
  String get searchProducts => 'Search products';

  @override
  String get searchNameBrand => 'Search by name or brand...';

  @override
  String get exmapleSearch => 'Ex: \"Yves Rocher\", \"moisturising\"';

  @override
  String get camera => 'Camera';

  @override
  String get aimBarcode => 'Aim at the barcode';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifText => 'Receive alerts and updates';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get information => 'Information';

  @override
  String get about => 'About';

  @override
  String get logout => 'Log out';

  @override
  String get retry => 'Retry';

  @override
  String get clear => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get allProducts => 'All products';

  @override
  String get noProductsRegistered => 'You have no saved products';

  @override
  String get noProductsInHave => 'You have no products in \"Have\"';

  @override
  String get noProductsInWishlist => 'You have no products in \"Wishlist\"';

  @override
  String get noFinishedProducts => 'You have no finished products';

  @override
  String get addFirstProductsHint =>
      'Add your first products by scanning barcodes or searching in the database';

  @override
  String get haveProductsHint => 'Products marked as \"Have\" will appear here';

  @override
  String get wishlistProductsHint =>
      'Add products to your wishlist from the detail screen';

  @override
  String get usedProductsHint =>
      'Products you finished this month appear in this list';

  @override
  String get usedProductsInfo =>
      'These are the products you finished this month. When the month ends, these products will be automatically removed and the data will be stored for the PAN project.';

  @override
  String productsCount(int count, String pluralSuffix) {
    return '$count product$pluralSuffix';
  }

  @override
  String get searchLoading => 'Searching...';

  @override
  String get searchErrorTitle => 'Search error';

  @override
  String get searchConnectionError => 'Search failed. Check your connection.';

  @override
  String get searchNoResults => 'No products found';

  @override
  String get searchTryAnotherTerm => 'Try another search term';

  @override
  String get searchBeautyProducts => 'Search beauty products';

  @override
  String get searchExamplesExtended =>
      'Ex: \"L\'Oréal\", \"moisturizer\", \"shampoo\"';

  @override
  String get noBrand => 'No brand';

  @override
  String get scanProductNotFound => 'Product not found';

  @override
  String scanNoBarcodeInfo(String barcode) {
    return 'No information was found for barcode:\n$barcode\n\nDo you want to create a new product manually?';
  }

  @override
  String get createProduct => 'Create product';

  @override
  String get newProductDefaultName => 'New product';

  @override
  String get deleteRoutineTitle => 'Delete routine';

  @override
  String deleteRoutineQuestion(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get routineDeleted => 'Routine deleted';

  @override
  String get routinesLoadError => 'Failed to load routines';

  @override
  String get routineDeleteError => 'Failed to delete routine';

  @override
  String get morning => 'Morning';

  @override
  String get night => 'Night';

  @override
  String get newRoutine => 'New routine';

  @override
  String get noMorningRoutines => 'No morning routines';

  @override
  String get noNightRoutines => 'No night routines';

  @override
  String createFirstRoutineHint(String period) {
    return 'Create your first $period routine\nand organize your skincare products';
  }

  @override
  String get createRoutine => 'Create routine';

  @override
  String get routineCreatedSuccess => '✓ Routine created successfully';

  @override
  String get routineCreateError => 'Failed to create routine';

  @override
  String get routineNameRequiredLabel => 'Routine name *';

  @override
  String get routineNameHint => 'Ex: Morning routine';

  @override
  String get requiredField => 'Required';

  @override
  String get routineType => 'Routine type';

  @override
  String get weekDays => 'Week days';

  @override
  String get none => 'None';

  @override
  String get all => 'All';

  @override
  String get addProduct => 'Add product';

  @override
  String get noMoreProductsToAdd => 'No more products\nto add';

  @override
  String get routineNameLabel => 'Name';

  @override
  String get morningRoutineLabel => 'Morning routine';

  @override
  String get nightRoutineLabel => 'Night routine';

  @override
  String get products => 'Products';

  @override
  String get noProductAdded => 'No product added';

  @override
  String get longPressReorder => 'Long press to reorder';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get addProductsToBuildRoutine =>
      'Add products from your stash\nto build your routine';

  @override
  String get routineUpdated => 'Routine updated';

  @override
  String get updateError => 'Update failed';

  @override
  String get productRemovedFromRoutine => 'Product removed from routine';

  @override
  String get productRemoveError => 'Failed to remove product';

  @override
  String get reorderProductsError => 'Failed to reorder products';

  @override
  String get productAddedToRoutine => 'Product added to routine';

  @override
  String get productAddError => 'Failed to add product';
}
