import 'package:ecomed/Screens/Authentication/loginPage.dart';
import 'package:ecomed/Screens/DashBoardScreen.dart';
import 'package:ecomed/Screens/UserDashboardScreen.dart';
import 'package:ecomed/Services/Internet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(GetInternet());

    return GetMaterialApp(
        title: 'EcoMed',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => LoginPage()),
          GetPage(name: '/home', page: () => HRDashboardScreen()),
        ]);
  }
}
