// import 'dart:html';
// import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:dartpy/dartpy_annotations.dart';
import 'package:memory_aid/record_page.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Aid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RecordPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}