import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:todoapp/controllers/auth_contoller.dart';
import 'package:todoapp/theme/styles.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder(
        init: AuthController.to,
        builder: (authController) {
          return Center(
            child: authController.isloadingAuth.value
                ? SpinKitThreeBounce(
                    color: $styles.colors.black,
                    size: 40,
                  )
                : SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Column(
                          children: [
                            Text("Smokeless ToDo", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
                            Text(
                              "by Irene",
                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        const Spacer(),
                        const Text("sign in",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            )),
                        const SizedBox(height: 24),
                        SignInButton(
                          Buttons.google,
                          onPressed: () {
                            log("want to sign in with google");
                            authController.signInWithGoogle().then((value) {
                              log("sign in page:signed in with google as ${value.user?.displayName}");
                            }).catchError((error, stacktrace) {
                              log("Error signing in with google:$error\n$stacktrace");
                            });
                            log("yay 2!");
                          },
                        ),
                        const Spacer(),
                        const SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
