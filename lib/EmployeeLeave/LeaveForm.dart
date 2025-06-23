import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveForm extends StatefulWidget {
  const LeaveForm({required this.refresh});
  final Function refresh;
  @override
  _LeaveFormState createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  String? _selectedLeaveType;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateTime _returnDate = DateTime.now();
  String _reason = '';
  String _employeeName = '';
  List<Map<String, dynamic>> _leaveTypes = [];

  String? _filePath;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  @override
  void initState() {
    _fetchLeaveTypes();
    // TODO: implement initState
    super.initState();
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

  Future<void> _submitLeaveRequest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? employeeId = prefs.getInt('employee_id');
      int? userIdStr = prefs.getInt('user_id');

      // if (employeeIdStr == null || userIdStr == null) {
      //   throw Exception(
      //       'Employee ID or User ID not found in SharedPreferences');
      // }

      // final int employeeId = int.parse(employeeIdStr);

      final noOfDays = _returnDate.difference(_fromDate).inDays;

      Map<String, dynamic> data = {
        "employee_id": employeeId,
        "request_type_id": int.parse(_selectedLeaveType!),
        "no_of_days": noOfDays.toDouble(),
        "reason": _reason,
        "date_from":
            "${_fromDate.year}-${_fromDate.month.toString().padLeft(2, '0')}-${_fromDate.day.toString().padLeft(2, '0')}",
        "date_to":
            "${_toDate.year}-${_toDate.month.toString().padLeft(2, '0')}-${_toDate.day.toString().padLeft(2, '0')}",
        "return_to_office":
            "${_returnDate.year}-${_returnDate.month.toString().padLeft(2, '0')}-${_returnDate.day.toString().padLeft(2, '0')}",
        "account_id": prefs.getInt("account_id"),
        "created_by": employeeId,
        "attachment": _filePath != null ? _filePath : null
      };

      print(
          "here is the data of the submit >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$data");

      var response = await ApiCalls.applyLeave(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response}'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedLeaveType;
        _fromDate = DateTime.now();
        _toDate = DateTime.now();
        _returnDate = DateTime.now();
        _reason = '';
        _filePath = null;
      });
      widget.refresh();
      Navigator.pop(context);
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit leave request: $e'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Leave Request'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Appstyles.cardStyle(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    'Leave Type:',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
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
                      fillColor: Colors.grey[100],
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
                  SizedBox(
                      height: 16), // Padding between label and date pickers
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _selectDate(context, _fromDate, (picked) {
                              setState(() {
                                _fromDate = picked;
                              });
                            });
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            child: Text(
                              '${_fromDate.year}-${_fromDate.month}-${_fromDate.day}',
                              style: GoogleFonts.lato(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _selectDate(context, _toDate, (picked) {
                              setState(() {
                                _toDate = picked;
                              });
                            });
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            child: Text(
                              '${_toDate.year}-${_toDate.month}-${_toDate.day}',
                              style: GoogleFonts.lato(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 19.0),
                  Text(
                    'Date of Return to Office:',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 9.0),
                  GestureDetector(
                    onTap: () async {
                      await _selectDate(context, _returnDate, (picked) {
                        setState(() {
                          _returnDate = picked;
                        });
                      });
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Return Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      child: Text(
                        '${_returnDate.year}-${_returnDate.month}-${_returnDate.day}',
                        style: GoogleFonts.lato(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Reason:',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 8.0), // Padding between label and text field
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _reason = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter reason for leave',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.0),
                  if (_selectedLeaveType == '1' &&
                      _toDate.difference(_fromDate).inDays > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attach Medical Certificates/Supporting Documents:',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: Text('Attach Files'),
                        ),
                        SizedBox(height: 8.0),
                        if (_filePath != null)
                          Text('File Attached: $_filePath'),
                      ],
                    ),
                  SizedBox(height: 16.0),
                  _isSubmitting
                      ? Center(child: CircularProgressIndicator())
                      : Center(
                          child: ElevatedButton(
                            onPressed: _submitLeaveRequest,
                            style: Appstyles.blueButtonStyle(),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500),
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
