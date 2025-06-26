import 'package:dropdown_search/dropdown_search.dart';
import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/DailyPlanModel.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyPlanPageForAdmin extends StatefulWidget {
  const DailyPlanPageForAdmin({super.key});

  @override
  State<DailyPlanPageForAdmin> createState() => _DailyPlanPageForAdminState();
}

class _DailyPlanPageForAdminState extends State<DailyPlanPageForAdmin> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _assignedUsers = [];
  int? _selectedUserId;
  int? _selectedTaskStatusId;
  int? _selectedStatusId;
  bool _isLoading = false;

  final List<Map<String, dynamic>> taskStatusOptions = [
    {'id': 1, 'label': 'Pending'},
    {'id': 2, 'label': 'Not Done'},
    {'id': 3, 'label': 'Done'},
  ];

  List<DailyPlan> _filteredPlans = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _fetchDailyPlans();
  }

  Future<void> _updatePlan(DailyPlan plan) async {
    try {
      final response = await ApiCalls.updateDailyPlanComment(
        planId: plan.planId,
        comments: plan.comments,
        statusId: _selectedStatusId ?? 0,
      );
      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Plan updated successfully")),
        );
        _fetchDailyPlans(); // Refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update plan")),
      );
    }
  }

  Future<void> _fetchDailyPlans() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final plans = await ApiCalls.fetchDailyPlans(
        planDate: formattedDate,
        userId: userId,
        userFilter: _selectedUserId,
        statusId: _selectedTaskStatusId,
      );

      setState(() {
        _filteredPlans = plans;
      });
    } catch (e) {
      print("❌ Error fetching daily plans: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load daily plans")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await ApiCalls.fetchUsers();
      setState(() {
        _assignedUsers = users;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
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
              height: 1.4,
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
        title: const Text(
          "Daily Plans",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
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
          // Search bar
          // User & Status Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 🔹 User Dropdown
                  Expanded(
                    child: DropdownSearch<Map<String, dynamic>>(
                      items: _assignedUsers,
                      itemAsString: (user) =>
                          "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}",
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select User",
                          hintText: "User",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search User...",
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        itemBuilder: (context, user, isSelected) {
                          return ListTile(
                            title: Text(
                                "${user['first_name']} ${user['last_name']}"),
                            leading: const Icon(Icons.person),
                          );
                        },
                      ),
                      selectedItem: _selectedUserId != null
                          ? _assignedUsers.firstWhere(
                              (u) => u['user_id'] == _selectedUserId,
                              orElse: () => {},
                            )
                          : null,
                      onChanged: (user) {
                        setState(() {
                          _selectedUserId = user?['user_id'] as int?;
                        });
                        _fetchDailyPlans();
                      },
                      compareFn: (a, b) => a['user_id'] == b['user_id'],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 🔹 Status Dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Task Status',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        prefixIcon: const Icon(Icons.check_circle_outline),
                      ),
                      value: _selectedTaskStatusId,
                      items: taskStatusOptions.map((status) {
                        return DropdownMenuItem<int>(
                          value: status['id'],
                          child: Text(status['label']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTaskStatusId = value;
                        });
                        _fetchDailyPlans();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Plan list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredPlans.isEmpty
                    ? const Center(
                        child: Text(
                          'No daily plans found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filteredPlans.length,
                        itemBuilder: (context, index) {
                          final plan = _filteredPlans[index];
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
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blueAccent,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 18,
                                        ),
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
                                  _buildDetailRow("Plan", plan.planName),
                                  _buildDetailRow("Task", plan.taskName ?? ''),
                                  // _buildDetailRow(
                                  //     "Comment", plan.comments ?? 'N/A'),

                                  _buildDetailRow(
                                      "Achievement", plan.achievements),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    initialValue: plan.comments ?? '',
                                    onChanged: (value) {
                                      plan.comments = value;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Comment',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      prefixIcon: const Icon(Icons.comment),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  /// Editable Task Status Dropdown
                                  DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: 'Task Status',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      prefixIcon: const Icon(
                                          Icons.check_circle_outline),
                                    ),
                                    value: _selectedStatusId,
                                    items: taskStatusOptions.map((status) {
                                      return DropdownMenuItem<int>(
                                        value: status['id'],
                                        child: Text(status['label']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatusId = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  /// Save Button
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _updatePlan(
                                            plan); // Call your API to update the plan
                                      },
                                      icon: const Icon(Icons.save),
                                      label: const Text("Save"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
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
