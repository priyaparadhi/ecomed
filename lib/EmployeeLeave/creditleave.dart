import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditLeaveDialog extends StatefulWidget {
  @override
  _CreditLeaveDialogState createState() => _CreditLeaveDialogState();
}

class _CreditLeaveDialogState extends State<CreditLeaveDialog> {
  Map<String, dynamic>? _selectedEmployee;
  String? _selectedLeaveType;
  int _leaveCount = 0;
  int _leaveBalance = 0;
  List<Map<String, dynamic>> _leaveTypesdata = [];
  int? _selectedLeaveTypeI;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  List<Map<String, dynamic>> _leaveTypes = [];
  TextEditingController creditleaves = TextEditingController();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTime selectdate = DateTime.now();
  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    featchLeavetypedropdown();
    _fetchLeaveTypes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void featchLeavetypedropdown() async {
    _leaveTypesdata = await ApiCalls.fetchLeaveTypesdropdown();
    print(_leaveTypesdata);
    setState(() {
      _leaveTypesdata;
    });
  }

  void getLeavedetaisl(int emplid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      "account_id": sharedPreferences.getInt("account_id"),
      "employee_id": emplid
    };

    Map<String, dynamic> responsedata =
        await ApiCalls.fetchleavesofEmployee(data);
    print(responsedata);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Credit/Debit Leave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor:
            Color.fromARGB(255, 122, 181, 248), // Updated color for the app bar
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Dropdown
            DropdownButtonFormField<Map<String, dynamic>>(
              menuMaxHeight: 200,
              value: _selectedEmployee,
              decoration: InputDecoration(
                labelText: 'Select Employee',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _employees.map((emp) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: emp,
                  child: Text(emp['user_name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedEmployee = newValue;
                });
                getLeavedetaisl(newValue!["employee_id"]);
              },
            ),

            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              decoration: InputDecoration(
                labelText: 'Select Leave Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _leaveTypes.map((leaveType) {
                return DropdownMenuItem<String>(
                  value: leaveType['request_type_id'].toString(),
                  child: Text(leaveType['request_type']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLeaveType = newValue;
                });
                print("Selected Leave Type: $_selectedLeaveType");
              },
            ),
            SizedBox(height: 16),

            // Leave Type Radio Buttons
            Text(
              'Select Leave Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            ..._leaveTypesdata.map((leaveType) {
              return RadioListTile<int>(
                title: Text(leaveType['leave_type'] ?? "noleavetype"),
                value: leaveType['leave_type_id'] ?? 2,
                groupValue: _selectedLeaveTypeI,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedLeaveTypeI = newValue;
                  });
                  print('Selected Leave Type: $_selectedLeaveTypeI');
                },
              );
            }).toList(),

            SizedBox(height: 16),

            // Date Picker
            GestureDetector(
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2050),
                );
                setState(() {
                  selectdate = date ?? DateTime.now();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: Text(
                  "${selectdate.day}/${selectdate.month}/${selectdate.year}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Balanced Leaves TextField (Read Only)
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Balanced Leaves',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              controller: TextEditingController(
                text: '$_leaveBalance',
              ),
            ),

            SizedBox(height: 16),

            // Credit Leave Input Field
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Credit Leave',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: creditleaves,
            ),

            SizedBox(height: 16),

            // Comment Input Field
            TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Comment',
                hintText: "Comment",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: TextEditingController(
                text: "",
              ),
            ),

            SizedBox(height: 24),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _creditLeave();
                },
                child: Text(
                  'Add',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 122, 181, 248),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _fetchLeaveTypes() async {
    try {
      List<Map<String, dynamic>> leaveTypes = await ApiCalls.fetchLeaveTypes();
      setState(() {
        _leaveTypes = leaveTypes;
      });
    } catch (e) {
      print('Failed to fetch leave types: $e');
    }
  }

  // void _showEmployeeDropdown() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select Employee'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: _searchController,
  //               decoration: InputDecoration(
  //                 labelText: 'Search',
  //                 border: OutlineInputBorder(),
  //               ),
  //               onChanged: (String query) {
  //                 setState(() {
  //                   _searchQuery = query;
  //                   _filterEmployees();
  //                 });
  //               },
  //             ),
  //             SizedBox(height: 8),
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: _filteredEmployees.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   if (_filteredEmployees.isEmpty) {
  //                     return Center(child: Text('No results found'));
  //                   }
  //                   final employee = _filteredEmployees[index];
  //                   return ListTile(
  //                     title: Text(
  //                         '${employee['first_name']} ${employee['last_name']}'),
  //                     onTap: () {
  //                       setState(() {
  //                         _selectedEmployee =
  //                             employee['employee_id'].toString();
  //                       });
  //                       _fetchLeaveBalanceIfNeeded(); // Fetch leave balance if both are selected
  //                       Navigator.of(context).pop();
  //                     },
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _fetchEmployees() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      List<
          Map<String,
              dynamic>> employees = await ApiCalls.fetchEmployeesDropdown(
          '${sharedPreferences.get("account_id")}'); // Replace with your account ID
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      print('Failed to fetch employees: $e');
    }
  }

  void _filterEmployees() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((employee) {
          final fullName = '${employee['first_name']} ${employee['last_name']}';
          final queryLowerCase = _searchQuery.toLowerCase();
          final fullNameLowerCase = fullName.toLowerCase();
          return fullNameLowerCase.contains(queryLowerCase);
        }).toList();
      }
    });
  }

  // void _fetchLeaveBalanceIfNeeded() {
  //   if (_selectedEmployee != null && _selectedLeaveType != null) {
  //     _fetchLeaveBalance(_selectedEmployee);
  //   }
  // }

  void _fetchLeaveBalance(String? employeeId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (employeeId == null) return;

    try {
      final response = await ApiCalls.fetchLeaveBalance(
        accountId: preferences.getInt("account_id") ?? 0,
        employeeId: int.parse(employeeId),
        requestTypeId: int.parse(_selectedLeaveType ??
            '1'), // Defaulting to 1 if no leave type selected
      );
      setState(() {
        _leaveBalance = response['balance_leave'].toInt();
      });
    } catch (e) {
      print('Failed to fetch leave balance: $e');
    }
  }

  void _creditLeave() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (_selectedEmployee != null &&
        _selectedLeaveType != null &&
        _leaveCount > -1) {
      print('Employee ID: ${_selectedEmployee!["employee_id"]}');
      print('Leave Type: $_selectedLeaveType');
      print('Leave Count: $_leaveCount');

      Map<String, dynamic> data = await ApiCalls.addLeaveOrCreditLeave({
        "account_id": sharedPreferences.getInt("account_id") ?? 1110,
        "employee_id": _selectedEmployee!["employee_id"],
        "request_type_id": _selectedLeaveType,
        "leave_type_id": "${_selectedLeaveTypeI}",
        "amount": creditleaves.text.toString(),
        "leave_date":
            "${selectdate.day}/${selectdate.month}/${selectdate.year}",
        "created_by": _selectedEmployee!["employee_id"] ?? 0
      });
      Fluttertoast.showToast(msg: "$data");
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }
}
