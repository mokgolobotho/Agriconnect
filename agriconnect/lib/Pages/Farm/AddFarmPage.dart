import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../Services/api_service.dart';
import '../Home/HomePage.dart';

class AddFarmPage extends StatefulWidget {
  const AddFarmPage({Key? key}) : super(key: key);

  @override
  State<AddFarmPage> createState() => _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  int userId = 0;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _suburbController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _approxSizeController = TextEditingController();

  double latitude = 0.0;
  double longitude = 0.0;
  bool _loadingLocation = false;
  bool _submitting = false;

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

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _getLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _loadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      _loadingLocation = false;
    });
  }

  Future<void> _submitFarm() async {
    if (!_formKey.currentState!.validate()) return;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please get your farm’s location first')),
      );
      return;
    }

    setState(() => _submitting = true);

    final response = await ApiService.AddFarm(
      owner_id : userId,
      name : _nameController.text,
      suburb : _suburbController.text,
      city : _cityController.text,
      province : _provinceController.text,
      country : _countryController.text,
      code : int.parse(_codeController.text),
      latitude : latitude,
      longitude : longitude,
      length : double.parse(_lengthController.text),
      width : double.parse(_widthController.text),
      approximate_size : double.parse(_lengthController.text) * double.parse(_widthController.text),
    );

    setState(() => _submitting = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Farm added successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add farm: ${response['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Farm")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Farm Name"),
                validator: (value) =>
                value!.isEmpty ? "Please enter farm name" : null,
              ),
              TextFormField(
                controller: _suburbController,
                decoration: InputDecoration(labelText: "Suburb"),
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City"),
              ),
              TextFormField(
                controller: _provinceController,
                decoration: InputDecoration(labelText: "Province"),
              ),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: "Country"),
              ),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Postal Code"),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadingLocation ? null : _getLocation,
                      icon: Icon(Icons.location_on),
                      label: Text(_loadingLocation
                          ? "Getting Location..."
                          : "Get Location"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (latitude != null && longitude != null)
                Text(
                  "📍 Latitude: $latitude, Longitude: $longitude",
                  style: TextStyle(color: Colors.green),
                ),
              SizedBox(height: 10),
              TextFormField(
                controller: _lengthController,
                decoration: InputDecoration(labelText: "Length (m)"),
              ),
              TextFormField(
                controller: _widthController,
                decoration: InputDecoration(labelText: "Width (m)"),
              ),
              TextFormField(
                controller: _approxSizeController,
                decoration: InputDecoration(labelText: "Approximate Size (m²)"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submitFarm,
                child: Text(_submitting ? "Submitting..." : "Add Farm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
