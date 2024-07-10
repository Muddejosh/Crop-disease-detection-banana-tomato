import 'package:cortex/constants/constants.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static final FlutterTts flutterTts = FlutterTts();

  static speak(dynamic text, RegressionType type) async {
    String label = text[0]['label'].toLowerCase().replaceAll('_', ' ');
    if (type == RegressionType.tomatoLeafClassification) {
      if (label.contains('healthy')) {
        await flutterTts.speak('Tomato healthy');
      } else {
        await flutterTts.speak('Disease Identified: Tomato $label');
      }
    } else if (type == RegressionType.bananaLeafClassification) {
      if (label.contains('healthy')) {
        await flutterTts.speak('Banana healthy');
      } else {
        await flutterTts.speak('Disease Identified: Banana $label');
      }
    } else {
      await flutterTts.speak('$text');
    }
  }

  static init() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.0);
  }

  static stop() async {
    await flutterTts.stop();
  }
}
