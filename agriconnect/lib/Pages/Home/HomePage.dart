import 'package:agriconnect/Services/api_service.dart';
import 'package:flutter/material.dart';
import '../../Widgets/FarmCard.dart';
import '../../Widgets/AppDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? userId;
  List<dynamic> userFarms = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Profile", "icon": Icons.person, "route": "/profile"},
    //{"title": "Check Weather", "icon": Icons.cloud, "route": "/crops"},
    {"title": "Add Farm", "icon": Icons.add_business, "route": "/addFarm"},
    {"title": "Give Feedback", "icon": Icons.feedback, "route": "/feedback"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getInt('user_id');

    if (storedId != null) {
      setState(() {
        userId = storedId;
      });

      await _fetchUserFarms(storedId);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserFarms(int id) async {
    try {
      final response = await ApiService.getUserFarms(owner_id: id);

      if (response['success']) {
        setState(() {
          userFarms = response['data']['farms'];
        });
      } else {
        setState(() {
          userFarms = [];
        });
      }
    } catch (e) {
      setState(() {
        userFarms = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: AppDrawer(menuItems: menuItems, currentPage: "Home"),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : userId == null
            ? Center(child: Text("No user logged in"))
            : userFarms.isEmpty
            ? Center(child: Text("No farms found"))
            : ListView.builder(
          itemCount: userFarms.length,
          itemBuilder: (context, index) {
            final farm = userFarms[index];
            return FarmCard(
              farm_id: farm["id"] ?? 0,
              name: farm["name"] ?? "Unknown Farm",
              location: farm["suburb"] ?? "Unknown Location",
            );
          },
        ),
      ),
    );
  }
}
