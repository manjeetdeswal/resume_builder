import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resume_builder/providers/resume_provider.dart';
import 'package:resume_builder/screens/editor_screen.dart';
import 'package:resume_builder/screens/home_screen.dart';
import 'package:resume_builder/screens/template_search_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ResumeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume  Builder',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
