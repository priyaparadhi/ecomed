import 'package:dropdown_search/dropdown_search.dart';
import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/TaskModel.dart';
import 'package:ecomed/Screens/CommentLog/commentLog.dart';
import 'package:ecomed/Screens/DailyPlan/AddDailyPlan.dart';
import 'package:ecomed/Screens/Tasks/Tasks/AddTaskPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeesTasksPage extends StatefulWidget {
  const EmployeesTasksPage({Key? key}) : super(key: key);

  @override
  State<EmployeesTasksPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<EmployeesTasksPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _taskStatusList = [];
  int? _selectedTaskStatusId;
  List<Map<String, dynamic>> _assignedUsers = [];
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _loadTaskStatuses();
    _loadUsers();
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final tasks = await ApiCalls.fetchAllTasks(
        selectedUserId: _selectedUserId,
        selectedTaskStatusId: _selectedTaskStatusId,
      );

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
    String _formatDate(String rawDate) {
      try {
        final date = DateTime.parse(rawDate);
        return DateFormat('d MMM yyyy').format(date);
      } catch (e) {
        return rawDate;
      }
    }

    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Task Name & Priority
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.taskName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.priority,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Status
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text(
                  "Status: ${task.status}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade200),

            /// Created By & Assigned To
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 16, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Created by: ${task.createdByName}",
                    style: const TextStyle(fontSize: 13),
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
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Dates
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined,
                    size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${_formatDate(task.taskStartDate)} → ${_formatDate(task.taskEndDate)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                IconButton(
                  tooltip: "Add Daily Plan",
                  icon: const Icon(
                    Icons.playlist_add,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddDailyPlanPage(taskId: task.taskId),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: "View Comments",
                  icon: const Icon(
                    Icons.comment_outlined,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentLogScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
        title: const Text(
          'Task List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
              : Column(
                  children: [
                    // Filter section
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownSearch<Map<String, dynamic>>(
                                  items: _assignedUsers,
                                  itemAsString: (user) =>
                                      "${user['first_name']} ${user['last_name']}",
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: "User",
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: "Search User...",
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  selectedItem: _selectedUserId != null
                                      ? _assignedUsers.firstWhere(
                                          (u) =>
                                              u['user_id'] == _selectedUserId,
                                          orElse: () => {},
                                        )
                                      : null,
                                  onChanged: (user) {
                                    setState(() {
                                      _selectedUserId =
                                          user?['user_id'] as int?;
                                      _fetchTasks();
                                    });
                                  },
                                  compareFn: (a, b) =>
                                      a['user_id'] == b['user_id'],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownSearch<Map<String, dynamic>>(
                                  items: _taskStatusList,
                                  itemAsString: (status) =>
                                      status['task_status'],
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: "Status",
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: "Search Status...",
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  selectedItem: _selectedTaskStatusId != null
                                      ? _taskStatusList.firstWhere(
                                          (s) =>
                                              s['task_status_id'] ==
                                              _selectedTaskStatusId,
                                          orElse: () => {},
                                        )
                                      : null,
                                  onChanged: (status) {
                                    setState(() {
                                      _selectedTaskStatusId =
                                          status?['task_status_id'] as int?;
                                      _fetchTasks();
                                    });
                                  },
                                  compareFn: (a, b) =>
                                      a['task_status_id'] ==
                                      b['task_status_id'],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tasks list
                    Expanded(
                      child: _tasks.isEmpty
                          ? const Center(child: Text('No tasks found'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _buildTaskCard(_tasks[index]),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
