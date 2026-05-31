import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LIMEN';

  @override
  String get submitAction => 'enviar';

  @override
  String get continueAction => 'continuar';

  @override
  String get restartAction => 'volver al umbral';

  @override
  String get wrongAnswer => 'la señal no reconoce eso.';

  @override
  String get networkDown => 'la señal no llega.';

  @override
  String get sessionError => 'el umbral no responde.';

  @override
  String get nodeLocked => 'aún no es tu turno.';

  @override
  String get loading => 'escuchando…';

  @override
  String get answerFieldLabel => 'tu respuesta';

  @override
  String get decodingLabel => 'descifrando';

  @override
  String get soundToggle => 'sonido';

  @override
  String get retryAction => 'reintentar';

  @override
  String arcProgress(int done, int total) {
    return 'progreso: $done de $total';
  }

  @override
  String get loginPrompt => 'te encontraron. ¿cómo te nombrarán los que observan?';

  @override
  String get aliasFieldLabel => 'tu alias';

  @override
  String get aliasHint => 'alias';

  @override
  String get enterAction => 'cruzar';

  @override
  String get mapTitle => 'el arco';

  @override
  String get mapOpen => 'mapa del arco';

  @override
  String get backAction => 'volver';

  @override
  String nodeLabel(String n) {
    return 'nodo $n';
  }

  @override
  String get stateSolved => 'resuelto';

  @override
  String get stateAvailable => 'disponible';

  @override
  String get stateSealed => 'sellado';
}
