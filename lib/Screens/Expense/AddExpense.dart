import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class ExpenseClaimPage extends StatefulWidget {
  @override
  _ExpenseClaimPageState createState() => _ExpenseClaimPageState();
}

class _ExpenseClaimPageState extends State<ExpenseClaimPage> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  String? selectedMode;
  String? selectedBillType;
  File? selectedBillFile;

  final List<String> modes = ['Car', 'Bike', 'Bus', 'Train', 'Walk'];
  final List<String> billTypes = ['Travel', 'Food', 'Other'];

  double distanceInKm = 0;
  double ratePerKm = 2.3;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> calculateDistance() async {
    final from = fromController.text.trim();
    final to = toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      showSnack('Please enter both From and To locations');
      return;
    }

    try {
      List<Location> fromLocations = await locationFromAddress(from);
      List<Location> toLocations = await locationFromAddress(to);

      if (fromLocations.isNotEmpty && toLocations.isNotEmpty) {
        final distance = Geolocator.distanceBetween(
              fromLocations.first.latitude,
              fromLocations.first.longitude,
              toLocations.first.latitude,
              toLocations.first.longitude,
            ) /
            1000;

        setState(() {
          distanceInKm = double.parse(distance.toStringAsFixed(2));
          totalAmount =
              double.parse((distanceInKm * ratePerKm).toStringAsFixed(2));
        });

        showSnack('Distance calculated: $distanceInKm km');
      } else {
        showSnack('Could not find valid locations');
      }
    } catch (e) {
      showSnack('Error calculating distance');
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedBillFile = File(result.files.single.path!);
      });
    }
  }

  void submitForm() {
    if (fromController.text.isEmpty ||
        toController.text.isEmpty ||
        selectedMode == null ||
        selectedBillType == null) {
      showSnack('Please fill all required fields');
      return;
    }

    showSnack('Expense submitted successfully!');
  }

  void clearForm() {
    setState(() {
      fromController.clear();
      toController.clear();
      descriptionController.clear();
      dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      selectedMode = null;
      selectedBillType = null;
      selectedBillFile = null;
      distanceInKm = 0;
      totalAmount = 0;
    });
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Expense Claim"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: clearForm,
            tooltip: 'Clear Form',
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _cardSection(
            title: "Basic Details",
            children: [
              _dateField(),
              _textField("From Location", fromController, Icons.location_on),
              _textField(
                  "To Location", toController, Icons.location_on_outlined),
              _dropdownField(
                  "Mode of Transport",
                  modes,
                  selectedMode,
                  (val) => setState(() => selectedMode = val),
                  Icons.directions_car),
              _dropdownField(
                  "Bill Type",
                  billTypes,
                  selectedBillType,
                  (val) => setState(() => selectedBillType = val),
                  Icons.receipt),
            ],
          ),
          _cardSection(
            title: "Upload Bill",
            children: [
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: Icon(Icons.attach_file),
                label: Text("Choose File"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade200,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 8),
              if (selectedBillFile != null)
                Text(
                  selectedBillFile!.path.split('/').last,
                  style: TextStyle(color: Colors.black87),
                ),
            ],
          ),
          _cardSection(
            title: "Distance & Fare",
            children: [
              ElevatedButton.icon(
                onPressed: calculateDistance,
                icon: Icon(Icons.calculate),
                label: Text("Calculate Fare"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 10),
              if (distanceInKm > 0)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Distance: $distanceInKm km"),
                      Text("Rate: ₹$ratePerKm per km"),
                      Text(
                        "Total Fare: ₹$totalAmount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          _cardSection(
            title: "Work Description",
            children: [
              _textField(
                  "Enter Description", descriptionController, Icons.description,
                  maxLines: 3),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: submitForm,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                child: Text("Submit", style: TextStyle(fontSize: 16)),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSection({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple)),
            SizedBox(height: 12),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _textField(
      String hint, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: dateController,
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2023),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() {
              dateController.text = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          labelText: "Date",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
