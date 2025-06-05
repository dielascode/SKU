import 'package:flutter/material.dart';
import 'package:penempuhan_upgradeview/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false, // Setel properti ini menjadi false
      home: HomePage(),
    );
  }
}