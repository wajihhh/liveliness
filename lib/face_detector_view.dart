import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'camera_view.dart';
import 'painters/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  _FaceDetectorViewState createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  bool _eyeBlinked = false;
  CustomPaint? _customPaint;
  String _text = "Blink your eyes";
  bool rightBlinked = false;
  bool leftBlinked = false;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Winky!',
      customPaint: _customPaint,
      text: _text,
      eyeBlinked: _eyeBlinked,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
      );
      _customPaint = CustomPaint(painter: painter);

      for (final face in faces) {
        double leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0.0;
        double rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0.0;

        print("Left Eye Probability ===> ${face.leftEyeOpenProbability}");
        print("Right Eye Probability ===> ${face.rightEyeOpenProbability}");

        if (leftEyeOpenProbability < 0.3) {
          leftBlinked = true;
          print("Left Eye Blinked");
          if (leftBlinked) {
            setState(() {
              _text = "Great! now blink your other eye";
              // _eyeBlinked = true;
            });
          }
          if (leftBlinked && rightBlinked) {
            print("Both Eyes Blinked");
            setState(() {
              _text = "Thank! your task has been done";
              _eyeBlinked = true;
            });
          }
        }
        if (rightEyeOpenProbability < 0.3) {
          rightBlinked = true;
          print("Right Eye Blinked");
          if (rightBlinked) {
            setState(() {
              _text = "Great! now blink your other eye";
              // _eyeBlinked = true;
            });
          }
          if (leftBlinked && rightBlinked) {
            print("Both Eyes Blinked");
            setState(() {
              _text = "Thank! your task has been done";
              _eyeBlinked = true;
            });
          }
        }
      }

    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
