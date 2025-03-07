import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:haven_net/features/first_screen/view/first_screen.dart';
import 'package:haven_net/features/local_notification/controller/local_notification_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:haven_net/features/parent_home_page/view/parent_home_page.dart';
import 'package:haven_net/features/voice_recognition/view/voice_recognition_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.  
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  } 


  print('[BackgroundFetch] Headless event received.');
  
  print("Hello i am speaking from background!!");
  BackgroundFetch.finish(taskId);
}

void main() async {
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseApiInterface().initNotifications();
  runApp(const MyApp());

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button & start speaking";
  String email = "";
  String password = "";
  String userType = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    await getLoginDataFromSharedPreferences();

    print("Firebase Token : ${await FirebaseMessaging.instance.getToken()}");
    int status = await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE
    ), (String taskId) async {  // <-- Event handler
      // This is the fetch-event callback.
      _speech = stt.SpeechToText();
      print("I am here [BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, DateTime.now());
      });
      print("Line 85 events till now : $_events");
      await _listen();
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {  // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundFetch] configure success: $status');
    setState(() {
      _status = status;
    });        

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }


  Future<void> _listen() async {
    print("In _listen() Function..");

    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );

    print("executed availability");

    if (available) {
      print("In available block and listening....");
      //_isListening = true;
      //setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
      );
    }

    else {
      _speech.stop();
      print("Engine is not available now");
    }
    // if (!_isListening) {
    //   print("In listening block, checking availability");
    // } 
    
    // else {
    //   _isListening = false;
    //   print("stopped listening");
    //   setState(() => _isListening = false);
    //   _speech.stop();
    // }
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  Future<void> getLoginDataFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('login_email') ?? "";
    password = prefs.getString('login_password') ?? "";
    userType = prefs.getString('login_user_type') ?? "";
  }

  @override
  Widget build(BuildContext context) {
    print(_events);
    print(_text);

    if(email != "" && password != "" && userType != "") {
      if(userType == "child") {
        return MaterialApp(
          home: SpeechScreen(
            eventsList: _events,
          )
        );
        
        
      }

      else {
        return MaterialApp(
          home: ParentsHomePage(
            email: email
          )
        );
        
      }
    }

    else {
      return const MaterialApp(
        home: FirstScreen(),
      );
    }
  }
}
