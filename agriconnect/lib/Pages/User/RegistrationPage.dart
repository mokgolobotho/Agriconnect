import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../Services/api_service.dart';
import '../Home/HomePage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? selectedGender;
  String? selectedTitle;

  bool _isLoading = false;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> titles = ['Mr', 'Mrs', 'Miss', 'Dr', 'Prof', 'Other'];

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?\d{10,15}$'); // Accepts 10-15 digits with optional '+'
    return phoneRegex.hasMatch(phone);
  }

  Future<void> _saveFcmToken(int userId) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await ApiService.saveFcmToken(
        userId: userId,
        fcmToken: fcmToken,
        deviceName: "My Device",
      );
    }
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.registerUser(
      first_name: nameController.text.trim(),
      last_name: surnameController.text.trim(),
      username: emailController.text.trim(),
      email: emailController.text.trim(),
      cellNumber: phoneController.text.trim(),
      password: passwordController.text,
      dob: dobController.text,
      gender: selectedGender!,
      title: selectedTitle!,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final user = result['data']['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user['id']);
      await prefs.setString('token', result['data']['token'] ?? '');
      await _saveFcmToken(user['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registered successfully ✅")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result['error'] ?? 'Unknown error'}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registration Page")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // First Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "First Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Please enter your first name" : null,
                ),
                SizedBox(height: 15),
                // Last Name
                TextFormField(
                  controller: surnameController,
                  decoration: InputDecoration(
                    labelText: "Last Name",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Please enter your last name" : null,
                ),
                SizedBox(height: 15),
                // Phone
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Cellphone Number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter your phone number";
                    if (!RegExp(r'^0\d{9}$').hasMatch(value)) // starts with 0, 10 digits
                      return "Enter a valid 10-digit phone number starting with 0";
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter your email";
                    if (!value.contains('@') || !value.contains('.'))
                      return "Enter a valid email address";
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // DOB picker
                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date of Birth",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Please select your date of birth" : null,
                  onTap: () => _selectDob(context),
                ),
                SizedBox(height: 15),
                // Gender
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  items: genders
                      .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedGender = value),
                  decoration: InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Please select a gender" : null,
                ),
                SizedBox(height: 15),
                // Title
                DropdownButtonFormField<String>(
                  value: selectedTitle,
                  items: titles
                      .map((title) => DropdownMenuItem(value: title, child: Text(title)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedTitle = value),
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Please select a title" : null,
                ),
                SizedBox(height: 15),
                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter a password";
                    if (value.length < 8) return "Password must be at least 8 characters";
                    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Password must contain at least one uppercase letter";
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return "Password must contain at least one special character";
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please confirm your password";
                    if (value != passwordController.text) return "Passwords do not match";
                    return null;
                  },
                ),
                SizedBox(height: 25),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("Register", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
