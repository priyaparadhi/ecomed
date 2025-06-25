import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class DailyPlanPageForAdmin extends StatefulWidget {
  const DailyPlanPageForAdmin({super.key});

  @override
  State<DailyPlanPageForAdmin> createState() => _DailyPlanPageForAdminState();
}

class _DailyPlanPageForAdminState extends State<DailyPlanPageForAdmin> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allPlans = [
    {
      "user_name": "Nandita Deshmukh",
      "plan": "Design UI for dashboard",
      "date": "2025-06-24",
      "task": "UI Design",
      "comment":
          "Finalize colors and typography. Check spacing and paddings for visual balance.",
      "status": "In Progress",
      "achievement": "Work is 80% complete.",
    },
    {
      "user_name": "Rahul Patil",
      "plan": "Write API docs",
      "date": "2025-06-24",
      "task": "Documentation",
      "comment": "Cover auth endpoints, error handling examples.",
      "status": "Not Started",
      "achievement": "",
    },
    {
      "user_name": "Sneha Gupta",
      "plan": "Backend optimization",
      "date": "2025-06-24",
      "task": "Development",
      "comment": "Optimize SQL queries for better performance.",
      "status": "Completed",
      "achievement": "Finished optimization. Performance improved by 30%.",
    },
  ];

  List<Map<String, dynamic>> _filteredPlans = [];

  @override
  void initState() {
    super.initState();
    _filteredPlans = List.from(_allPlans);
    _searchController.addListener(() => _applyFilter());
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredPlans = _allPlans.where((plan) {
        return plan['user_name'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "In Progress":
        return Colors.orange;
      case "Not Started":
        return Colors.red;
      case "Completed":
        return Colors.green;
      default:
        return Colors.grey;
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
              onDateChange: (date) => setState(() => _selectedDate = date),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by employee name...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ),
          // Plan list
          Expanded(
            child: ListView.builder(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan['date'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(plan['status']).withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                plan['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(plan['status']),
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
                                plan['user_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow("Plan", plan['plan']),
                        _buildDetailRow("Task", plan['task']),
                        _buildDetailRow("Comment", plan['comment']),
                        if (plan['achievement'].isNotEmpty)
                          _buildDetailRow(
                            "Achievement",
                            plan['achievement'],
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
