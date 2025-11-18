import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/api_service.dart';

class AppDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final String currentPage;

  const AppDrawer({
    Key? key,
    required this.menuItems,
    required this.currentPage,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      final response = await ApiService.logoutUser(); // API call to deactivate device

      // Clear cache
      await prefs.clear();

      Navigator.pop(context); // Close loading dialog

      if (response['success'] == true) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Logout failed")),
        );
      }
    } else {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              "AgriConnect Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: Icon(item["icon"] as IconData),
                  title: Text(item["title"] as String),
                  selected: currentPage == item["title"],
                  onTap: () {
                    Navigator.pop(context);
                    if (currentPage != item["title"]) {
                      if (item.containsKey("onTap")) {
                        item["onTap"]();
                      } else if (item.containsKey("route")) {
                        Navigator.pushReplacementNamed(
                            context, item["route"] as String);
                      }
                    }
                  },
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout"),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
