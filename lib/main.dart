import 'package:flutter/material.dart';
import 'package:sherlock_voice_assistant/constant.dart';
import 'package:sherlock_voice_assistant/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //* init class size config because we're gonna use it in the app
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        backgroundColor: Colors.black,
        textTheme: TextTheme(
            headline1: TextStyle(
              color: Colors.white,
              fontSize: 36.0
            ),
            bodyText1: TextStyle(
              color: Colors.white,
              fontSize: 24.0
            )),
      ),
    );
  }
}
