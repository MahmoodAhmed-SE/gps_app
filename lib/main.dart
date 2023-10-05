import 'package:flutter/material.dart';
import 'package:gps_app/screens/homepage.dart';

void main() {
  runApp(const GpsApp());
}

class GpsApp extends StatelessWidget {
  const GpsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Homepage(title: 'GPS App homepage'),
    );
  }
}

