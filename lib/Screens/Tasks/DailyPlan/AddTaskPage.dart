import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _taskNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> _assignedUsers = [];
  List<int> _selectedUserIds = [];

  List<String> _selectedUsers = [];

  List<Map<String, dynamic>> _priorityList = [];
  int? _selectedPriorityId;
  List<Map<String, dynamic>> _taskStatusList = [];
  int? _selectedTaskStatusId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPriorities();
    _loadTaskStatuses();
    _loadUsers();
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null ||
          _endDate == null ||
          _selectedPriorityId == null ||
          _selectedTaskStatusId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await ApiCalls.addTask(
          taskName: _taskNameController.text.trim(),
          assignedTo: _selectedUserIds,
          startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
          priorityId: _selectedPriorityId!,
          taskStatusId: _selectedTaskStatusId!,
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Task added')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Failed to add task')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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

  Future<void> _loadPriorities() async {
    try {
      final priorities = await ApiCalls.fetchPriorities();
      setState(() {
        _priorityList = priorities;
      });
    } catch (e) {
      print('Error loading priorities: $e');
    }
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

  Future<void> _pickDate(bool isStartDate) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: Colors.indigo),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Add Plan'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create a new Plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Multi-line Task name
                  TextField(
                    controller: _taskNameController,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Task Name",
                      alignLabelWithHint: true,
                      hintText: "Describe the task...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  MultiSelectDialogField<int>(
                    items: _assignedUsers
                        .map((user) => MultiSelectItem<int>(
                              user['user_id'] as int,
                              "${user['first_name']} ${user['last_name']}",
                            ))
                        .toList(),
                    title: const Text('Assign To'),
                    searchable: true,
                    selectedColor: Colors.indigo,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    buttonText: const Text(
                      "Assign Users",
                      style: TextStyle(fontSize: 16),
                    ),
                    onConfirm: (values) {
                      setState(() {
                        _selectedUserIds = values.cast<int>();
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Start Date",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _startDate != null
                                  ? dateFormat.format(_startDate!)
                                  : "Pick",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "End Date",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _endDate != null
                                  ? dateFormat.format(_endDate!)
                                  : "Pick",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: _priorityList
                        .map((p) => DropdownMenuItem<int>(
                              value: p['priority_id'] as int,
                              child: Text(p['priority'].toString()),
                            ))
                        .toList(),
                    value: _selectedPriorityId,
                    onChanged: (val) =>
                        setState(() => _selectedPriorityId = val),
                  ),

                  const SizedBox(height: 16),
                  DropdownSearch<Map<String, dynamic>>(
                    items: _taskStatusList,
                    itemAsString: (Map<String, dynamic>? item) =>
                        item?['task_status'] ?? '',
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Task Status",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    selectedItem: _taskStatusList.firstWhere(
                      (item) => item['task_status_id'] == _selectedTaskStatusId,
                      orElse: () => {},
                    ),
                    onChanged: (val) {
                      setState(() {
                        _selectedTaskStatusId = val?['task_status_id'] as int?;
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

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      backgroundColor: Colors.indigo,
                    ),
                    onPressed: _isLoading ? null : _submitTask,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Task',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
