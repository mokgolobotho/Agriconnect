import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for profile details
  final TextEditingController _nameController =
  TextEditingController(text: "John Doe");
  final TextEditingController _emailController =
  TextEditingController(text: "johndoe@gmail.com");
  final TextEditingController _phoneController =
  TextEditingController(text: "+27 123 456 789");
  final TextEditingController _locationController =
  TextEditingController(text: "Pretoria, South Africa");

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File tempImage = File(pickedFile.path);

      // Save image to local storage
      final directory = await getApplicationDocumentsDirectory();
      final String path = directory.path;
      final String fileName = basename(pickedFile.path);
      final File localImage = await tempImage.copy('$path/$fileName');

      setState(() {
        _profileImage = localImage;
      });
    }
  }

  Future<void> _loadSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/profile.jpg');
    if (await file.exists()) {
      setState(() {
        _profileImage = file;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Save image permanently as "profile.jpg"
      if (_profileImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final savedImage = await _profileImage!.copy('${directory.path}/profile.jpg');
        setState(() {
          _profileImage = savedImage;
        });
      }


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage("Assets/profile.png") as ImageProvider,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                value!.isEmpty ? "Please enter your name" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                value!.isEmpty ? "Please enter your email" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                validator: (value) =>
                value!.isEmpty ? "Please enter your phone number" : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              const SizedBox(height: 30),

              // Save button
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
