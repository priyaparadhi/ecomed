import 'dart:convert';

import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/widget/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveBalancePage extends StatefulWidget {
  @override
  _LeaveBalancePageState createState() => _LeaveBalancePageState();
}

class _LeaveBalancePageState extends State<LeaveBalancePage> {
  String? selectedEmployee;
  String? selectedLeaveType;
  int balancedLeaves = 0;
  int bookedLeaves = 0;
  Map<String, dynamic> data = {};
  Map<String, LeaveDetails> leaveDetails = {
    'Casual': LeaveDetails(balanced: 10, booked: 3),
    'Sick': LeaveDetails(balanced: 8, booked: 2),
    'Annual': LeaveDetails(balanced: 15, booked: 5),
  };

  List<Map<String, dynamic>> dataofEmployeeleaves = [];

  // Dummy data for dropdowns
  List<Map<String, dynamic>> employees = [];
  final List<String> leaveTypes = ['Casual', 'Sick', 'Annual'];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getemployess();
  }

  void getemployess() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final fetchedEmployees = await ApiCalls.fetchEmployeesDropdown(
        "${sharedPreferences.getInt("account_id")}");

    setState(() {
      employees = fetchedEmployees;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () async {
                  final Map<String, dynamic> selected =
                      await showEmployeeSearchDialog(context, employees) ?? {};
                  if (selected != null) {
                    Fluttertoast.showToast(msg: "$selected");
                    setState(() {
                      selectedEmployee = selected["user_name"];
                    });

                    _fetchLeaveData(selected["employee_id"]);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Select Employee',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    controller: TextEditingController(
                      text: selectedEmployee,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Balanced',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$balancedLeaves',
                            style: TextStyle(fontSize: 24, color: Colors.green),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Booked',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$bookedLeaves',
                            style: TextStyle(fontSize: 24, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: dataofEmployeeleaves.isEmpty
                    ? Center(child: Text("No detailed leave data available"))
                    : ListView(
                        children: dataofEmployeeleaves.map((entry) {
                          final leaveType = entry["request_type"];
                          final remain = entry["balance_leave"];
                          final outof = entry["total_leave_days"];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$leaveType Leaves',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${remain} / $outof',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mock fetch leave data (simulate API call)
  void _fetchLeaveData(int employee_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic> data1 = await ApiCalls.fetchLeaveCount(
      accountId: sharedPreferences.getInt("account_id") ?? 1,
      employeeId: employee_id,
    );

    print("Response Data: $data1");

    setState(() {
      balancedLeaves = data1["balanced_leaves"];
      bookedLeaves = data1["booked_count"];
      // If individual leave list is not part of new API, you can set it empty or skip the list section
      dataofEmployeeleaves = [];
    });
  }
}

class LeaveDetails {
  final int balanced;
  final int booked;

  LeaveDetails({required this.balanced, required this.booked});
}

// Implement your employee search dialog as needed
Future<Map<String, dynamic>?> showEmployeeSearchDialog(
    BuildContext context, List<Map<String, dynamic>> employees) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return SearchDialog(employees: employees);
    },
  );
}
