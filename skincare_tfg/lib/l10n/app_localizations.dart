import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'DueGlow'**
  String get appName;

  /// Saludo en la pantalla de inicio
  ///
  /// In es, this message translates to:
  /// **'¡Hola {name}!'**
  String helloUser(String name);

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @createAcount.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAcount;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @userEmailExample.
  ///
  /// In es, this message translates to:
  /// **'usuario@ejemplo.com'**
  String get userEmailExample;

  /// No description provided for @enterEmailAddress.
  ///
  /// In es, this message translates to:
  /// **'Ingrese su correo'**
  String get enterEmailAddress;

  /// No description provided for @invalidAddress.
  ///
  /// In es, this message translates to:
  /// **'Correo inválido'**
  String get invalidAddress;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @enterPass.
  ///
  /// In es, this message translates to:
  /// **'Ingrese su contraseña'**
  String get enterPass;

  /// No description provided for @pass6Char.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get pass6Char;

  /// No description provided for @myProducts.
  ///
  /// In es, this message translates to:
  /// **'Mis productos'**
  String get myProducts;

  /// No description provided for @seeAll.
  ///
  /// In es, this message translates to:
  /// **'VER TODOS'**
  String get seeAll;

  /// No description provided for @routines.
  ///
  /// In es, this message translates to:
  /// **'Rutinas'**
  String get routines;

  /// No description provided for @categories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categories;

  /// No description provided for @expiringSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximos a caducar'**
  String get expiringSoon;

  /// No description provided for @days.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get days;

  /// No description provided for @allFine.
  ///
  /// In es, this message translates to:
  /// **'¡Todo en orden!'**
  String get allFine;

  /// No description provided for @noProdExpiring.
  ///
  /// In es, this message translates to:
  /// **'No hay productos próximos a caducar'**
  String get noProdExpiring;

  /// No description provided for @searchProducts.
  ///
  /// In es, this message translates to:
  /// **'Buscar productos'**
  String get searchProducts;

  /// No description provided for @searchNameBrand.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o marca...'**
  String get searchNameBrand;

  /// No description provided for @exmapleSearch.
  ///
  /// In es, this message translates to:
  /// **'Ej: \"Yves Rocher\", \"hidratante\"'**
  String get exmapleSearch;

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camera;

  /// No description provided for @aimBarcode.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código de barras'**
  String get aimBarcode;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @notifText.
  ///
  /// In es, this message translates to:
  /// **'Recibir alertas y actualizaciones'**
  String get notifText;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Claro'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @information.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get information;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @clear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @versionLabel.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String versionLabel(String version);

  /// No description provided for @notificationsEnabled.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activadas'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones desactivadas'**
  String get notificationsDisabled;

  /// No description provided for @allProducts.
  ///
  /// In es, this message translates to:
  /// **'Todos los productos'**
  String get allProducts;

  /// No description provided for @noProductsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No tienes productos registrados'**
  String get noProductsRegistered;

  /// No description provided for @noProductsInHave.
  ///
  /// In es, this message translates to:
  /// **'No tienes productos en \"Tengo\"'**
  String get noProductsInHave;

  /// No description provided for @noProductsInWishlist.
  ///
  /// In es, this message translates to:
  /// **'No tienes productos en \"Deseados\"'**
  String get noProductsInWishlist;

  /// No description provided for @noFinishedProducts.
  ///
  /// In es, this message translates to:
  /// **'No has registrado productos terminados'**
  String get noFinishedProducts;

  /// No description provided for @addFirstProductsHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega tus primeros productos escaneando códigos de barras o buscando en la base de datos'**
  String get addFirstProductsHint;

  /// No description provided for @haveProductsHint.
  ///
  /// In es, this message translates to:
  /// **'Los productos que marques como \"Tengo\" aparecerán aquí'**
  String get haveProductsHint;

  /// No description provided for @wishlistProductsHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega productos a tu wishlist desde la pantalla de detalles'**
  String get wishlistProductsHint;

  /// No description provided for @usedProductsHint.
  ///
  /// In es, this message translates to:
  /// **'Los productos que has acabado este mes aparecen en esta lista'**
  String get usedProductsHint;

  /// No description provided for @usedProductsInfo.
  ///
  /// In es, this message translates to:
  /// **'Estos son los productos que has terminado este mes. Cuando termine el mes, estos productos se eliminarán automáticamente y se almacenarán los datos para el proyecto PAN.'**
  String get usedProductsInfo;

  /// No description provided for @productsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} producto{pluralSuffix}'**
  String productsCount(int count, String pluralSuffix);

  /// No description provided for @searchLoading.
  ///
  /// In es, this message translates to:
  /// **'Buscando...'**
  String get searchLoading;

  /// No description provided for @searchErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error al buscar'**
  String get searchErrorTitle;

  /// No description provided for @searchConnectionError.
  ///
  /// In es, this message translates to:
  /// **'Error al buscar. Revisa tu conexión.'**
  String get searchConnectionError;

  /// No description provided for @searchNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron productos'**
  String get searchNoResults;

  /// No description provided for @searchTryAnotherTerm.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro término de búsqueda'**
  String get searchTryAnotherTerm;

  /// No description provided for @searchBeautyProducts.
  ///
  /// In es, this message translates to:
  /// **'Busca productos de belleza'**
  String get searchBeautyProducts;

  /// No description provided for @searchExamplesExtended.
  ///
  /// In es, this message translates to:
  /// **'Ej: \"L\'Oréal\", \"hidratante\", \"champú\"'**
  String get searchExamplesExtended;

  /// No description provided for @noBrand.
  ///
  /// In es, this message translates to:
  /// **'Sin marca'**
  String get noBrand;

  /// No description provided for @scanProductNotFound.
  ///
  /// In es, this message translates to:
  /// **'Producto no encontrado'**
  String get scanProductNotFound;

  /// No description provided for @scanNoBarcodeInfo.
  ///
  /// In es, this message translates to:
  /// **'No se encontró información para el código de barras:\n{barcode}\n\n¿Quieres crear un nuevo producto manualmente?'**
  String scanNoBarcodeInfo(String barcode);

  /// No description provided for @createProduct.
  ///
  /// In es, this message translates to:
  /// **'Crear producto'**
  String get createProduct;

  /// No description provided for @newProductDefaultName.
  ///
  /// In es, this message translates to:
  /// **'Nuevo producto'**
  String get newProductDefaultName;

  /// No description provided for @deleteRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar rutina'**
  String get deleteRoutineTitle;

  /// No description provided for @deleteRoutineQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String deleteRoutineQuestion(String name);

  /// No description provided for @routineDeleted.
  ///
  /// In es, this message translates to:
  /// **'Rutina eliminada'**
  String get routineDeleted;

  /// No description provided for @routinesLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar rutinas'**
  String get routinesLoadError;

  /// No description provided for @routineDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar rutina'**
  String get routineDeleteError;

  /// No description provided for @morning.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get morning;

  /// No description provided for @night.
  ///
  /// In es, this message translates to:
  /// **'Noche'**
  String get night;

  /// No description provided for @newRoutine.
  ///
  /// In es, this message translates to:
  /// **'Nueva rutina'**
  String get newRoutine;

  /// No description provided for @noMorningRoutines.
  ///
  /// In es, this message translates to:
  /// **'Sin rutinas de mañana'**
  String get noMorningRoutines;

  /// No description provided for @noNightRoutines.
  ///
  /// In es, this message translates to:
  /// **'Sin rutinas de noche'**
  String get noNightRoutines;

  /// No description provided for @createFirstRoutineHint.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera rutina de {period}\ny organiza tus productos de skincare'**
  String createFirstRoutineHint(String period);

  /// No description provided for @createRoutine.
  ///
  /// In es, this message translates to:
  /// **'Crear rutina'**
  String get createRoutine;

  /// No description provided for @routineCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'✓ Rutina creada correctamente'**
  String get routineCreatedSuccess;

  /// No description provided for @routineCreateError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear la rutina'**
  String get routineCreateError;

  /// No description provided for @routineNameRequiredLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la rutina *'**
  String get routineNameRequiredLabel;

  /// No description provided for @routineNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Rutina de mañana'**
  String get routineNameHint;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Obligatorio'**
  String get requiredField;

  /// No description provided for @routineType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de rutina'**
  String get routineType;

  /// No description provided for @weekDays.
  ///
  /// In es, this message translates to:
  /// **'Días de la semana'**
  String get weekDays;

  /// No description provided for @none.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get none;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @addProduct.
  ///
  /// In es, this message translates to:
  /// **'Añadir producto'**
  String get addProduct;

  /// No description provided for @noMoreProductsToAdd.
  ///
  /// In es, this message translates to:
  /// **'No hay más productos\npara añadir'**
  String get noMoreProductsToAdd;

  /// No description provided for @routineNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get routineNameLabel;

  /// No description provided for @morningRoutineLabel.
  ///
  /// In es, this message translates to:
  /// **'Rutina de mañana'**
  String get morningRoutineLabel;

  /// No description provided for @nightRoutineLabel.
  ///
  /// In es, this message translates to:
  /// **'Rutina de noche'**
  String get nightRoutineLabel;

  /// No description provided for @products.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get products;

  /// No description provided for @noProductAdded.
  ///
  /// In es, this message translates to:
  /// **'Ningún producto añadido'**
  String get noProductAdded;

  /// No description provided for @longPressReorder.
  ///
  /// In es, this message translates to:
  /// **'Mantén pulsado para reordenar'**
  String get longPressReorder;

  /// No description provided for @noProductsYet.
  ///
  /// In es, this message translates to:
  /// **'Sin productos aún'**
  String get noProductsYet;

  /// No description provided for @addProductsToBuildRoutine.
  ///
  /// In es, this message translates to:
  /// **'Añade productos de tu armario\npara construir tu rutina'**
  String get addProductsToBuildRoutine;

  /// No description provided for @routineUpdated.
  ///
  /// In es, this message translates to:
  /// **'Rutina actualizada'**
  String get routineUpdated;

  /// No description provided for @updateError.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar'**
  String get updateError;

  /// No description provided for @productRemovedFromRoutine.
  ///
  /// In es, this message translates to:
  /// **'Producto eliminado de la rutina'**
  String get productRemovedFromRoutine;

  /// No description provided for @productRemoveError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar producto'**
  String get productRemoveError;

  /// No description provided for @reorderProductsError.
  ///
  /// In es, this message translates to:
  /// **'Error al reordenar productos'**
  String get reorderProductsError;

  /// No description provided for @productAddedToRoutine.
  ///
  /// In es, this message translates to:
  /// **'Producto añadido a la rutina'**
  String get productAddedToRoutine;

  /// No description provided for @productAddError.
  ///
  /// In es, this message translates to:
  /// **'Error al añadir producto'**
  String get productAddError;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
