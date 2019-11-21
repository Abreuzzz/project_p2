import 'package:flutter/material.dart';
import 'package:project_p2/theme/themes.dart';
import 'package:project_p2/ui/home_screen.dart';

void main()=> runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TextsPage(),
      title: "DuNtpad",
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
    );
  }
}