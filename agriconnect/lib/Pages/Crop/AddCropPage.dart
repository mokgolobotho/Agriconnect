import 'package:flutter/material.dart';
import '../../Services/api_service.dart';

class AddCropPage extends StatefulWidget {
  final int farmId;
  final String farmName;

  const AddCropPage({required this.farmId, required this.farmName, Key? key}) : super(key: key);

  @override
  State<AddCropPage> createState() => _AddCropPageState();
}

class _AddCropPageState extends State<AddCropPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  DateTime? _plantingDate;
  DateTime? _harvestDate;
  bool _isLoading = false;

  Future<void> _pickDate({required bool isPlanting}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPlanting) {
          _plantingDate = picked;
        } else {
          _harvestDate = picked;
        }
      });
    }
  }

  Future<void> _submitCrop() async {
    if (!_formKey.currentState!.validate()) return;

    if (_plantingDate == null || _harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both planting and harvest dates")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.AddCrops(
      farmId: widget.farmId,
      name: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      plantingDate: _plantingDate!.toIso8601String(),
      harvestDate: _harvestDate!.toIso8601String(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['data']['message'] ?? "Crop added successfully")),
      );
      Navigator.pop(context, true); // Return true to refresh the farm crop list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['data']['error'] ?? "Failed to add crop")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Crop - ${widget.farmName}"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Crop Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Enter crop name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Quantity",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Enter quantity" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isPlanting: true),
                        child: Text(_plantingDate == null
                            ? "Select Planting Date"
                            : "Planting: ${_plantingDate!.toLocal().toString().split(' ')[0]}"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isPlanting: false),
                        child: Text(_harvestDate == null
                            ? "Select Harvest Date"
                            : "Harvest: ${_harvestDate!.toLocal().toString().split(' ')[0]}"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitCrop,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Crop", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
