// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get all => 'Todo';

  @override
  String get alphaBadge => 'ALFA';

  @override
  String get alphaBanner =>
      'Esta aplicación está en alfa. Las funciones pueden cambiar y se esperan errores.';

  @override
  String get apertium => 'Apertium';

  @override
  String get autoTryAll => 'Auto (probar todos)';

  @override
  String get azure => 'Azure';

  @override
  String get cancel => 'Cancelar';

  @override
  String couldNotLoadVoices(String error) {
    return 'No se pudieron cargar las voces: $error';
  }

  @override
  String get couldNotOpenBugReport => 'No se pudo abrir el informe de error';

  @override
  String get createAccountForMore =>
      'Crea una cuenta gratuita de OpenSubtitles para obtener más resultados.';

  @override
  String get createFreeAccount => 'Crear cuenta gratuita';

  @override
  String get createOsAccount => 'Crear cuenta de OpenSubtitles';

  @override
  String get defaultLanguageLabel => 'Idioma predeterminado';

  @override
  String get defaultTargetLanguage => 'Idioma de destino predeterminado';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteTranslation => '¿Eliminar traducción?';

  @override
  String get dismiss => 'Descartar';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? Crea una';

  @override
  String get emailHelper =>
      'Aumenta el límite diario de MyMemory de 5.000 a 50.000 caracteres';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get emailOptional => 'Correo electrónico (opcional)';

  @override
  String get enterSearchQuery => 'Introduce una consulta de búsqueda';

  @override
  String get errorCheckingAuth =>
      'Error al verificar el estado de autenticación';

  @override
  String get failedToLoad => 'Error al cargar';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get gotIt => 'Entendido';

  @override
  String get help => 'Ayuda';

  @override
  String get helpCreateAccountFull =>
      'Crea una cuenta gratuita de OpenSubtitles para obtener 5 descargas al día. Abre la página de registro en tu navegador.';

  @override
  String get helpDownloadsDesc =>
      'Todos los proveedores se buscan en paralelo. Los resultados de OpenSubtitles requieren inicio de sesión. Toca un resultado para descargar y comenzar la reproducción.';

  @override
  String get helpDownloadsFull =>
      'Cuando buscas, todos los proveedores se consultan en paralelo. Si no has iniciado sesión en OpenSubtitles, solo se muestran resultados de SubDL y Podnapisi. Toca un resultado para descargar y reproducir. Las descargas de OpenSubtitles requieren un inicio de sesión gratuito.';

  @override
  String get helpProvidersAppDesc =>
      'Esta aplicación busca en tres proveedores de subtítulos. OpenSubtitles es gratuito con 5 descargas al día o ilimitado con una suscripción VIP. SubDL ofrece 2.000 búsquedas al día con una clave API gratuita. Podnapisi no requiere autenticación ni tiene límite diario.';

  @override
  String get helpProvidersDescription =>
      'OpenSubtitles — cuenta gratuita: 5 descargas/día, VIP: ilimitado.\nSubDL — 2.000 búsquedas/día con clave API gratuita.\nPodnapisi — sin autenticación, sin límite diario.';

  @override
  String get homeTagline => 'Elige subtítulos y léelos en voz alta';

  @override
  String get howDownloadsWork => 'Cómo funcionan las descargas';

  @override
  String get language => 'Idioma';

  @override
  String get libreTranslate => 'LibreTranslate';

  @override
  String get loadingSaved => 'Cargando traducciones guardadas…';

  @override
  String loggedInAs(String username) {
    return 'Iniciada sesión como $username';
  }

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginFailed =>
      'Inicio de sesión fallido. Verifica tus credenciales.';

  @override
  String get loginRequired => 'Inicio de sesión requerido';

  @override
  String get loginRequiredHelp =>
      'Necesitas una cuenta gratuita de OpenSubtitles para descargar subtítulos.\n\nLas cuentas gratuitas obtienen 5 descargas al día.\n\nTambién puedes usar subtítulos de SubDL o Podnapisi sin iniciar sesión.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get movies => 'Películas';

  @override
  String get myMemory => 'MyMemory';

  @override
  String get newestFirst => 'Más recientes primero';

  @override
  String get next => 'Siguiente';

  @override
  String get noDownloadableResults =>
      'No se encontraron resultados descargables. Crea una cuenta gratuita de OpenSubtitles para obtener más resultados.';

  @override
  String noResultsFound(String query) {
    return 'No se encontraron resultados para \"$query\".';
  }

  @override
  String get noSavedTranslations => 'Aún no hay traducciones guardadas.';

  @override
  String get noTranslationsAvailable => 'No hay traducciones disponibles.';

  @override
  String noVoicesAvailable(String language) {
    return 'No hay voces disponibles para $language';
  }

  @override
  String get ok => 'OK';

  @override
  String get oldestFirst => 'Más antiguos primero';

  @override
  String get openSignupPage => 'Abrir página de registro';

  @override
  String get openSubtitlesAccount => 'Cuenta de OpenSubtitles';

  @override
  String get password => 'Contraseña';

  @override
  String get pause => 'Pausa';

  @override
  String get play => 'Reproducir';

  @override
  String get playSample => 'Reproducir muestra';

  @override
  String get playTranslatedSample => 'Reproducir muestra traducida';

  @override
  String get pleaseEnterBoth =>
      'Introduce tanto el nombre de usuario como la contraseña';

  @override
  String get previous => 'Anterior';

  @override
  String get readAccountHelpAloud =>
      'Leer ayuda de creación de cuenta en voz alta';

  @override
  String get readAccountInfoAloud =>
      'Leer información de la cuenta en voz alta';

  @override
  String get readAloud => 'Leer en voz alta';

  @override
  String get readHelpAloud => 'Leer ayuda en voz alta';

  @override
  String get readHelpAloudNoResults => 'Leer ayuda de búsqueda en voz alta';

  @override
  String get readHowDownloadsWorkAloud =>
      'Leer cómo funcionan las descargas en voz alta';

  @override
  String get readSubtitleProvidersAloud =>
      'Leer ayuda de proveedores de subtítulos en voz alta';

  @override
  String get readWelcomeAloud => 'Leer mensaje de bienvenida en voz alta';

  @override
  String get recent => 'Reciente';

  @override
  String get reportABug => 'Reportar un error';

  @override
  String get reportABugSubtitle =>
      'Abrir un informe de error prellenado en GitHub';

  @override
  String get savedTranslations => 'Traducciones guardadas';

  @override
  String get savedTranslationsTitle => 'Traducciones Guardadas';

  @override
  String get saveTranslation => 'Guardar traducción';

  @override
  String get saveTranslationHint => 'Guardar traducción para uso sin conexión';

  @override
  String get searchHelp => 'Ayuda de búsqueda';

  @override
  String get searchHint => 'Buscar películas y programas de TV…';

  @override
  String get searchSubtitles => 'Buscar subtítulos';

  @override
  String get searchTips => 'Consejos de búsqueda';

  @override
  String get searchTipsContent =>
      'Busca subtítulos de películas y TV por nombre.\n\nLos resultados de SubDL y Podnapisi siempre se muestran. Los resultados de OpenSubtitles aparecen solo cuando has iniciado sesión.\n\nLas cuentas gratuitas de OpenSubtitles obtienen 5 descargas al día.';

  @override
  String get searchTitle => 'Buscar Subtítulos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get skip => 'Saltar';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get speechConfiguration => 'Configuración de voz';

  @override
  String get speechRate => 'Velocidad de voz';

  @override
  String get speed => 'Velocidad';

  @override
  String get stop => 'Detener';

  @override
  String get stopSample => 'Detener muestra';

  @override
  String get stopTranslatedSample => 'Detener muestra traducida';

  @override
  String get subtitleProviders => 'Proveedores de subtítulos';

  @override
  String get support => 'Soporte';

  @override
  String get sync => 'Sincronización';

  @override
  String get testTranslatedVoice => 'Probar voz traducida';

  @override
  String testTranslatedVoiceDescription(String language) {
    return 'Traduce las primeras 5 líneas a $language y escúchalas.';
  }

  @override
  String get testVoice => 'Probar voz';

  @override
  String testVoiceDescription(String speed, String pitch) {
    return 'Escucha una muestra a tu velocidad actual (${speed}x) y tono (${pitch}x).';
  }

  @override
  String get timeHint => 'Formato: HH:MM';

  @override
  String get titleAZ => 'Título (A-Z)';

  @override
  String translatingEntries(String current, String total) {
    return 'Traduciendo $current de $total…';
  }

  @override
  String get translationAndLanguage => 'Traducción e idioma';

  @override
  String get translationError => 'Error de traducción';

  @override
  String get translationFailedTap => 'Traducción fallida: toca para detalles';

  @override
  String get translationProvider => 'Proveedor de traducción';

  @override
  String get translationSaved => 'Traducción guardada';

  @override
  String get tvEpisodes => 'Episodios de TV';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado.';

  @override
  String get unknownVoice => 'Desconocida';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get voice => 'Voz';

  @override
  String get voicePitch => 'Tono de voz';

  @override
  String get welcomeFullText =>
      '¡Bienvenido a subvocal!\n\nEsta aplicación lee subtítulos en voz alta en sincronía con tu video.\n\nPara empezar:\n1. Busca una película o programa en la pestaña Buscar.\n2. Toca un resultado para descargar subtítulos.\n3. La reproducción comienza automáticamente.\n\nTambién puedes iniciar sesión en OpenSubtitles en Ajustes para obtener más resultados.\n\n¿Necesitas ayuda? Consulta la sección de Ayuda en Ajustes.';

  @override
  String get welcomeGettingStarted => 'Para empezar:';

  @override
  String get welcomeHelpHint =>
      '¿Necesitas ayuda? Consulta la sección de Ayuda en Ajustes.';

  @override
  String get welcomeIntro =>
      'Esta aplicación lee subtítulos en voz alta en sincronía con tu video.';

  @override
  String get welcomeLoginHint =>
      'También puedes iniciar sesión en OpenSubtitles en Ajustes para obtener más resultados.';

  @override
  String welcomeStep(String number, String description) {
    return '$number. $description';
  }

  @override
  String get welcomeTitle => 'Bienvenido a subvocal';

  @override
  String deleteConfirm(String title, String language) {
    return '¿Estás seguro de que quieres eliminar \"$title\" ($language)?';
  }

  @override
  String searchError(String message) {
    return 'Búsqueda fallida: $message';
  }

  @override
  String get welcomeStep1 =>
      '1. Busca una película o programa en la pestaña Buscar.';

  @override
  String get welcomeStep2 => '2. Toca un resultado para descargar subtítulos.';

  @override
  String get welcomeStep3 => '3. La reproducción comienza automáticamente.';

  @override
  String get noSubtitleLoaded => 'No hay subtítulos cargados';
}
