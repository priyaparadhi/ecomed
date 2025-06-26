import 'dart:convert';
import 'package:ecomed/Models/AttendenceModel.dart';
import 'package:ecomed/Models/DailyPlanModel.dart';
import 'package:ecomed/Models/TaskModel.dart';
import 'package:ecomed/Models/Timesheetmodel.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveTracker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiCalls {
  //static String baseurl = "https://portalwiz.net/laravelapi/public/api/";
  static String basestorage = "https://portalwiz.net/laravelapi/storage/app/";
  static String baseurl = "https://ecomed-dev.portalwiz.in/api/public/api/";
  //baseurl = https://portalwiz.net/laravelapi/public/api/
  //basestorage = https://portalwiz.net/laravelapi/storage/app/
  // devurl = https://pw-bms-dev.portalwiz.in
  // dev storage =
  static Future<List<Map<String, dynamic>>> fetchLeaveTypesdropdown() async {
    // Replace this with your actual API call
    final response = await http.get(Uri.parse('${baseurl}leave_type_dropdown'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load leave types');
    }
  }

  static Future<Map<String, dynamic>> fetchleavesofEmployee(
      Map<String, dynamic> empdetails) async {
    final response = await http.post(
      Uri.parse('${baseurl}fetch_leave_of_employee'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(empdetails),
    );

    print("Request: ${empdetails}");

    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body)[0];
    } else {
      throw Exception('Failed to add contact');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLeaveTypes() async {
    final response = await http.get(Uri.parse(
        '${baseurl}fetch_leave_type')); // Replace with your actual API endpoint

    if (response.statusCode == 200) {
      final List<dynamic> leaveTypes = json.decode(response.body);
      return leaveTypes.map((leave) {
        return {
          'request_type_id': leave['request_type_id'],
          'request_type': leave['request_type'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch leave types');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchEmployeesDropdown(
      String accountId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseurl}fetch_employees'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'account_id': accountId,
        }),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;

        if (responseBody.containsKey('users') &&
            responseBody['users'] is List) {
          List<dynamic> usersList = responseBody['users'] as List<dynamic>;

          // Convert each item in the list to a Map<String, dynamic>
          List<Map<String, dynamic>> employees =
              usersList.map((item) => item as Map<String, dynamic>).toList();
          return employees;
        } else {
          print('Invalid response structure: ${responseBody}');
          throw Exception('Invalid response structure');
        }
      } else {
        print('Failed to fetch employees, status code: ${response.statusCode}');
        throw Exception('Failed to fetch employees');
      }
    } catch (e) {
      print('Error in fetchEmployeesDropdown: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> fetchLeaveBalance({
    required int accountId,
    required int employeeId,
    required int requestTypeId,
  }) async {
    final response = await http.post(
      Uri.parse(
          '${baseurl}fetch_leaves_of_employee'), // Replace with actual URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'account_id': accountId,
        'employee_id': employeeId,
        'request_type_id': requestTypeId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch leave balance');
    }
  }

  static Future<Map<String, dynamic>> addLeaveOrCreditLeave(
      Map<String, dynamic> leaveData) async {
    try {
      print("Request Body: ${jsonEncode(leaveData)}"); // Print request body

      final response = await http.post(
        Uri.parse('${baseurl}add_leave_of_employee'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(leaveData),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Print response body

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add leave');
      }
    } catch (e) {
      print("Error: $e"); // Print error if any
      throw Exception('Failed to add leave: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchLeaveCount({
    required int accountId,
    required int employeeId,
  }) async {
    final response = await http.post(
      Uri.parse('${baseurl}fetch_leave_count'),
      body: {
        'account_id': "$accountId",
        'employee_id': "$employeeId",
      },
    );

    print({
      'account_id': "$accountId",
      'employee_id': "$employeeId",
    });

    Fluttertoast.showToast(msg: response.body);
    print(" Response Data ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch leave count');
    }
  }

  static Future<Map<String, dynamic>> applyLeave(
      Map<String, dynamic> leaveData) async {
    try {
      print(
          "Request Body for apply leave: ${jsonEncode(leaveData)}"); // Print request body

      final response = await http.post(
        Uri.parse('${baseurl}apply_leave'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(leaveData),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Print response body

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add leave');
      }
    } catch (e) {
      print("Error: $e"); // Print error if any
      throw Exception('Failed to add leave: $e');
    }
  }

  static Future<List<String>> fetchEmployeeTypes() async {
    final response = await http.get(
      Uri.parse('${baseurl}employee_type_dropdown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item['employment_type'] as String).toList();
    } else {
      throw Exception('Failed to load employee types');
    }
  }

  static Future<List<LeaveHistory>> fetchSingleEmployeeLeave() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? employeeId = prefs.getString('employee_id');

      // if (employeeId == null) {
      //   throw Exception('Employee ID not found in SharedPreferences');
      // }

      final response = await http.post(
        Uri.parse('${baseurl}fetch_single_employee_leave'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'account_id': '${prefs.getInt("account_id")}',
          'employee_id': '${prefs.getInt("employee_id")}',
        }),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<String> requestTypeIds = [];
        for (var leave in jsonResponse) {
          requestTypeIds.add(leave['request_type_id'].toString());
        }
        await prefs.setStringList('request_type_ids', requestTypeIds);

        return jsonResponse
            .map((leave) => LeaveHistory.fromJson(leave))
            .toList();
      } else {
        throw Exception('Failed to load leave history');
      }
    } catch (e) {
      throw Exception('Failed to load leave history: $e');
    }
  }

  static Future<List<WfhHistory>> fetchSingleEmployeeWFH() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(
        Uri.parse('${baseurl}fetch_single_employee_wfh'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'account_id': '${prefs.getInt("account_id")}',
          'employee_id': '${prefs.getInt("employee_id")}',
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((x) => WfhHistory.fromJson(x)).toList();
      } else {
        throw Exception('Failed to load WFH history');
      }
    } catch (e) {
      throw Exception('Failed to load WFH history: $e');
    }
  }

  static Future<List<dynamic>> fetchAllLeave(String accountId) async {
    final response = await http.post(
      Uri.parse('${baseurl}fetch_applied_leaves'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_id': accountId,
      }),
    );
    print("Response data ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leave data');
    }
  }

  static Future<void> fetchAndStoreEmployeeId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int? userId = prefs.getInt('user_id');
      int? accountId =
          prefs.getInt('account_id'); // ✅ Get from SharedPreferences

      if (userId == null || accountId == null) {
        print('User ID or Account ID not found in SharedPreferences');
        return;
      }

      final response = await http.post(
        Uri.parse('${baseurl}fetch_employees'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'account_id': accountId,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final employee = responseBody['users'].firstWhere(
          (user) => user['user_id'] == userId,
          orElse: () => null,
        );

        if (employee != null) {
          final String employeeId = employee['employee_id'].toString();
          await prefs.setString('employee_id', employeeId);

          print('Employee ID stored: $employeeId');
          print('Employee details: $employee');
        } else {
          print('Employee not found for user ID: $userId');
        }
      } else {
        print('Failed to fetch employees, status code: ${response.statusCode}');
        throw Exception('Failed to fetch employees');
      }
    } catch (e) {
      print('Error in fetchAndStoreEmployeeId: $e');
    }
  }

  static Future<List<dynamic>> fetchAllWFH() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt('account_id');

    // Safety check: accountId must not be null
    if (accountId == null) {
      throw Exception('Account ID not found in SharedPreferences.');
    }

    final response = await http.post(
      Uri.parse('${baseurl}fetch_all_wfh'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(
        <String, dynamic>{
          // allow dynamic values
          'account_id': accountId,
        },
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Failed to load work-from-home data. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  static Future<void> updateWFHStatus(
      String wfhId, String status, String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? employeeId = prefs.getString('employee_id');

    if (employeeId == null) {
      throw Exception('Employee ID not found in SharedPreferences');
    }

    final Map<String, dynamic> requestBody = {
      "account_id": "${prefs.getInt("account_id")}",
      "wfh_id": wfhId,
      "wfh_status": status,
      "comment": comment,
      "updated_by": employeeId,
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('${baseurl}update_wfh'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('WFH status updated successfully');
    } else {
      print('Failed to update WFH status, status code: ${response.statusCode}');
      throw Exception('Failed to update WFH status');
    }
  }

  static Future<List<dynamic>> fetchApprovedLeaves(
      String accountId, String employeeId) async {
    final response = await http.post(
      Uri.parse('${baseurl}fetch_approved_leaves'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_id': accountId,
        'employee_id': employeeId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch approved leaves');
    }
  }

  static Future<List<dynamic>> fetchDeniedLeaves(
      String accountId, String employeeId) async {
    final response = await http.post(
      Uri.parse('${baseurl}fetch_cancelled_leaves'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_id': accountId,
        'employee_id': employeeId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch cancelled leaves');
    }
  }

  static Future<Map<String, dynamic>> fetchCasualLeaves() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? employeeId = prefs.getString('employee_id');

      // // Wait until employeeId is not null
      // while (employeeId == null) {
      //   await Future.delayed(Duration(milliseconds: 100));
      //   employeeId = prefs.getString('employee_id');
      // }

      final body = {
        "account_id": "${prefs.getInt("account_id")}",
        "employee_id": "${prefs.getInt("employee_id")}",
      };

      print("Request Body: ${json.encode(body)}"); // Print request body

      final response = await http.post(
        Uri.parse('${baseurl}fetch_casual_leaves'),
        headers: headers,
        body: json.encode(body),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Print response body

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch casual leaves');
      }
    } catch (e) {
      print("Error: $e"); // Print error if any
      throw Exception('Failed to fetch casual leaves: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchSickLeaves() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? employeeId = prefs.getString('employee_id');

      // // Wait until employeeId is not null
      // while (employeeId == null) {
      //   await Future.delayed(Duration(milliseconds: 100));
      //   employeeId = prefs.getString('employee_id');
      // }

      final body = {
        "account_id": "${prefs.getInt("account_id")}",
        "employee_id": "${prefs.getInt("employee_id")}",
      };

      final response = await http.post(
        Uri.parse('${baseurl}fetch_sick_leaves'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch sick leaves');
      }
    } catch (e) {
      throw Exception('Failed to fetch sick leaves: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchElectiveLeaves() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? employeeId = prefs.getString('employee_id');

      // // Wait until employeeId is not null
      // while (employeeId == null) {
      //   await Future.delayed(Duration(milliseconds: 100));
      //   employeeId = prefs.getString('employee_id');
      // }

      final body = {
        "account_id": "${prefs.getInt("account_id")}",
        "employee_id": "${prefs.getInt("employee_id")}",
      };

      final response = await http.post(
        Uri.parse('${baseurl}fetch_elective_leaves'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch elective leaves');
      }
    } catch (e) {
      throw Exception('Failed to fetch elective leaves: $e');
    }
  }

  static Future<List<dynamic>> fetchApprovedWfh(
      String accountId, String employeeId) async {
    final response = await http.post(
      Uri.parse('${baseurl}fetch_approved_wfh'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_id': accountId,
        'employee_id': employeeId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch approved wfh');
    }
  }

  static Future<List<dynamic>> fetchDeniedWfh(
      String accountId, String employeeId) async {
    final response = await http.post(
      Uri.parse('${baseurl}fetch_cancelled_wfh'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_id': accountId,
        'employee_id': employeeId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch cancelled wfh');
    }
  }

  static Future<void> updateLeaveStatus(
      String leaveId, String leaveStatusId, String comment) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (prefs.getInt('user_id') == null) {
        throw Exception('Employee ID not found in SharedPreferences');
      }

      if (prefs.getInt('user_id') == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final response = await http.post(
        Uri.parse('${baseurl}update_leave'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'account_id': '${prefs.getInt("account_id")}',
          'leave_id': leaveId,
          'leave_status_id': leaveStatusId,
          'comment': comment,
          'updated_by': "${prefs.getInt('user_id') ?? 0}",
        }),
      );

      print({
        'account_id': '${prefs.getInt("account_id")}',
        'leave_id': leaveId,
        'leave_status_id': leaveStatusId,
        'comments': comment,
        'updated_by': "${prefs.getInt('user_id') ?? 0}",
      });
      print(response.body);

      if (response.statusCode == 200) {
        print('Leave status updated!');
      } else {
        throw Exception('Failed to update leave status');
      }
    } catch (e) {
      throw Exception('Failed to update leave status: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchyourownleaves(
      int accountId, int employeeId) async {
    final url = Uri.parse('${baseurl}fetch_own_leaves');

    // Request body
    final Map<String, dynamic> requestBody = {
      'account_id': accountId,
      'employee_id': employeeId,
    };

    try {
      // Sending the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Show success toast
        Fluttertoast.showToast(
            msg: "Leave data fetched successfully!",
            backgroundColor: Colors.green);
        return responseData;
      } else {
        // Handle error response
        Fluttertoast.showToast(
            msg: "Failed to fetch leaves. Try again!",
            backgroundColor: Colors.red);
        return {};
      }
    } catch (e) {
      // Handle any other exceptions
      Fluttertoast.showToast(
          msg: "An error occurred: ${e.toString()}",
          backgroundColor: Colors.red);
      return {};
    }
  }

  static Future<void> addWFH({
    required String accountId,
    required int employeeId,
    required int noOfDays,
    required String reason,
    required String dateFrom,
    required String dateTo,
    required String returnToOffice,
    required int createdBy,
  }) async {
    final url = Uri.parse('${baseurl}add_wfh');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final requestBody = {
      "account_id": '${prefs.getInt("account_id")}',
      "employee_id": employeeId,
      "no_of_days": noOfDays.toString(),
      "reason": reason,
      "date_from": dateFrom,
      "date_to": dateTo,
      "return_to_office": returnToOffice,
      "created_by": createdBy
    };

    print('Request URL: $url');
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      url,
      body: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('Work from home request submitted successfully.');
    } else {
      print('Failed to submit work from home request');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${baseurl}login');

    final requestBody = jsonEncode({
      'email': email,
      'password': password,
    });

    print('Request URL: $url');
    print('Request Body: $requestBody');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        // IMPORTANT: Get the first element of the data list
        final userData = responseData['data'][0];

        return {
          'success': responseData['success'],
          'message': responseData['message'],
          'user_data': userData,
        };
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPriorities() async {
    final response = await http.get(Uri.parse('${baseurl}priority_dropdown'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load priorities');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTaskStatuses() async {
    final response =
        await http.get(Uri.parse('${baseurl}task_status_dropdown'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load task statuses');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('${baseurl}user_dropdown'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<Map<String, dynamic>> addTask({
    required String taskName,
    required List<int> assignedTo,
    required String startDate,
    required String endDate,
    required int priorityId,
    required int taskStatusId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse('${baseurl}add_task'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "task_name": taskName,
        "assigned_to": assignedTo,
        "task_start_date": startDate,
        "task_end_date": endDate,
        "priority_id": priorityId,
        "task_status_id": taskStatusId,
        "created_by": '${prefs.getInt("user_id")}',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add task');
    }
  }

  static Future<List<Task>> fetchAllTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('${baseurl}fetch_all_tasks');

    final int? userId = prefs.getInt("user_id");
    final Map<String, dynamic> requestBody = {
      "user_id": userId // Send as int, not string
    };

    print('📤 Request URL: $url');
    print('📤 Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('📥 Response Status Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        final List tasksJson = jsonResponse['data'];
        return tasksJson.map((e) => Task.fromJson(e)).toList();
      } else {
        throw Exception('Error fetching tasks.');
      }
    } else {
      throw Exception('Failed to load tasks.');
    }
  }

  static Future<void> addTimesheet({
    required int userId,
    required int taskId,
    required int taskStatusId,
    required String workDate,
    required String startTime,
    required String endTime,
    required String comment,
  }) async {
    final url = Uri.parse('${baseurl}add_timesheet');

    final requestBody = {
      "user_id": userId,
      "task_id": taskId,
      "task_status_id": taskStatusId,
      "work_date": workDate,
      "start_time": startTime,
      "end_time": endTime,
      "comment": comment,
    };

    print('🔵 Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    print('🟢 Response Status Code: ${response.statusCode}');
    print('🟢 Response Body: ${response.body}');

    final data = jsonDecode(response.body);
    if (!data['success']) {
      throw Exception(data['message'] ?? 'Failed to add timesheet');
    }
  }

  static Future<List<TimesheetEntry>> fetchTimesheetByUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt("user_id");
    final url = Uri.parse('${baseurl}fetch_timesheet_by_user');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List list = data['data'];
        return list.map((json) => TimesheetEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load timesheet data');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  static Future<List<AttendanceRecord>> fetchAllAttendance({
    int? userId,
    required String date,
  }) async {
    final url = Uri.parse('${baseurl}fetch_all_attendance');

    final Map<String, dynamic> requestBody = {
      'user_id': userId, // Will be null if not selected
      'date': date, // Format: 'yyyy-MM-dd'
    };

    print("🔵 Request Body: ${jsonEncode(requestBody)}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print("🟢 Response Status Code: ${response.statusCode}");
    print("🟢 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => AttendanceRecord.fromJson(e)).toList();
    } else {
      throw Exception('❌ Failed to load attendance: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPlanType() async {
    final response = await http.get(Uri.parse('${baseurl}fetch_plan_type'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load plan type');
    }
  }

  static Future<Map<String, dynamic>> addDailyPlan({
    required int taskId,
    required int userId,
    required String planName,
    required String planDate,
    required int statusId,
    required int priorityId,
    required int planTypeId,
    String? achievements,
    String? comments,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? createdBy = prefs.getInt("user_id");

    final Map<String, dynamic> requestBody = {
      "task_id": taskId,
      "user_id": userId,
      "plan_name": planName,
      "achievements": achievements,
      "comments": comments,
      "plan_date": planDate,
      "status_id": statusId,
      "priority_id": priorityId,
      "plan_type_id": planTypeId,
      "created_by": createdBy
    };

    // 🔍 Print the request body
    print("🔼 Request to add_daily_plan:");
    print(jsonEncode(requestBody));

    final response = await http.post(
      Uri.parse('${baseurl}add_daily_plan'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    // 🔽 Print the response
    print("🔽 Response from add_daily_plan:");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add daily plan');
    }
  }

  static Future<List<DailyPlan>> fetchDailyPlans({
    required String planDate,
    required int userId,
    int? userFilter,
    int? statusId,
  }) async {
    final url = Uri.parse("${baseurl}fetch_daily_plan");

    final requestBody = {
      "plan_date": planDate,
      "user_id": userId,
      "user_filter": userFilter,
      "status_id": statusId,
    };

    print("📤 Request to fetch_daily_plan:");
    print(jsonEncode(requestBody));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['success'] == true && jsonData['data'] != null) {
        return (jsonData['data'] as List)
            .map((item) => DailyPlan.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to fetch daily plans");
    }
  }

  static Future<bool> updateDailyPlanAchievement({
    required int planId,
    required String achievements,
    required int createdBy,
  }) async {
    final url = Uri.parse("${baseurl}update_daily_plan");

    final body = {
      "plan_id": planId,
      "achievements": achievements,
      "achievements_created_by": createdBy,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📤 Update Achievement Request: ${jsonEncode(body)}");
      print("📥 Response (${response.statusCode}): ${response.body}");

      final jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } catch (e) {
      print("❌ Error updating achievement: $e");
      return false;
    }
  }

  static Future<bool> updateDailyPlanComment({
    required int planId,
    required String comments,
    required int statusId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? createdBy = prefs.getInt("user_id");
    final url = Uri.parse("${baseurl}update_daily_plan");

    final body = {
      "plan_id": planId,
      "comments": comments,
      "comment_created_by": createdBy,
      "status_id": statusId
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📤 Update Achievement Request: ${jsonEncode(body)}");
      print("📥 Response (${response.statusCode}): ${response.body}");

      final jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } catch (e) {
      print("❌ Error updating comment: $e");
      return false;
    }
  }
}
