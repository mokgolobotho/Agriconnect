import 'package:flutter/material.dart';
import '../../Services/api_service.dart';
import '../Crop/CropDashboardPage.dart';

class HarvestedCropsDashboardPage extends StatefulWidget {
  final int farmId;
  final String farmName;

  const HarvestedCropsDashboardPage({
    Key? key,
    required this.farmId,
    required this.farmName,
  }) : super(key: key);

  @override
  State<HarvestedCropsDashboardPage> createState() =>
      _HarvestedCropsDashboardPageState();
}

class _HarvestedCropsDashboardPageState
    extends State<HarvestedCropsDashboardPage> {
  bool isLoading = true;
  List<dynamic> harvestedCrops = [];

  @override
  void initState() {
    super.initState();
    _fetchHarvestedCrops();
  }

  Future<void> _fetchHarvestedCrops() async {
    setState(() => isLoading = true);
    try {
      final response =
      await ApiService.getFarmHarvestedCrops(farm_id: widget.farmId);

      if (response['success'] == true && response['data']['crops'] != null) {
        setState(() {
          harvestedCrops = response['data']['crops'];
          isLoading = false;
        });
      } else {
        setState(() {
          harvestedCrops = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching harvested crops: $e")),
      );
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.farmName} - Harvested Crops"),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // ✅ simple back button
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🌾 Harvested Crops",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : harvestedCrops.isEmpty
                  ? const Center(
                child: Text("No harvested crops found."),
              )
                  : ListView.builder(
                itemCount: harvestedCrops.length,
                itemBuilder: (context, index) {
                  final crop = harvestedCrops[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CropDashboardPage(
                            cropId: crop['id'],
                            cropName:
                            crop['name'] ?? 'Unknown Crop',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      margin:
                      const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.grass,
                              color: Colors.white),
                        ),
                        title: Text(
                          crop['name'] ?? 'Unknown Crop',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Type: ${crop['type'] ?? 'N/A'}\n"
                              "Harvested: ${_formatDate(crop['harvest_date'])}",
                        ),
                        trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
