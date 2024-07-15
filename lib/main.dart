import 'package:biblos/src/home.dart';
import 'package:biblos/src/services/ls.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => AppWidgetState();
}

class AppWidgetState extends State<MyApp> {
  AppDataClass appData = AppDataClass();

  @override
  void initState() {
    appData.initialize();
    super.initState();
  }

  static AppWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppWidgetState>();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblos',
      theme: currentTheme,
      home: const HomePage(title: 'Biblos'),
    );
  }
}
