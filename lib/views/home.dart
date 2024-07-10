import 'dart:io';

import 'package:cortex/constants/constants.dart';
import 'package:cortex/interpreter/bananaLeafClassifier/banana_leaf_classifier.dart';
import 'package:cortex/interpreter/interface.dart';
import 'package:cortex/interpreter/tomatoLeafClassifier/tomato_leaf_classifier.dart';
import 'package:cortex/tts/tts.dart';
import 'package:cortex/widgets/cortex_button.dart';
import 'package:cortex/widgets/display_output.dart';
import 'package:cortex/widgets/loading_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cortex/Authtentication/login.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isWaitingForInput = true;
  bool _isLoadingModels = true;
  bool _showRemedy = false;
  String _status = '';
  String? _image;
  dynamic _output = '';
  late Interpreter _interpreter;
  RegressionType regressionType = RegressionType.bananaLeafClassification;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _image = null;
    _isLoadingModels = true;
    _status = 'Loading the Models . . .';

    // Set default interpreter as Banana leaf classifier
    _interpreter = BananaLeafClassifier();

    loadModel();
    TextToSpeech.init();
  }

  @override
  void dispose() {
    // Dispose and clear memory
    super.dispose();
    Tflite.close();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: regressionType == RegressionType.bananaLeafClassification
          ? 'assets/models/banana_leaf_classifier_model/banana_leaf_classifier.tflite'
          : 'assets/models/tomato_leaf_classifier_model/tomato_leaf_classifier.tflite',
      labels: regressionType == RegressionType.bananaLeafClassification
          ? 'assets/models/banana_leaf_classifier_model/banana_leaf_labels.txt'
          : 'assets/models/tomato_leaf_classifier_model/tomato_leaf_labels.txt',
    );
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingModels = false;
      _status = "Finished loading models";
    });
  }

  Future<void> loadLeafDetectionModel() async {
    await Tflite.loadModel(
      model: 'assets/models/leaf_detection_model/leaf_detection_model.tflite',
      labels: 'assets/models/leaf_detection_model/leaf_labels.txt',
    );
  }

  void changeInterpreter() {
    setState(() {
      _interpreter = regressionType == RegressionType.tomatoLeafClassification
          ? TomatoLeafClassifier()
          : BananaLeafClassifier();
      loadModel();
    });
  }

  Future<void> pickImage(ImageSource source) async {
    // Function to grab the image from camera or gallery
    final image = await picker.getImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
      maxHeight: 224,
      maxWidth: 224,
    );
    if (image == null) return;

    setState(() {
      _image = image.path;
    });

    runThroughModel();
  }

  void runThroughModel() async {
    final result = await _interpreter.processImage(_image!);

    setState(() {
      _output = result.isNotEmpty ? result : "Could not identify the object.";
      _isWaitingForInput = false;
      _status = 'Idle';
      _showRemedy = result.isNotEmpty && result[0]['label'] != "healthy";
    });

    TextToSpeech.speak(result, regressionType);
  }

  void showRemedyPopup(String disease) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String remedy;
        switch (disease) {
          case 'Bacterial_spot':
            remedy =
                'Apply copper-based bactericides weekly to create a protective barrier. Copper-based sprays adhere to plant surfaces, inhibiting bacterial growth and reducing the spread of the disease.';
            break;
          case 'Early_blight':
            remedy =
                'Remove infected leaves to prevent further spread and apply fungicides. Early blight affects tomatoes and potatoes; removing affected foliage reduces fungal spore production. Fungicides should be applied preventatively to protect healthy plants.';
            break;
          case 'Late_blight':
            remedy =
                'Plant resistant varieties and apply fungicides to manage the disease. Late blight is a serious threat to potatoes and tomatoes. Resistant varieties offer the best defense, supplemented by fungicides to protect plants during periods of high humidity.';
            break;
          case 'Leaf_mold':
            remedy =
                'Improve ventilation by spacing plants and apply fungicides. Leaf mold thrives in humid conditions; spacing plants improves airflow, reducing humidity levels that favor fungal growth. Fungicides should be applied early in the season preventatively.';
            break;
          case 'Septoria_leaf_spot':
            remedy =
                'Remove infected leaves promptly and apply fungicides as directed. Septoria leaf spot affects tomato plants; removing infected foliage reduces spore production and slows disease spread. Fungicides should be applied according to label instructions.';
            break;
          case 'Spider_mites':
            remedy =
                'Control spider mites with insecticidal soaps or neem oil. Spider mites are tiny pests that suck plant sap, causing stippling and reducing plant vigor. Insecticidal soaps and neem oil are effective and safer alternatives to chemical pesticides.';
            break;
          case 'Target_spot':
            remedy =
                'Use fungicides and improve air circulation by pruning. Target spot affects various plants, causing circular lesions on leaves. Fungicides should be applied preventatively or at the first sign of infection. Pruning dense foliage improves airflow, reducing humidity that favors fungal growth.';
            break;
          case 'Mosaic_virus':
            remedy =
                'Remove and destroy infected plants to prevent spread. Mosaic viruses cause mottling and distortion in leaves, reducing plant vigor. There is no cure once a plant is infected, so prompt removal and destruction of infected plants are crucial to prevent further spread.';
            break;
          case 'Yellow_leaf_curl':
            remedy =
                'Control whiteflies using insecticides and plant resistant varieties. Yellow leaf curl is spread by whiteflies; controlling these pests with insecticides or reflective mulches is essential. Planting resistant varieties provides long-term protection against this viral disease.';
            break;
          case 'cordana':
            remedy =
                'Remove affected leaves and apply fungicides to manage Cordana. Cordana affects various plants, causing leaf spots and premature leaf drop. Removing infected foliage reduces fungal spore production. Fungicides should be applied preventatively.';
            break;
          case 'pestalotiopsis':
            remedy =
                'Prune infected areas and apply fungicides to control Pestalotiopsis. Pestalotiopsis causes dieback in plants, leading to branch and tip dieback. Pruning affected areas promotes new, healthy growth. Fungicides should be applied to protect healthy foliage.';
            break;
          case 'sigatoka':
            remedy =
                'Remove infected leaves promptly and apply fungicides for Sigatoka. Sigatoka affects banana plants, causing leaf spots that reduce fruit quality. Prompt removal of infected leaves reduces spore production. Fungicides should be applied preventatively or at the first signs of infection.';
            break;
          default:
            remedy =
                'No specific remedy available. Please consult an expert for advice tailored to your specific situation.';
            break;
        }

        return AlertDialog(
          title: Text('Remedy for $disease'),
          content: Text(remedy),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _image = null;
      _output = '';
      _isWaitingForInput = true;
      _status = 'Input Image';
      _showRemedy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: AppColors.cortexPrimaryBg,
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.04, vertical: width * 0.04),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
              vertical: width * 0.04, horizontal: width * 0.03),
          decoration: BoxDecoration(
            color: AppColors.cortexSecondaryBg,
            borderRadius: BorderRadius.circular(width * 0.02),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cortexFg,
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: width * 0.02, horizontal: width * 0.02),
                child: Row(
                  children: [
                    Text(
                      ' Classify',
                      style: GoogleFonts.sourceCodePro(
                        color: Colors.white,
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: width * 0.01, horizontal: width * 0.02),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black26,
                          ),
                          child: Text(
                            regressionType ==
                                    RegressionType.tomatoLeafClassification
                                ? 'Tomato disease'
                                : 'Banana disease',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        Transform.scale(
                          scale: 0.9,
                          child: CupertinoSwitch(
                            trackColor: Colors.amber,
                            activeColor: Colors.blue,
                            value: regressionType ==
                                RegressionType.tomatoLeafClassification,
                            onChanged: (value) {
                              if (_output != "Processing...") {
                                setState(() {
                                  _output = "Processing...";
                                  regressionType = value
                                      ? RegressionType.tomatoLeafClassification
                                      : RegressionType.bananaLeafClassification;
                                  changeInterpreter();
                                  if (_image != null) {
                                    runThroughModel();
                                  } else {
                                    _output = "";
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(height: width * 0.05),
              if (_showRemedy)
                Container(
                  width: 100, // Adjust width as needed
                  height: 40, // Adjust height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.amber,
                  ),
                  child: TextButton(
                    onPressed: () {
                      final label = _output[0]['label'];
                      showRemedyPopup(label);
                    },
                    child: Text(
                      'Remedy',
                      style: TextStyle(
                        color: Color.fromARGB(255, 26, 0, 0),
                        fontSize: 16, // Adjust font size as needed
                      ),
                    ),
                  ),
                ),
              SizedBox(height: width * 0.05),
              Center(
                child: _isWaitingForInput == true
                    ? LoadingStatus(
                        label: _status,
                        isBusy: _isLoadingModels,
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: width * 0.6,
                            width: width * 0.6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                File(_image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: width * 0.06),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.1,
                                vertical: width * 0.05),
                            child: Center(
                              child: DisplayOutput(
                                regressionType: regressionType,
                                output: _output,
                              ),
                            ),
                          ),
                          SizedBox(height: width * 0.06),
                          CortexFlatButton(
                            label: 'Clear',
                            onTap: clearImage,
                          ),
                          SizedBox(
                            height: width * 0.05,
                          ),
                          // if (_showRemedy)
                          //   CortexFlatButton(
                          //     label: 'Remedy',
                          //     onTap: () {
                          //       final label = _output[0]['label'];
                          //       showRemedyPopup(label);
                          //     },
                          //   ),
                        ],
                      ),
              ),
              Column(
                children: [
                  CortexFlatButton(
                    label: 'Take A Photo',
                    onTap: () => pickImage(ImageSource.camera),
                  ),
                  SizedBox(
                    height: width * 0.05,
                  ),
                  CortexFlatButton(
                    label: 'Pick From Gallery',
                    onTap: () => pickImage(ImageSource.gallery),
                  ),
                  SizedBox(
                    height: width * 0.05,
                  ),
                  Container(
                    width: 100, // Adjust width as needed
                    height: 40, // Adjust height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.amber,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color.fromARGB(255, 26, 0, 0),
                          fontSize: 16, // Adjust font size as needed
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
