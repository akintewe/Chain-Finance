import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'colors.dart';

class Loader {
  static void show() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.secondary,
            size: 50,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
} 