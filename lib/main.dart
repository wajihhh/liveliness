import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:liveliness/welcome_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async{
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('CameraError: ${e.description}');
  }
  runApp(const LivelinessApp());
}

class LivelinessApp extends StatelessWidget {
  const LivelinessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Winky!",
      theme: ThemeData(
        primarySwatch: Colors.amber
      ),
      home: const Welcome(),
    );
  }
}
