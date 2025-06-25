import 'package:dropdown_search/dropdown_search.dart';
import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddDailyPlanPage extends StatefulWidget {
  final int taskId;

  const AddDailyPlanPage({Key? key, required this.taskId}) : super(key: key);

  @override
  State<AddDailyPlanPage> createState() => _AddDailyPlanPageState();
}

class _AddDailyPlanPageState extends State<AddDailyPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _planNameController = TextEditingController();

  final List<String> _users = ['Alice', 'Bob', 'Charlie'];
  final List<String> _statuses = ['Not Started', 'In Progress', 'Completed'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _planTypes = ['Development', 'Testing', 'Research'];
  List<Map<String, dynamic>> _assignedUsers = [];
  int? _selectedUserId;
  List<Map<String, dynamic>> _priorityList = [];
  int? _selectedPriorityId;
  List<Map<String, dynamic>> _planTypeList = [];
  int? _selectedPlanTypeId;
  List<Map<String, dynamic>> _taskStatusList = [];
  int? _selectedTaskStatusId;
  String? _selectedUser, _selectedStatus, _selectedPriority, _selectedPlanType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadPlanType();
    _loadUsers();
    _loadPriorities();
    _loadTaskStatuses();
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

  Future<void> _loadPlanType() async {
    try {
      final planType = await ApiCalls.fetchPlanType();
      setState(() {
        _planTypeList = planType;
      });
    } catch (e) {
      print('Error loading plan type: $e');
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitDailyPlan() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await ApiCalls.addDailyPlan(
          taskId: widget.taskId ?? 0, // Ensure it's not null
          userId: _selectedUserId ?? 0,
          planName: _planNameController.text.trim(),
          planDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
          statusId: _selectedTaskStatusId ?? 0,
          priorityId: _selectedPriorityId ?? 0,
          planTypeId: _selectedPlanTypeId ?? 0,
          achievements: null,
          comments: null,
        );

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );

          // ✅ Clear the form after success
          setState(() {
            _selectedUserId = null;
            _selectedTaskStatusId = null;
            _selectedPriorityId = null;
            _selectedPlanTypeId = null;
            _selectedDate = null;
          });
          _planNameController.clear();
          _formKey.currentState!.reset();

          // Optionally go back after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add plan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: label,
      filled: true,
      fillColor: Colors.white, // white background
      prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            const BorderSide(color: Colors.black, width: 2), // 👈 thin border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            const BorderSide(color: Colors.black, width: 1), // 👈 thin border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
            color: Colors.black, width: 1.2), // slightly darker
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(label),
      icon: const Icon(Icons.arrow_drop_down),
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      validator: (val) => val == null ? 'Please select $label' : null,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Add Daily Plan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                DropdownSearch<Map<String, dynamic>>(
                  items: _assignedUsers,
                  itemAsString: (user) =>
                      "${user['first_name']} ${user['last_name']}",
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: _inputDecoration("Select User",
                        icon: Icons.person_outline),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration:
                          _inputDecoration("Search User", icon: Icons.search),
                    ),
                    itemBuilder: (context, user, isSelected) => ListTile(
                      title: Text("${user['first_name']} ${user['last_name']}"),
                      leading: const Icon(Icons.person),
                    ),
                  ),
                  selectedItem: _selectedUserId != null
                      ? _assignedUsers.firstWhere(
                          (u) => u['user_id'] == _selectedUserId,
                          orElse: () => {})
                      : null,
                  onChanged: (user) =>
                      setState(() => _selectedUserId = user?['user_id']),
                  compareFn: (a, b) => a['user_id'] == b['user_id'],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _planNameController,
                  decoration: _inputDecoration('Plan Name',
                      icon: Icons.edit_note_outlined),
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Please enter a plan name' : null,
                  maxLines: null,
                  minLines: 2,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration('Pick Date',
                        icon: Icons.calendar_today_outlined),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                          : 'Tap to pick a date',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration:
                      _inputDecoration("Priority", icon: Icons.flag_outlined),
                  items: _priorityList
                      .map((p) => DropdownMenuItem<int>(
                            value: p['priority_id'],
                            child: Text(p['priority'].toString()),
                          ))
                      .toList(),
                  value: _selectedPriorityId,
                  onChanged: (val) => setState(() => _selectedPriorityId = val),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Plan Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: _planTypeList
                      .map((p) => DropdownMenuItem<int>(
                            value: p['plan_type_id'] as int,
                            child: Text(p['plan_type'].toString()),
                          ))
                      .toList(),
                  value: _selectedPlanTypeId,
                  onChanged: (val) => setState(() => _selectedPlanTypeId = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: _submitDailyPlan,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
