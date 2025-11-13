import 'package:flutter/material.dart';
import '../../Services/api_service.dart';

class CropAlertsPage extends StatefulWidget {
  final int cropId;
  final String cropName;

  const CropAlertsPage({
    Key? key,
    required this.cropId,
    required this.cropName,
  }) : super(key: key);

  @override
  State<CropAlertsPage> createState() => _CropAlertsPageState();
}

class _CropAlertsPageState extends State<CropAlertsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> alerts = [];

  @override
  void initState() {
    super.initState();
    _fetchCropAlerts();
  }

  Future<void> _fetchCropAlerts() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.getCropRecommendations(cropId: widget.cropId);

      if (response['success'] == true && response['records'] != null) {
        final records = List<Map<String, dynamic>>.from(response['records']);

        setState(() {
          // Map each record to an alert
          alerts = records.map((record) {
            return {
              "crop_name": record['crop_name'] ?? widget.cropName,
              "fertility_level": record['fertility_level'],
              "recommendations": List<String>.from(record['recommendations'] ?? []),
              "created_at": record['created_at'] ?? DateTime.now().toIso8601String(),
            };
          }).toList();

          // ✅ Sort by fertility level (Low → Moderate → High) and then by recent date
          final fertilityOrder = {"Low": 0, "Moderate": 1, "High": 2};
          alerts.sort((a, b) {
            int levelCompare = (fertilityOrder[a['fertility_level']] ?? 3)
                .compareTo(fertilityOrder[b['fertility_level']] ?? 3);
            if (levelCompare != 0) return levelCompare; // sort by fertility level first

            // If fertility level is the same, sort by created_at descending (most recent first)
            DateTime dateA = DateTime.parse(a['created_at']);
            DateTime dateB = DateTime.parse(b['created_at']);
            return dateB.compareTo(dateA);
          });

          isLoading = false;
        });
      } else {
        throw Exception(response['error'] ?? 'Failed to load the alerts');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching alerts: $e')),
        );
      }
    }
  }


  String _formatDate(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.cropName} Alerts"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
          ? const Center(
        child: Text(
          "✅ No fertility alerts in the last 24 hours.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchCropAlerts,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];

            // ✅ Ensure recommendations is a List<String>
            List<String> recommendations = [];
            if (alert['recommendations'] != null &&
                alert['recommendations'] is List) {
              recommendations = (alert['recommendations'] as List)
                  .map((e) => e.toString())
                  .toList();
            }

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.warning,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            alert['crop_name'] ?? 'Unknown Crop',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fertility Level: ${alert['fertility_level'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    if (recommendations.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recommendations:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            ...recommendations
                                .map((rec) => Text("• $rec"))
                                .toList(),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      "📅 ${_formatDate(alert['created_at'])}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
