import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:todoapp/Pages/sign_in_page.dart';
import 'package:todoapp/controllers/auth_contoller.dart';

import 'package:todoapp/firebase_options.dart';
import 'package:todoapp/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(AuthController(), permanent: true);
    return GetMaterialApp(title: 'ToDoApp', theme: lightTheme, darkTheme: darkTheme, home: SignInPage());
  }
}
