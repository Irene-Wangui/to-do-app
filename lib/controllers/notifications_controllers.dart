import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:todoapp/utils/show_toast.dart';

class NotificationsController extends GetxController {
  static NotificationsController get to => Get.find();
  final isloadingAuth = true.obs;
  @override
  void onInit() {
    super.onInit();
    log('notifications contrioller initialized');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
    checkNotificationPermissions();
  }

  Future<void> checkNotificationPermissions() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      log("Permission: Denied");
      showToast(title: 'Notification permission denied', type: ToastType.error);

      final result = await Permission.notification.request();
      if (result.isGranted) {
        log("Permission: Granted after request");
      } else {
        log("Permission: Still denied after request");
      }
    } else if (status.isGranted) {
      log("Permission: Granted");
    } else if (status.isPermanentlyDenied) {
      log("Permission: Permanently Denied");
      showToast(title: 'Notification permission permanently denied', type: ToastType.error);
      openAppSettings(); // Optionally open settings
    } else if (status.isRestricted) {
      log("Permission: Restricted");
    } else if (status.isLimited) {
      log("Permission: Limited");
    }
  }

  @pragma('vm:entry-point')
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    log("Handling a background message: ${message.messageId}");
  }
}
