import 'package:flutter/material.dart';
import 'package:screen_capture_event/screen_capture_event.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final ScreenCaptureEvent screenListener = ScreenCaptureEvent();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _initScreenListener();
  }

  void _initScreenListener() {
    // Add listener for screen recording
    screenListener.addScreenRecordListener((recorded) {
      print("Screen recording event detected: $recorded");

      // Only update state if there is a change
      if (recorded != isRecording) {
        setState(() {
          isRecording = recorded;
        });

        if (recorded) {
          showAlert();
        }
      }
    });

    // Start watching for screen recording events
    screenListener.watch();
    print("Listener initialized");
  }

  
  void _restartListener() async {
    // Dispose and re-watch with a delay to handle short recordings
    screenListener.dispose();
    await Future.delayed(Duration(milliseconds: 100)); // Small delay for reset
    screenListener.watch();
    print("Listener restarted");
  }

  @override
  void dispose() {
    screenListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(isRecording ? "Recording Detected!" : "Not Recording"),
      ),
    );
  }

  void showAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            height: 350,
            width: MediaQuery.sizeOf(context).width - 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  size: 80,
                  color: Colors.red,
                ),
                const Text(
                  "Alert: Screen Recording",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                const Text("The current interface involves private content, screen recording is not allowed"),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartListener();
                  },
                  child: const Text("Confirm"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}