import 'package:flutter/material.dart';

import 'Pages/Farm/SensorDetailPage.dart';
import 'Pages/User/EditProfilePage.dart';
import 'Pages/User/LoginPage.dart';
import 'Pages/Farm/FarmDetailPage.dart';
import 'Pages/Home/HomePage.dart';
import 'Pages/User/ProfilePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agriconnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // start at login page
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/farmDetail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return FarmDetailPage(
            name: args["name"]!,
            location: args["location"]!,
          );
        },
        '/sensorData': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SensorDetailPage(
              sensorName: args["sensorName"]!,
              //sensorData: args["sensorData"],
          );
        },
        '/editProfile': (context) => EditProfilePage(),
      },
    );
  }
}

