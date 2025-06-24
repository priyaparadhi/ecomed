import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveTracker.dart';
import 'package:ecomed/Screens/EmployeeLeave/leavehistory.dart';
import 'package:ecomed/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkFromHomeForm extends StatefulWidget {
  @override
  _WorkFromHomeFormState createState() => _WorkFromHomeFormState();
}

class _WorkFromHomeFormState extends State<WorkFromHomeForm> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateTime _returnDate = DateTime.now();
  String _reason = '';
  bool _isSubmitting = false;
  Future<List<LeaveHistory>>? futureLeaveHistory;
  Future<List<WfhHistory>>? futureWfhHistory;

  void initState() {
    super.initState();
    callFunction();
  }

  void callFunction() async {
    try {
      // String employeeId = await _fetchAndStoreEmployeeId();

      setState(() {
        // futureLeaveHistory = ApiCalls.fetchSingleEmployeeLeave();
        futureWfhHistory = ApiCalls.fetchSingleEmployeeWFH();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<String> _fetchAndStoreEmployeeId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? employeeId = prefs.getString('employee_id');

  //   if (employeeId == null) {
  //     await ApiCalls.fetchAndStoreEmployeeId();
  //     employeeId = prefs.getString('employee_id');
  //   }

  //   if (employeeId == null) {
  //     throw Exception('Employee ID not found after fetching and storing.');
  //   }

  //   return employeeId;
  // }

  Future<void> _submitWorkFromHomeRequest() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? employeeId = prefs.getInt('employee_id');

      // if (employeeIdStr == null) {
      //   throw Exception(
      //       'Employee ID or User ID not found in SharedPreferences');
      // }

      //final int employeeId = int.parse(employeeIdStr);
      final noOfDays = _toDate.difference(_fromDate).inDays + 1;

      await ApiCalls.addWFH(
        accountId: "1100",
        employeeId: employeeId ?? 0,
        noOfDays: noOfDays,
        reason: _reason,
        dateFrom: '${_fromDate.year}-${_fromDate.month}-${_fromDate.day}',
        dateTo: '${_toDate.year}-${_toDate.month}-${_toDate.day}',
        returnToOffice:
            '${_returnDate.year}-${_returnDate.month}-${_returnDate.day}',
        createdBy: employeeId ?? 0,
      );

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Work from home request submitted'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh WFH history
      callFunction();

      // Close the bottom sheet
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting work from home request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit work from home request'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: Colors.blue),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appstyles.primaryColor,
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 2,
              ),
              Expanded(
                  child: Padding(
                padding:
                    const EdgeInsets.all(8.0), // You can adjust this as needed
                child: Text(
                  "Apply For Work From Home",
                  style: GoogleFonts.lato(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              Padding(
                padding:
                    const EdgeInsets.all(8.0), // You can adjust this as needed
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.22, // ~25% of screen width
                  height: MediaQuery.of(context).size.height *
                      0.042, // ~4% of screen height
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16.0)),
                        ),
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                  left: 16.0,
                                  right: 16.0,
                                  top: 16.0,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'Date:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                await _selectDate(
                                                    context, _fromDate,
                                                    (picked) {
                                                  setState(() {
                                                    _fromDate = picked;
                                                  });
                                                });
                                              },
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: 'From',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[200],
                                                ),
                                                child: Text(
                                                  '${_fromDate.year}-${_fromDate.month}-${_fromDate.day}',
                                                  style: const TextStyle(
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                await _selectDate(
                                                    context, _toDate, (picked) {
                                                  setState(() {
                                                    _toDate = picked;
                                                  });
                                                });
                                              },
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: 'To',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[200],
                                                ),
                                                child: Text(
                                                  '${_toDate.year}-${_toDate.month}-${_toDate.day}',
                                                  style: const TextStyle(
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'Date of Return to Office:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      const SizedBox(height: 19.0),
                                      GestureDetector(
                                        onTap: () async {
                                          await _selectDate(
                                              context, _returnDate, (picked) {
                                            setState(() {
                                              _returnDate = picked;
                                            });
                                          });
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Return Date',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                          ),
                                          child: Text(
                                            '${_returnDate.year}-${_returnDate.month}-${_returnDate.day}',
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'Reason:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            _reason = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              'Enter reason for work from home',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                        ),
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 16.0),
                                      _isSubmitting
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : Center(
                                              child: ElevatedButton(
                                                onPressed:
                                                    _submitWorkFromHomeRequest,
                                                style:
                                                    Appstyles.blueButtonStyle(),
                                                child: const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      const SizedBox(
                                          height: 24.0), // space at bottom
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize:
                          const Size(0, 40), // Ensures consistent height
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: GoogleFonts.lato(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
          LeaveHistorySection(
            futureLeaveHistory: futureLeaveHistory ?? Future.value([]),
            futureWfhHistory: futureWfhHistory ?? Future.value([]),
          )
        ],
      ),
    );
  }
}
