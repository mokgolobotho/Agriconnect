import 'package:flutter/material.dart';
import '../Pages/Farm/FarmDetailPage.dart';

class FarmCard extends StatelessWidget {
  final String name;
  final String location;

  const FarmCard({
    required this.name,
    required this.location,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.agriculture, size: 40, color: Colors.green),
        title: Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(location),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FarmDetailPage(
                name: name,
                location: location,
              ),
            ),
          );
        },
      ),
    );
  }
}
