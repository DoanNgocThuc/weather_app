import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/screens/confirm_screen.dart';
import 'package:weather_app/screens/subscribe_screen.dart';
import 'screens/home_screen.dart';
import '../firebase_options.dart';


Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env"); // <-- Load BEFORE runApp
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),

    
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/subscribe': (context) => const SubscribeScreen(),
        '/confirm': (context) => const ConfirmScreen(),
      },
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
    
  }
}
