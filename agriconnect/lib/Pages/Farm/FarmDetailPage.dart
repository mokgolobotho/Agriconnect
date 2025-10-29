import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Services/api_service.dart';
import '../../Widgets/AppDrawer.dart';
import '../Crop/CropDashboardPage.dart';
import '../Crop/AddCropPage.dart'; // ✅ import the AddCropPage

class FarmDetailPage extends StatefulWidget {
  final String name;
  final String location;
  final int farm_id;

  const FarmDetailPage({
    required this.name,
    required this.location,
    required this.farm_id,
    Key? key,
  }) : super(key: key);

  @override
  State<FarmDetailPage> createState() => _FarmDetailPageState();
}

class _FarmDetailPageState extends State<FarmDetailPage> {
  bool isLoading = true;
  List<dynamic> crops = [];

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "icon": Icons.home, "route": "/home"},
    {"title": "Add Crop", "icon": Icons.grass, "route": "/crops"},
    {"title": "Resource list", "icon": Icons.list_alt, "route": "/resources"},
    {"title": "Give Feedback", "icon": Icons.feedback, "route": "/feedback"},
    {"title": "Logout", "icon": Icons.logout, "route": "/login"},
  ];

  @override
  void initState() {
    super.initState();
    fetchFarmCrops(widget.farm_id);
  }

  Future<void> fetchFarmCrops(int farm_id) async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getFarmCrops(farm_id: farm_id);

      if (response['success']) {
        setState(() {
          crops = response['data']['crops'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load crops ");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading crops: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      drawer: AppDrawer(menuItems: menuItems, currentPage: "farmDetail"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Location: ${widget.location}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),

            const Text(
              "🌾 Crops",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : crops.isEmpty
                  ? const Center(child: Text("No crops found for this farm."))
                  : ListView.builder(
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CropDashboardPage(
                            cropId: crop['id'],
                            cropName: crop['name'] ?? 'Unnamed Crop',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.grass, color: Colors.white),
                        ),
                        title: Text(
                          crop['name'] ?? 'Unknown Crop',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text("Type: ${crop['type'] ?? 'N/A'}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to AddCropPage and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCropPage(
                farmId: widget.farm_id,
                farmName: widget.name,
              ),
            ),
          );

          // If a crop was added, refresh the crop list
          if (result == true) {
            fetchFarmCrops(widget.farm_id);
          }
        },
        label: const Text("Add Crop"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}
