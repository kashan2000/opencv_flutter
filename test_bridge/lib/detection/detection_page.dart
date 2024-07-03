import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:opencv_flutter_bridge/detector/openCV_detector_async.dart';

import 'detections_layer.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage>
    with WidgetsBindingObserver {
  CameraController? _camController;
  late ArucoDetectorAsync _openCVDetector;
  int _camFrameRotation = 0;
  double _camFrameToScreenScale = 0;
  int _lastRun = 0;
  bool _detectionInProgress = false;
  List<double> _arucos = List.empty();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _openCVDetector = ArucoDetectorAsync();
    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _camController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  List<ShapeResult> identifiedShapes = [];

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _openCVDetector.destroy();
    _camController?.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    var idx =
        cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    if (idx < 0) {
      //  log("No Back camera found - weird");
      return;
    }

    var desc = cameras[idx];
    _camFrameRotation = Platform.isAndroid ? desc.sensorOrientation : 0;
    _camController = CameraController(
      desc,
      ResolutionPreset.high, // 720p
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _camController!.initialize();
      await _camController!
          .startImageStream((image) => _processCameraImage(image));
    } catch (e) {
      // log("Error initializing camera, error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_detectionInProgress ||
        !mounted ||
        DateTime.now().millisecondsSinceEpoch - _lastRun < 30) {
      return;
    }

    // Call the detector
    _detectionInProgress = true;

    var res = await _openCVDetector.detect(image, _camFrameRotation);

    List<ShapeResult> shapes =  parseShapes(res!);

    /// Logic not working
    int count = 1;
    // Float32List ressList = ress.asTypedList(count);

    // int index = 0;
    // while (index < count) {
    //   print("extracting data");
    //   // Process each shape's data from the ressList
    //   // Example assuming each shape occupies a fixed number of elements in the list
    //   List<Point> corners = [
    //     Point(res![index], res[index + 1]),
    //     Point(res[index + 2], res[index + 3]),
    //     Point(res[index + 4], res[index + 5]),
    //     Point(res[index + 6], res[index + 7]),
    //   ];
    //
    //   String shapeName = '';
    //   int shapeNameStartIndex = index + 8;  // Assuming corners take 8 elements
    //   while (res[shapeNameStartIndex] != -1) {
    //     shapeName += String.fromCharCode(res[shapeNameStartIndex].toInt());
    //
    //     shapeNameStartIndex++;
    //   }
    //
    //   // Move past the delimiter
    //   index = shapeNameStartIndex + 1;
    //
    //   // // Extract dominant color
    //   // List<int> dominantColor = [
    //   //   res[index],
    //   //   ressList[index + 1],
    //   //   ressList[index + 2],
    //   // ];
    //
    //   // Create ShapeResult object
    //   ShapeResult shapeResult = ShapeResult(corners, shapeName,[]);
    //   shapes.add(shapeResult);
    //
    //   print("shapes>> $shapes");
    //
    //   // Move to the next shape's data
    //   index += 3;  // Assuming dominant color takes 3 elements
    // }

    _detectionInProgress = false;
    _lastRun = DateTime.now().millisecondsSinceEpoch;

    // Make sure we are still mounted, the background thread can return a response after we navigate away from this
    // screen but before bg thread is killed
    if (!mounted || res == null || res.isEmpty) {
      return;
    }

    List<double> arucos = [];
    for (var shape in shapes) {
      for (var corner in shape.corners) {
        arucos.add(corner.x.toDouble());
        arucos.add(corner.y.toDouble());
      }
    }
    setState(() {
      identifiedShapes = shapes;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_camController == null) {
      return const Center(
        child: Text('Loading...'),
      );
    }

    return Stack(
      children: [
        CameraPreview(_camController!),
        DetectionsLayer(
          shapes: identifiedShapes,
        ),
      ],
    );
  }
}

List<ShapeResult> parseShapes(Float32List ress) {
  // print("parsing object");
  List<ShapeResult> shapes = [];
  int index = 0;

  while (index < ress.length) {
    // print(
    //     "inside while loop with res length is ${ress.length} and index is $index");
    // Extract corners
    List<Point> corners = [
      Point(ress[index], ress[index + 1]),
      Point(ress[index + 2], ress[index + 3]),
      Point(ress[index + 4], ress[index + 5]),
      Point(ress[index + 6], ress[index + 7]),
    ];

    // print("got corners >> $corners");

    // Extract shape name
    String shapeName = '';
    int shapeNameStartIndex = index + 8;
    while (ress[shapeNameStartIndex] != -1) {
      shapeName += String.fromCharCode(ress[shapeNameStartIndex].toInt());
      shapeNameStartIndex++;
      // print("shape name is >> $shapeName");
    }

    // Move past the delimiter
    index = shapeNameStartIndex + 1;

    // Extract dominant color
    List<int> dominantColor = [
      ress[index].toInt(),
      ress[index + 1].toInt(),
      ress[index + 2].toInt(),
    ];

    // Create ShapeResult object
    ShapeResult shapeResult = ShapeResult(corners, shapeName, dominantColor);
    shapes.add(shapeResult);

    // print("sahpe class is > $shapes");

    // Move to the next shape's data
    index += 3;
  }

  return shapes;
}

class ShapeResult {
  List<Point> corners;
  String shapeName;
  List<int> dominantColor;

  ShapeResult(this.corners, this.shapeName, this.dominantColor);

  @override
  String toString() {
    return 'ShapeResult{corners: $corners, shapeName: $shapeName, dominantColor: $dominantColor}';
  }
}
