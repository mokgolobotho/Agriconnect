import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/api_service.dart';
import '../../Widgets/AppDrawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool isLoading = true;

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "icon": Icons.home, "route": "/home"},
    {"title": "Add Farm", "icon": Icons.add_business, "route": "/addFarm"},
    {"title": "Give Feedback", "icon": Icons.feedback, "route": "/feedback"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.getUserProfile(userId: userId);
      if (response['success']) {
        setState(() {
          profile = response['data'];
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: AppDrawer(menuItems: menuItems, currentPage: "Profile"),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profile == null
          ? Center(child: Text("Failed to load profile"))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: profile!['photo'] != null
                  ? NetworkImage(profile!['photo'])
                  : AssetImage("assets/profile.png") as ImageProvider,
            ),
            SizedBox(height: 20),
            Column(
              children: [
                // Title at the top
                _buildRow("Title", profile!['title'] ?? ""),
                _buildRow("Name", "${profile!['first_name']}"),
                _buildRow("Surname", profile!['last_name'] ?? ""),
                _buildRow("Email", profile!['email'] ?? ""),
                _buildRow("Phone", profile!['cell_number'] ?? ""),
                _buildRow("Gender", profile!['gender'] ?? ""),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "/editProfile")
                    .then((_) => _fetchProfile());
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

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
