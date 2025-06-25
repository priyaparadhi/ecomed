import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class DailyPlanPage extends StatefulWidget {
  const DailyPlanPage({super.key});

  @override
  State<DailyPlanPage> createState() => _DailyPlanPageState();
}

class _DailyPlanPageState extends State<DailyPlanPage> {
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _plans = [
    {
      "user_name": "Nandita Deshmukh",
      "plan": "Design UI for dashboard",
      "date": "2025-06-24",
      "task": "UI Design",
      "comment":
          "Finalize colors and typography. Ensure consistency across all elements. Check spacing and paddings for proper alignment and visual balance.",
      "status": "In Progress",
      "achievement": "",
    },
    {
      "user_name": "Rahul Patil",
      "plan": "Write API docs",
      "date": "2025-06-24",
      "task": "Documentation",
      "comment":
          "Cover auth endpoints, error handling examples, and update version history. Ensure clarity and completeness for new team members.",
      "status": "Not Started",
      "achievement": "",
    },
  ];

  void _updateAchievement(int index, String value) {
    setState(() {
      _plans[index]['achievement'] = value;
    });
  }

  void _showAchievementDialog(int index) {
    final controller = TextEditingController(
      text: _plans[index]['achievement'],
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
              onDateChange: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
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
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _showAchievementDialog(index),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.4),
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
                                    plan['achievement'].isEmpty
                                        ? "Add your achievement..."
                                        : plan['achievement'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: plan['achievement'].isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      color: plan['achievement'].isEmpty
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
