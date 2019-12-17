import 'package:flutter/material.dart';

final safeStreetsTheme = ThemeData(
  textTheme: const TextTheme(
    title: TextStyle(
      color: Colors.blue,
    ),
    button: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blue,
    textTheme: ButtonTextTheme.primary,
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.white,
    iconTheme: IconThemeData(color: Colors.blue),
    textTheme: TextTheme(
      title: TextStyle(
          fontFamily: "ComicSans", color: Colors.blue, fontSize: 20.0),
    ),
  ),
  primarySwatch: Colors.blue,
  cardTheme: const CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    clipBehavior: Clip.antiAlias,
    elevation: 1,
  ),
);
