import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:native_opencv/native_opencv.dart';

import 'detection/detection_page.dart';
import 'detection/video_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "pathfinder",
    /// Add support for multiple platforms later
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAYTcquL_OQAZv18AAdorrEIPqxGLMgrF4',
      appId: '1:318338551652:android:01379f11ea447c492f7471',
      messagingSenderId: '318338551652',
      projectId: 'pathfinder-1fb80',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open CV Flutter Bridge',
      showSemanticsDebugger: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Experience Open CV'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 bool showVersion = false;
 final nativeOpencv = NativeOpencv();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Open CV Flutter tutorial',
            ),
            TextButton(onPressed: () {
                // setState(() {
                //   showVersion = true;
                //   print("version>> ${nativeOpencv.cvVersion()}");
                // });
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                  return const DetectionPage();
                }));
            }, child: const Text("Get Open CV for real time")),
            SizedBox(height: 20,),
            TextButton(onPressed: () {
              // setState(() {
              //   showVersion = true;
              //   print("version>> ${nativeOpencv.cvVersion()}");
              // });
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return  VideoProcessor();
              }));
            }, child: const Text("Get Open CV for video")),
            if(showVersion)
              Text("Open CV version is : ${nativeOpencv.cvVersion()}")
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
