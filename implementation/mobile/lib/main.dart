import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.blue,
            ),
            button: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            subhead: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          ),
          appBarTheme: AppBarTheme(
              color: Colors.white,
              iconTheme: IconThemeData(color: Colors.blue),
              textTheme: TextTheme(
                title: TextStyle(
                    fontFamily: "ComicSans",
                    color: Colors.blue,
                    fontSize: 20.0),
              )),
          primarySwatch: Colors.blue,
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 1,
          )),
      home: HomeScreen(),
    );
  }
}
