import 'package:flutter/material.dart';
import '../../Widgets/FarmCard.dart';
import '../../Widgets/AppDrawer.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> farms = [
    {"name": "Sunrise Farm", "location": "Gauteng"},
    {"name": "Green Valley", "location": "KwaZulu-Natal"},
    {"name": "Happy Fields", "location": "Western Cape"},
    {"name": "Strawberry Fields", "location": "Limpopo"},
  ];
  final List<Map<String, dynamic>> menuItems = [
    {"title": "Profile", "icon": Icons.person, "route": "/profile"},
    {"title": "Check Weather", "icon": Icons.cloud, "route": "/crops"},
    {"title": "Add Farm", "icon": Icons.add_business, "route": "/resources"},
    {"title": "Previous Alerts", "icon": Icons.add_alert, "route": "/resources"},
    {"title": "Give Feedback", "icon": Icons.feedback, "route": "/feedback"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: AppDrawer( menuItems: menuItems,
        currentPage: "Home"),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: farms.length,
          itemBuilder: (context, index) {
            return FarmCard(
              name: farms[index]["name"]!,
              location: farms[index]["location"]!,
            );
          },
        ),
      ),
    );
  }
}
