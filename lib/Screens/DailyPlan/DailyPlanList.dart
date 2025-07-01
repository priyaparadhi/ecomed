import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/DailyPlanModel.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyPlanPage extends StatefulWidget {
  const DailyPlanPage({super.key});

  @override
  State<DailyPlanPage> createState() => _DailyPlanPageState();
}

class _DailyPlanPageState extends State<DailyPlanPage> {
  DateTime _selectedDate = DateTime.now();

  List<DailyPlan> _plans = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchDailyPlans();
  }

  Future<void> _fetchDailyPlans() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final fetchedPlans = await ApiCalls.fetchDailyPlans(
        planDate: formattedDate,
        userId: userId,
        userFilter: null,
        statusId: null,
      );

      setState(() => _plans = fetchedPlans);
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load daily plans")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAchievement(int index, String achievementText) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    final plan = _plans[index];

    final success = await ApiCalls.updateDailyPlanAchievement(
      planId: plan.planId,
      achievements: achievementText,
      createdBy: userId,
    );

    if (success) {
      setState(() {
        _plans[index].achievements = achievementText;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Achievement updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update achievement")),
      );
    }
  }

  void _showAchievementDialog(int index) {
    final controller = TextEditingController(
      text: _plans[index].achievements, // ✅ use property, not map key
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Add / Update Achievement",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter achievement...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _updateAchievement(index, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange; // Pending
      case 2:
        return Colors.red; // Not Done
      case 3:
        return Colors.green; // Done
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(int? statusId) {
    switch (statusId) {
      case 1:
        return "Pending";
      case 2:
        return "Not Done";
      case 3:
        return "Done";
      default:
        return "Unknown";
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4, // Improves spacing for multi-line text
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Plans"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Date Picker
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: DatePicker(
              DateTime.now().subtract(const Duration(days: 30)),
              initialSelectedDate: _selectedDate,
              selectionColor: Colors.blueAccent,
              selectedTextColor: Colors.white,
              daysCount: 60,
              dateTextStyle: const TextStyle(fontSize: 16),
              dayTextStyle: const TextStyle(fontSize: 12),
              monthTextStyle: const TextStyle(fontSize: 12),
              onDateChange: (date) {
                setState(() => _selectedDate = date);
                _fetchDailyPlans();
              },
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _plans.isEmpty
                    ? const Center(
                        child: Text(
                          "No plans available for this date.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date at top
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        plan.planDate,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blueGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(plan.statusId)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _getStatusLabel(plan.statusId),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                _getStatusColor(plan.statusId),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  // User row
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blueAccent,
                                        child: const Icon(Icons.person,
                                            color: Colors.white, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          plan.userName ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(
                                      "Task Name", plan.taskName ?? 'N/A'),
                                  _buildDetailRow("Plan", plan.planName),

                                  _buildDetailRow(
                                      "Comment", plan.comments ?? 'N/A'),
                                  _buildDetailRow(
                                      "Location", plan.location ?? 'N/A'),

                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => const AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 16),
                                              Expanded(
                                                  child: Text(
                                                      "Verifying location...")),
                                            ],
                                          ),
                                        ),
                                      );

                                      final currentPosition =
                                          await _getCurrentLocation();
                                      if (currentPosition == null) {
                                        Navigator.pop(
                                            context); // Close the loader
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Location not available.")),
                                        );
                                        return;
                                      }

                                      final planLatLng =
                                          await _getLatLngFromAddress(
                                              plan.location ?? 'N/A');
                                      if (planLatLng == null) {
                                        Navigator.pop(
                                            context); // Close the loader
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Unable to resolve plan location.")),
                                        );
                                        return;
                                      }

                                      final distanceInMeters =
                                          Geolocator.distanceBetween(
                                        currentPosition.latitude,
                                        currentPosition.longitude,
                                        planLatLng.latitude,
                                        planLatLng.longitude,
                                      );

                                      Navigator.pop(
                                          context); // Close the loader

                                      if (distanceInMeters <= 100) {
                                        _showAchievementDialog(
                                            index); // ✅ Allow editing
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "You are not within 100 meters of the plan location."),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blueAccent
                                              .withOpacity(0.4),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.emoji_events,
                                            size: 18,
                                            color: Colors.blueAccent,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              plan.achievements.isEmpty
                                                  ? "Add your achievement..."
                                                  : plan.achievements,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontStyle:
                                                    plan.achievements.isEmpty
                                                        ? FontStyle.italic
                                                        : FontStyle.normal,
                                                color: plan.achievements.isEmpty
                                                    ? Colors.grey
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

Future<Position?> _getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

Future<LatLng?> _getLatLngFromAddress(String address) async {
  try {
    final locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {
    debugPrint("Geocoding failed: $e");
  }
  return null;
}

class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}
