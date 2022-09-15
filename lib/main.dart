import 'dart:async';
import 'package:app_devbase_v1/pages/checker.dart';
import 'package:app_devbase_v1/pages/home.dart';
import 'package:app_devbase_v1/pages/welcome.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/*=-=-=-=-=-=-=-= remote notifications config -=-=-=-=-=-=-=-=*/
/// To verify things are working, check out the native platform logs.
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

/// Create a [AndroidNotificationChannel] for heads up notifications
// AndroidNotificationChannel? channel;
/*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();

// runApp(MyApp());
    runApp(MaterialApp(
      initialRoute: '/checker',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/loginTwoStepAuth':
          // return PageTransition(
          //     child: LoginTwoStepAuth(key: new Key(new Uuid().toString())),
          //     type: PageTransitionType.rightToLeft);

          default:
            return null;
        }
      },
      routes: {
        '/checker': (context) => Checker(),
        '/welcome': (context) =>
            WelcomePage(key: new Key(new Uuid().toString())),
        '/home': (context) => Home(key: new Key(new Uuid().toString())),
      },
      home: Checker(),
    ));
  }, (error, st) => print(error));

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              BackButton(
                color: Colors.amber,
              ),
              Text(
                "header",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.redAccent),
        ));
  }
}
