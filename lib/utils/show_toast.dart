import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:todoapp/theme/styles.dart';

enum ToastType {
  error,
  successs,
  info,
}

void showToast({required title, required ToastType type}) {
  switch (type) {
    case ToastType.info:
      toastification.show(
          title: Text(title,
              style: $styles.text.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          autoCloseDuration: const Duration(seconds: 3),
          icon: Icon(MdiIcons.informationVariantBoxOutline));
      break;

    case ToastType.successs:
      toastification.show(
          title: Text(title,
              style: $styles.text.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          autoCloseDuration: const Duration(seconds: 3),
          icon: Icon(MdiIcons.checkCircle));
      break;
    case ToastType.error:
      toastification.show(
          title: Text(title,
              style: $styles.text.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          autoCloseDuration: const Duration(seconds: 3),
          icon: Icon(MdiIcons.alertOctagon));
      break;
  }
}
