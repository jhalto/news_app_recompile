import 'package:flutter/material.dart';
import 'package:news_app_recompile/screens/home_page.dart';
import 'package:news_app_recompile/screens/widgets/common_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title:'jhalto',

      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black26
        ),
        scaffoldBackgroundColor: backgroundClr
      ),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
