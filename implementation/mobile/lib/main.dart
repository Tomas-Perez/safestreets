import 'package:flutter/material.dart';
import 'package:mobile/screens/report_violation_screen.dart';
import 'package:mobile/screens/reports_map_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: TextTheme(
          button: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        primarySwatch: Colors.blue,
      ),
      home: ReportsMapScreen(),
    );
  }
}