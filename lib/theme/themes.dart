import 'package:flutter/material.dart';

final ThemeData kIOSTheme = ThemeData(
  primaryColor: Color.fromARGB(255, 63, 81, 181),
  primaryColorLight: Color.fromARGB(255, 197, 202, 233),
  primaryColorDark: Color.fromARGB(255, 48, 63, 159),
  accentColor: Color.fromARGB(255, 255, 82, 82),
  dividerColor: Color.fromARGB(255, 189, 189, 189),
);

final ThemeData kDefaultTheme = ThemeData(
  primaryColor: Color.fromARGB(255, 63, 81, 181),
  primaryColorLight: Color.fromARGB(255, 197, 202, 233),
  primaryColorDark: Color.fromARGB(255, 48, 63, 159),
  accentColor: Color.fromARGB(255, 255, 82, 82),
  dividerColor: Color.fromARGB(255, 189, 189, 189),
  textTheme: kTextTheme,

  /*primaryColor: Colors.red[900],
  primaryColorLight: Colors.red[600],
  textSelectionColor: Colors.red[200],
  textSelectionHandleColor: Colors.red[200],
  cursorColor: Colors.red[900],
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: Colors.red[900]),
  textTheme: kTextTheme, // Color texts
  iconTheme: kIconTheme, // Color statusMessage
  accentIconTheme: kIconAccentTheme, // Secundary color of status
  cardColor: Colors.white, // Background BottomNavigationBar
  hintColor: Colors.grey[600], // Details of all TextField
*/
);

final TextTheme kTextTheme = TextTheme(
  title: TextStyle(
    color: Color.fromARGB(255, 255, 255, 255),
  ),
  body1: TextStyle(
    color: Color.fromARGB(255, 33, 33, 33),
  ),
  body2: TextStyle(
    color: Color.fromARGB(255, 117, 117, 117),
  ),

/*
    display1: TextStyle(color: Colors.white, fontSize: 20.0), //TextField do Search
    subhead: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 15.0),
    body1: TextStyle(color: Colors.black, fontSize: 15.0),
    button: TextStyle(color: Colors.lightBlue, fontSize: 15.0),
    overline: TextStyle(color: Colors.grey[800], fontSize: 10.0)
    */
);

final IconThemeData kIconTheme = IconThemeData(
  color: Color.fromARGB(255, 197, 202, 233),
    );

final IconThemeData kIconAccentTheme = IconThemeData(
/*
  color: Colors.redAccent,
*/
    );
