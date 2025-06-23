import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetInternet extends GetxController {
  Connectivity connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    connectivity.onConnectivityChanged.listen(NetConnectivityResult);
  }

  NetConnectivityResult(List<ConnectivityResult> cr) {
    if (cr.contains(ConnectivityResult.none)) {
      Get.rawSnackbar(
        shouldIconPulse: true,
        titleText: Text(
          "No Internet Connection",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        messageText: Text(
          "Please check your connection and try again.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        icon: Icon(
          Icons.wifi_off_rounded,
          color: Colors.white,
          size: 28,
        ),
        isDismissible: true,
        backgroundColor: Colors.orangeAccent.shade400,
        duration: Duration(seconds: 5),
        borderRadius: 12,
        margin: EdgeInsets.all(15),
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
