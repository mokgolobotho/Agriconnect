import 'package:flutter/material.dart';

import 'Pages/Crop/HarvestedCropsDashboardPage.dart';
import 'Pages/Farm/SensorDetailPage.dart';
import 'Pages/Farm/WeatherAlertsPage.dart';
import 'Pages/Feedback/FeedbackPage.dart';
import 'Pages/User/EditProfilePage.dart';
import 'Pages/User/LoginPage.dart';
import 'Pages/Farm/FarmDetailPage.dart';
import 'Pages/Home/HomePage.dart';
import 'Pages/User/ProfilePage.dart';
import 'Pages/Farm/AddFarmPage.dart';
import 'Pages/Farm/FarmAlertsPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages/User/SplashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: SplashPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/farmDetail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return FarmDetailPage(
            farm_id: int.parse(args["farm_id"]!),
            name: args["name"]!,
            location: args["location"]!,
          );
        },
        '/farmAlerts': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return FarmAlertsPage(
            farmId:  args["farm_id"],
            farmName: args["farm_name"]!,
          );
        },
        '/addFarm': (context) => AddFarmPage(),
        '/sensorData': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SensorDetailPage(
              sensorName: args["sensorName"]!,
              //sensorData: args["sensorData"],
          );
        },
        '/editProfile': (context) => EditProfilePage(),
        '/feedback': (context) =>  FeedbackPage(),
        '/HarvestedCropsDashboardPage': (context) {
          final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          if (args == null || args['farmId'] == null) {
            return Scaffold(
              body: Center(child: Text("No farm selected.")),
            );
          }

          return HarvestedCropsDashboardPage(
            farmId: args['farmId'],
            farmName: args['farmName'] ?? '',
          );
        },

        '/WeatherAlertsPage': (context) {
          final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          if (args == null || args['farmId'] == null) {
            return Scaffold(
              body: Center(child: Text("No farm selected.")),
            );
          }

          return WeatherAlertsPage(
            farmId: args['farmId'],
            farmName: args['farmName'] ?? '',
          );
        },



      },
    );
  }
}

