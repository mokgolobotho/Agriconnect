import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final String currentPage;

  const AppDrawer({
    Key? key,
    required this.menuItems,
    required this.currentPage,
  }) : super(key: key);

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
                      Navigator.pushReplacementNamed(
                          context, item["route"] as String);
                    }
                  },
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
