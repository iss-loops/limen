import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggle de silencio propio. audioplayers ya respeta el volumen del sistema;
/// esto añade el control en-app que pide §3.
class SoundEnabled extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final soundEnabledProvider =
    NotifierProvider<SoundEnabled, bool>(SoundEnabled.new);

/// Reproduce los SFX del demo: acorde de revelación y clicks de tecla.
/// Tolera entornos sin plugin de audio (tests): falla en silencio.
class SoundController {
  final Ref _ref;
  // `late final` ⇒ los players se crean en el primer uso (no en construcción),
  // así un controlador silenciado nunca toca el plugin de audio.
  late final AudioPlayer _chord = AudioPlayer(playerId: 'limen_chord');
  late final AudioPlayer _key = AudioPlayer(playerId: 'limen_key');

  SoundController(this._ref);

  Future<void> reveal() => _play(_chord, 'audio/reveal.wav');
  Future<void> keystroke() => _play(_key, 'audio/key.wav');

  Future<void> _play(AudioPlayer player, String asset) async {
    if (!_ref.read(soundEnabledProvider)) return;
    try {
      await player.stop();
      await player.play(AssetSource(asset), volume: 0.9);
    } catch (_) {
      // Sin plugin de audio disponible: no romper el flujo.
    }
  }

  void dispose() {
    _chord.dispose().ignore();
    _key.dispose().ignore();
  }
}

final soundControllerProvider = Provider<SoundController>((ref) {
  final controller = SoundController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
