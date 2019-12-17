import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/report_violation_screen.dart';
import 'package:mobile/screens/reports_map_screen.dart';
import 'package:mobile/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: safeStreetsTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) => HomeScreen(),
        '/map': (ctx) => ReportsMapScreen(),
        '/report': (ctx) => ReportViolationScreen(),
      },
    );
  }
}
