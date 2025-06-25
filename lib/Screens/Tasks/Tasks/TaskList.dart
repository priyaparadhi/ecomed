import 'package:dropdown_search/dropdown_search.dart';
import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/TaskModel.dart';
import 'package:ecomed/Screens/Tasks/Tasks/Timesheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _taskStatusList = [];
  int? _selectedTaskStatusId;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _loadTaskStatuses();
  }

  String _convertTimeTo24Hr(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _loadTaskStatuses() async {
    try {
      final statuses = await ApiCalls.fetchTaskStatuses();
      setState(() {
        _taskStatusList = statuses;
      });
    } catch (e) {
      print('Error loading task statuses: $e');
    }
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tasks = await ApiCalls.fetchAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildTaskCard(Task task) {
    final commentController = TextEditingController();
    TimeOfDay? _startTime;
    TimeOfDay? _endTime;
    String? selectedStatus = task.status;

    String _formatDate(String rawDate) {
      try {
        final date = DateTime.parse(rawDate);
        return DateFormat('d MMM yyyy').format(date);
      } catch (e) {
        return rawDate;
      }
    }

    Future<void> _submitTimesheet(
        Function(void Function()) setInnerState) async {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Start and End time are required.")),
        );
        return;
      }

      if (commentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a comment.")),
        );
        return;
      }

      try {
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyy-MM-dd').format(now);
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id') ?? 0;

        await ApiCalls.addTimesheet(
          userId: userId,
          taskId: task.taskId,
          taskStatusId: _selectedTaskStatusId ?? task.taskStatusId,
          workDate: formattedDate,
          startTime: _convertTimeTo24Hr(_startTime!),
          endTime: _convertTimeTo24Hr(_endTime!),
          comment: commentController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Timesheet added successfully")),
        );

        // 🧹 Clear the values
        setInnerState(() {
          _startTime = null;
          _endTime = null;
          commentController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Task Name + Priority
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.taskName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// Created by & Assigned To
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Created by: ${task.createdByName}",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.groups_2_outlined,
                        size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Assigned to: ${task.assignedToNames}",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// Dates
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      "${_formatDate(task.taskStartDate)} → ${_formatDate(task.taskEndDate)}",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Status Dropdown
                DropdownSearch<Map<String, dynamic>>(
                  items: _taskStatusList,
                  itemAsString: (item) => item?['task_status'] ?? '',
                  selectedItem: _taskStatusList.firstWhere(
                    (item) => item['task_status'] == selectedStatus,
                    orElse: () => _taskStatusList.first,
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Update Task Status",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  onChanged: (val) {
                    setInnerState(() {
                      selectedStatus = val?['task_status'];
                      _selectedTaskStatusId =
                          val?['task_status_id']; // ✅ Store selected ID
                    });
                  },
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: 'Search Status',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePickerButton(
                        label: "Start Time",
                        icon: Icons.access_time,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setInnerState(() {
                              _startTime = picked;
                            });
                          }
                        },
                        time: _startTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimePickerButton(
                        label: "End Time",
                        icon: Icons.timelapse_outlined,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setInnerState(() {
                              _endTime = picked;
                            });
                          }
                        },
                        time: _endTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Comment
                TextFormField(
                  controller: commentController,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Add your comment...",
                    hintStyle: TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// Save & Timesheet Buttons Row
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Save Button
                      ElevatedButton.icon(
                        icon: Icon(Icons.save, size: 18),
                        label: Text("Save", style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _submitTimesheet(setInnerState),
                      ),

                      const SizedBox(width: 24),

                      /// Timesheet Icon + Text (clickable)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TimesheetPage(), // dynamic ID if needed
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.access_time_filled_rounded,
                                color: Colors.indigo, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              "View Timesheet",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.indigo,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimePickerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required TimeOfDay? time,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                time != null ? time.format(context) : label,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Task List',
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _tasks.isEmpty
                  ? const Center(child: Text('No tasks found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildTaskCard(_tasks[index]),
                        );
                      },
                    ),
    );
  }
}
