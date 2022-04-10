import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login.dart';

_initFltterFire() async {
  return await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDMc6mZkKXPQ2mXpv-IbGqcfvG0voJzY1U",
        appId: "...",
        messagingSenderId: "...",
        projectId: "..."),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux) {
    _initFltterFire();
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MainWindow());
}

class MainWindow extends StatelessWidget {
  const MainWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
