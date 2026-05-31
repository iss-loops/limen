import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
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
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es')
  ];

  /// Nombre del producto.
  ///
  /// In es, this message translates to:
  /// **'LIMEN'**
  String get appTitle;

  /// Acción para enviar una respuesta.
  ///
  /// In es, this message translates to:
  /// **'enviar'**
  String get submitAction;

  /// Avanzar al siguiente nodo.
  ///
  /// In es, this message translates to:
  /// **'continuar'**
  String get continueAction;

  /// Reiniciar el recorrido del demo.
  ///
  /// In es, this message translates to:
  /// **'volver al umbral'**
  String get restartAction;

  /// Feedback de respuesta incorrecta (voz del sistema).
  ///
  /// In es, this message translates to:
  /// **'la señal no reconoce eso.'**
  String get wrongAnswer;

  /// Sin conexión con el servidor.
  ///
  /// In es, this message translates to:
  /// **'la señal no llega.'**
  String get networkDown;

  /// Fallo al abrir sesión.
  ///
  /// In es, this message translates to:
  /// **'el umbral no responde.'**
  String get sessionError;

  /// Intento de acceder a un nodo bloqueado.
  ///
  /// In es, this message translates to:
  /// **'aún no es tu turno.'**
  String get nodeLocked;

  /// Estado de carga.
  ///
  /// In es, this message translates to:
  /// **'escuchando…'**
  String get loading;

  /// Etiqueta accesible del campo de respuesta.
  ///
  /// In es, this message translates to:
  /// **'tu respuesta'**
  String get answerFieldLabel;

  /// Etiqueta accesible mientras el texto se revela.
  ///
  /// In es, this message translates to:
  /// **'descifrando'**
  String get decodingLabel;

  /// Etiqueta accesible del botón de silencio.
  ///
  /// In es, this message translates to:
  /// **'sonido'**
  String get soundToggle;

  /// Reintentar tras un fallo de red.
  ///
  /// In es, this message translates to:
  /// **'reintentar'**
  String get retryAction;

  /// Etiqueta accesible del indicador de progreso del arco.
  ///
  /// In es, this message translates to:
  /// **'progreso: {done} de {total}'**
  String arcProgress(int done, int total);

  /// Voz del sistema en la entrada de alias.
  ///
  /// In es, this message translates to:
  /// **'te encontraron. ¿cómo te nombrarán los que observan?'**
  String get loginPrompt;

  /// Etiqueta accesible del campo de alias.
  ///
  /// In es, this message translates to:
  /// **'tu alias'**
  String get aliasFieldLabel;

  /// Placeholder del campo de alias.
  ///
  /// In es, this message translates to:
  /// **'alias'**
  String get aliasHint;

  /// Acción para entrar tras elegir alias.
  ///
  /// In es, this message translates to:
  /// **'cruzar'**
  String get enterAction;

  /// Título de la pantalla de mapa del arco.
  ///
  /// In es, this message translates to:
  /// **'el arco'**
  String get mapTitle;

  /// Etiqueta accesible del botón que abre el mapa.
  ///
  /// In es, this message translates to:
  /// **'mapa del arco'**
  String get mapOpen;

  /// Etiqueta accesible del botón de regreso.
  ///
  /// In es, this message translates to:
  /// **'volver'**
  String get backAction;

  /// Etiqueta de un nodo en el mapa.
  ///
  /// In es, this message translates to:
  /// **'nodo {n}'**
  String nodeLabel(String n);

  /// Estado de un nodo resuelto.
  ///
  /// In es, this message translates to:
  /// **'resuelto'**
  String get stateSolved;

  /// Estado de un nodo desbloqueado.
  ///
  /// In es, this message translates to:
  /// **'disponible'**
  String get stateAvailable;

  /// Estado de un nodo bloqueado.
  ///
  /// In es, this message translates to:
  /// **'sellado'**
  String get stateSealed;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es': return AppL10nEs();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
