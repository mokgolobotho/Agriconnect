import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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

  // 🔹 Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _suburbController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();

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
    }

    setState(() {
      isLoading = false;
    });
  }

  /// 🌍 Get GPS + address details
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
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _loadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return;
    }

    // ✅ Get coordinates
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    // ✅ Reverse geocode to get address details
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String suburb = place.subLocality ?? '';
        String city = place.locality ?? '';
        String province = place.administrativeArea ?? '';
        String country = place.country ?? '';
        String postalCode = place.postalCode ?? '';

        // Fix missing suburb/city logic
        if (suburb.isEmpty && city.isNotEmpty && city != province) {
          suburb = city;
        } else if (suburb.isEmpty && province.isNotEmpty && city.isEmpty) {
          city = province;
        }
        if (city == province && place.subAdministrativeArea != null) {
          city = place.subAdministrativeArea!;
        }

        setState(() {
          _suburbController.text = suburb;
          _cityController.text = city;
          _provinceController.text = province;
          _countryController.text = country;
          _codeController.text = postalCode;
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
    }

    setState(() {
      _loadingLocation = false;
    });
  }

  /// 🧾 Submit farm to backend
  Future<void> _submitFarm() async {
    if (!_formKey.currentState!.validate()) return;

    if (latitude == 0.0 || longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get your farm’s location first')),
      );
      return;
    }

    setState(() => _submitting = true);

    double length = double.tryParse(_lengthController.text) ?? 0.0;
    double width = double.tryParse(_widthController.text) ?? 0.0;
    double approximateSize = length * width;

    final response = await ApiService.AddFarm(
      owner_id: userId,
      name: _nameController.text,
      suburb: _suburbController.text,
      city: _cityController.text,
      province: _provinceController.text,
      country: _countryController.text,
      code: int.tryParse(_codeController.text) ?? 0,
      latitude: latitude,
      longitude: longitude,
      length: length,
      width: width,
      approximate_size: approximateSize, // ✅ sent automatically
    );

    setState(() => _submitting = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm added successfully!')),
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
      appBar: AppBar(
        title: const Text("Add Farm"),
        backgroundColor: Colors.green.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                const InputDecoration(labelText: "Farm Name"),
                validator: (value) =>
                value!.isEmpty ? "Please enter farm name" : null,
              ),
              TextFormField(
                controller: _suburbController,
                decoration: const InputDecoration(labelText: "Suburb"),
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),
              TextFormField(
                controller: _provinceController,
                decoration:
                const InputDecoration(labelText: "Province"),
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: "Country"),
              ),
              TextFormField(
                controller: _codeController,
                decoration:
                const InputDecoration(labelText: "Postal Code"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadingLocation ? null : _getLocation,
                      icon: const Icon(Icons.location_on),
                      label: Text(_loadingLocation
                          ? "Getting Location..."
                          : "Get Location"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (latitude != 0.0 && longitude != 0.0)
                Text(
                  "📍 Latitude: $latitude, Longitude: $longitude",
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lengthController,
                decoration:
                const InputDecoration(labelText: "Length (m)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _widthController,
                decoration:
                const InputDecoration(labelText: "Width (m)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submitFarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _submitting ? "Submitting..." : "Add Farm",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
