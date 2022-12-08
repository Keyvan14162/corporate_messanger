import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_auth/route_generator.dart';
import 'firebase_options.dart';

// 26/08/2022
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // hide android bottom buttons, immersive sticky
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home defined here
      onGenerateRoute: RouteGenerator.routeGenrator,
      title: "corporate-messaging",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF3B4257),
        secondaryHeaderColor: Colors.tealAccent.shade400,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          color: Colors.teal,
          foregroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.teal,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
    );
  }
}
