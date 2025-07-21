import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  static Future<void> playWrongSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  static Future<void> playResultSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/result.mp3'));
    } catch (e) {
      print('Error playing result sound: $e');
    }
  }

  static Future<void> playCoinsSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/coins.mp3'));
    } catch (e) {
      print('Error playing coins sound: $e');
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}