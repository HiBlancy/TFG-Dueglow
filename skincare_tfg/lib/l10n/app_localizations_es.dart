// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'DueGlow';

  @override
  String helloUser(String name) {
    return '¡Hola $name!';
  }

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get createAcount => 'Crear Cuenta';

  @override
  String get email => 'Correo electrónico';

  @override
  String get userEmailExample => 'usuario@ejemplo.com';

  @override
  String get enterEmailAddress => 'Ingrese su correo';

  @override
  String get invalidAddress => 'Correo inválido';

  @override
  String get password => 'Contraseña';

  @override
  String get enterPass => 'Ingrese su contraseña';

  @override
  String get pass6Char => 'Mínimo 6 caracteres';

  @override
  String get myProducts => 'Mis productos';

  @override
  String get seeAll => 'VER TODOS';

  @override
  String get routines => 'Rutinas';

  @override
  String get categories => 'Categorías';

  @override
  String get expiringSoon => 'Próximos a caducar';

  @override
  String get days => 'días';

  @override
  String get allFine => '¡Todo en orden!';

  @override
  String get noProdExpiring => 'No hay productos próximos a caducar';

  @override
  String get searchProducts => 'Buscar productos';

  @override
  String get searchNameBrand => 'Buscar por nombre o marca...';

  @override
  String get exmapleSearch => 'Ej: \"Yves Rocher\", \"hidratante\"';

  @override
  String get camera => 'Cámara';

  @override
  String get aimBarcode => 'Apunta al código de barras';

  @override
  String get settings => 'Configuración';

  @override
  String get general => 'General';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notifText => 'Recibir alertas y actualizaciones';

  @override
  String get appearance => 'Apariencia';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get information => 'Información';

  @override
  String get about => 'Acerca de';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get retry => 'Reintentar';

  @override
  String get clear => 'Limpiar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get notificationsEnabled => 'Notificaciones activadas';

  @override
  String get notificationsDisabled => 'Notificaciones desactivadas';

  @override
  String get allProducts => 'Todos los productos';

  @override
  String get noProductsRegistered => 'No tienes productos registrados';

  @override
  String get noProductsInHave => 'No tienes productos en \"Tengo\"';

  @override
  String get noProductsInWishlist => 'No tienes productos en \"Deseados\"';

  @override
  String get noFinishedProducts => 'No has registrado productos terminados';

  @override
  String get addFirstProductsHint =>
      'Agrega tus primeros productos escaneando códigos de barras o buscando en la base de datos';

  @override
  String get haveProductsHint =>
      'Los productos que marques como \"Tengo\" aparecerán aquí';

  @override
  String get wishlistProductsHint =>
      'Agrega productos a tu wishlist desde la pantalla de detalles';

  @override
  String get usedProductsHint =>
      'Los productos que has acabado este mes aparecen en esta lista';

  @override
  String get usedProductsInfo =>
      'Estos son los productos que has terminado este mes. Cuando termine el mes, estos productos se eliminarán automáticamente y se almacenarán los datos para el proyecto PAN.';

  @override
  String productsCount(int count, String pluralSuffix) {
    return '$count producto$pluralSuffix';
  }

  @override
  String get searchLoading => 'Buscando...';

  @override
  String get searchErrorTitle => 'Error al buscar';

  @override
  String get searchConnectionError => 'Error al buscar. Revisa tu conexión.';

  @override
  String get searchNoResults => 'No se encontraron productos';

  @override
  String get searchTryAnotherTerm => 'Prueba con otro término de búsqueda';

  @override
  String get searchBeautyProducts => 'Busca productos de belleza';

  @override
  String get searchExamplesExtended =>
      'Ej: \"L\'Oréal\", \"hidratante\", \"champú\"';

  @override
  String get noBrand => 'Sin marca';

  @override
  String get scanProductNotFound => 'Producto no encontrado';

  @override
  String scanNoBarcodeInfo(String barcode) {
    return 'No se encontró información para el código de barras:\n$barcode\n\n¿Quieres crear un nuevo producto manualmente?';
  }

  @override
  String get createProduct => 'Crear producto';

  @override
  String get newProductDefaultName => 'Nuevo producto';

  @override
  String get deleteRoutineTitle => 'Eliminar rutina';

  @override
  String deleteRoutineQuestion(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get routineDeleted => 'Rutina eliminada';

  @override
  String get routinesLoadError => 'Error al cargar rutinas';

  @override
  String get routineDeleteError => 'Error al eliminar rutina';

  @override
  String get morning => 'Mañana';

  @override
  String get night => 'Noche';

  @override
  String get newRoutine => 'Nueva rutina';

  @override
  String get noMorningRoutines => 'Sin rutinas de mañana';

  @override
  String get noNightRoutines => 'Sin rutinas de noche';

  @override
  String createFirstRoutineHint(String period) {
    return 'Crea tu primera rutina de $period\ny organiza tus productos de skincare';
  }

  @override
  String get createRoutine => 'Crear rutina';

  @override
  String get routineCreatedSuccess => '✓ Rutina creada correctamente';

  @override
  String get routineCreateError => 'Error al crear la rutina';

  @override
  String get routineNameRequiredLabel => 'Nombre de la rutina *';

  @override
  String get routineNameHint => 'Ej: Rutina de mañana';

  @override
  String get requiredField => 'Obligatorio';

  @override
  String get routineType => 'Tipo de rutina';

  @override
  String get weekDays => 'Días de la semana';

  @override
  String get none => 'Ninguno';

  @override
  String get all => 'Todos';

  @override
  String get addProduct => 'Añadir producto';

  @override
  String get noMoreProductsToAdd => 'No hay más productos\npara añadir';

  @override
  String get routineNameLabel => 'Nombre';

  @override
  String get morningRoutineLabel => 'Rutina de mañana';

  @override
  String get nightRoutineLabel => 'Rutina de noche';

  @override
  String get products => 'Productos';

  @override
  String get noProductAdded => 'Ningún producto añadido';

  @override
  String get longPressReorder => 'Mantén pulsado para reordenar';

  @override
  String get noProductsYet => 'Sin productos aún';

  @override
  String get addProductsToBuildRoutine =>
      'Añade productos de tu armario\npara construir tu rutina';

  @override
  String get routineUpdated => 'Rutina actualizada';

  @override
  String get updateError => 'Error al actualizar';

  @override
  String get productRemovedFromRoutine => 'Producto eliminado de la rutina';

  @override
  String get productRemoveError => 'Error al eliminar producto';

  @override
  String get reorderProductsError => 'Error al reordenar productos';

  @override
  String get productAddedToRoutine => 'Producto añadido a la rutina';

  @override
  String get productAddError => 'Error al añadir producto';
}
