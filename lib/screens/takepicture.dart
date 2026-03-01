import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/fonctions.dart';

import '../core/theming/app_style.dart';
import '../core/utils/size_utils.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen_old that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {

  const TakePictureScreen({
    Key? key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {

    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }
  String imagePath='';
  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    return
    imagePath.isEmpty?
      Scaffold(
      appBar: AppBar(
        backgroundColor: UIColors.primaryAccent,
        title:
        Padding(
          padding: getPadding(left: 90),
          child:
          Text("Camera",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H4(color: Colors.black, weight: 'regular'),
          ),
        ),
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                onPressed: () { Navigator.of(context).pop(); },
              );
            }) ,),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.background,
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;
            imagePath=image.path;
            setState(() {

            });
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    ):Scaffold(
      appBar:
      AppBar(
        backgroundColor: UIColors.primaryAccent,
        title:
        Padding(
          padding: getPadding(left: 80),
          child:
          Text("Valider",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H4(color: Colors.black, weight: 'regular'),
          ),
        ),
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                onPressed: () {
                  imagePath='';
                  //Navigator.of(context).pop();
                  setState(() {

                });},
              );
            }) ,

      ),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.background,
        onPressed: () async {
          saveKey('tmpImage', imagePath);
          print('tmpImage *********'+ imagePath);
          Navigator.of(context).pop();
          setState(() {

          });
        },
        child: Icon(Icons.check,color: UIColors.primaryAccent,),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({Key? key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                onPressed: () { Navigator.of(context).pop(); },
              );
            }) ,
        title:
        Padding(
          padding: getPadding(left: 20),
          child:
          Text("Capture",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H4(color: Colors.black, weight: 'regular'),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: (){
              saveKey('tmpImage', imagePath);
              //Navigator.of(context).pop();
            },
            child: Icon(Icons.check,color: Theme.of(context).colorScheme.background,),
          ),
        ],
      ),
      body: Image.file(File(imagePath)),
    );
  }
}