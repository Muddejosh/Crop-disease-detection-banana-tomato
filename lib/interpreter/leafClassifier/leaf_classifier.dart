import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:cortex/interpreter/interface.dart';

class LeafClassifier extends Interpreter {
  @override
  Future<List> processImage(String imgPath) async {
    return classifyImage(File(imgPath));
  }

  Future<List> classifyImage(File image) async {
    // this function runs the model on the image
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 4,
      threshold: 0.5, // TODO: Increase threshold and handle null
      imageMean: 225.0,
      imageStd: 225.0,
    );
    return output ?? [];
  }
}
