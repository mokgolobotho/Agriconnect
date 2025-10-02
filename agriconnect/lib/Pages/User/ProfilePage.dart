import 'package:flutter/material.dart';

import '../../Widgets/AppDrawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, String> profileDetails = {
    "Name": "John Doe",
    "Email": "johndoe@gmail.com",
    "Phone": "+27 123 456 789",
    "Location": "Pretoria, South Africa",
  };

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "icon": Icons.person, "route": "/home"},
    {"title": "Add Farm", "icon": Icons.add_business, "route": "/resources"},
    {"title": "Give Feedback", "icon": Icons.feedback, "route": "/feedback"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User profile"),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: AppDrawer(menuItems: menuItems, currentPage: "Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("*/Assets/profile.png"), // or NetworkImage
            ),
            const SizedBox(height: 20),

            // Profile details
            Column(
              children: profileDetails.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Value
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Edit button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "/editProfile");
              },
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
