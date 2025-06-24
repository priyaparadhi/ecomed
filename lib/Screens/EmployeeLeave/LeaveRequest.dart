import 'dart:io';

import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveBalances.dart';
import 'package:ecomed/Screens/EmployeeLeave/UpcomingLeaves.dart';
import 'package:ecomed/Screens/EmployeeLeave/creditleave.dart';
import 'package:ecomed/styles/DrawerWidget.dart';
import 'package:ecomed/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LeaveRequest extends StatefulWidget {
  @override
  _LeaveRequestState createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic> leaveRequests = [];
  List<dynamic> approvedLeaveRequests = [];
  List<dynamic> deniedLeaveRequests = [];
  List<dynamic> wfhRequests = [];
  List<dynamic> approvedWfhRequests = [];
  List<dynamic> deniedWfhRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _fetchAndStoreEmployeeId();
    fetchData();
    fetchWFHData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController!.index == 3) {
      // When the "Approved" tab is selected
      _fetchApprovedLeaves();
    } else if (_tabController!.index == 5) {
      // When the "Denied" tab is selected
      _fetchDeniedLeaves();
    }
  }
  // Future<void> _loadData() async {
  //   await fetchData();
  //   await fetchWFHData();
  //   _fetchApprovedLeaves();
  //   _fetchDeniedLeaves();
  //   //_fetchApprovedWfh();
  //   setState(() {});
  // }

  Future<void> fetchData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      List<dynamic> data =
          await ApiCalls.fetchAllLeave('${preferences.getInt('account_id')}');
      setState(() {
        leaveRequests = data;
        // approvedLeaveRequests = leaveRequests
        //     .where((leave) => leave['status'] == 'Approved')
        //     .toList();
        // deniedLeaveRequests = leaveRequests
        //     .where((leave) => leave['status'] == 'Denied')
        //     .toList();
      });
    } catch (e) {
      print('Error fetching leave data: $e');
    }
  }

  Future<void> _fetchAndStoreEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      await ApiCalls.fetchAndStoreEmployeeId();
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> fetchWFHData() async {
    try {
      List<dynamic> data = await ApiCalls.fetchAllWFH();
      setState(() {
        wfhRequests = data;
      });
    } catch (e) {
      print('Error fetching WFH data: $e');
    }
  }

  Future<void> _fetchApprovedLeaves() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('employee_id');
      print('Retrieved employee ID: $employeeId');
      if (employeeId != null) {
        List<dynamic> leavesData = await ApiCalls.fetchApprovedLeaves(
            '${prefs.getInt("account_id")}', employeeId);
        List<dynamic> wfhData = await ApiCalls.fetchApprovedWfh(
            '${prefs.getInt("account_id")}', employeeId);
        setState(() {
          approvedLeaveRequests = leavesData;
          approvedWfhRequests = wfhData;
        });
        print('Approved leave requests: $approvedLeaveRequests');
        print('Approved WFH requests: $approvedWfhRequests');
      } else {
        print('No employee ID found');
      }
    } catch (e) {
      print('Error fetching approved requests: $e');
    }
  }

  Future<void> _fetchDeniedLeaves() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('employee_id');
      print('Retrieved employee ID: $employeeId');
      if (employeeId != null) {
        List<dynamic> data = await ApiCalls.fetchDeniedLeaves(
            '${prefs.getInt("account_id")}', employeeId);
        List<dynamic> wfhData = await ApiCalls.fetchDeniedWfh(
            '${prefs.getInt("account_id")}', employeeId);
        setState(() {
          deniedLeaveRequests = data;
          deniedWfhRequests = wfhData;
        });
        print('Denied leave requests: $deniedLeaveRequests');
        print('Denied WFH requests: $deniedWfhRequests');
      } else {
        print('No employee ID found');
      }
    } catch (e) {
      print('Error fetching denied leaves: $e');
    }
  }

  // Future<void> _fetchApprovedWfh() async {
  //   try {
  //     List<dynamic> data = await ApiCalls.fetchApprovedWfh('1', '1');
  //     setState(() {
  //       approvedWfhRequests = data;
  //     });
  //   } catch (e) {
  //     print('Error fetching approved leaves: $e');
  //   }
  // }

  Future<void> openAttachment(String attachmentUrl) async {
    if (attachmentUrl == null || attachmentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attachment URL is empty'),
        ),
      );
      return;
    }

    String fullUrl =
        'https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/$attachmentUrl';
    String fileExtension = attachmentUrl.split('.').last;

    if (fileExtension == 'pdf') {
      String filePath = await _downloadFile(fullUrl);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(filePath: filePath),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Attachment'),
            ),
            body: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(fullUrl)),
            ),
          ),
        ),
      );
    }
  }

  Future<String> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/temp.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        drawer: DrawerWidget(),
        appBar: AppBar(
          title: Text('Leave List'),
          actions: [
            Tooltip(
              message: 'Credit / Debit Leave',
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CreditLeaveDialog();
                    },
                  );
                },
              ),
            ),
            Tooltip(
              message: 'See Calendar',
              child: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  _selectDate(context);
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(text: 'Leaves'),
                Tab(text: 'Leave Balances'),
                Tab(text: 'WFH'),
                Tab(text: 'Approved'),
                Tab(text: 'Upcoming Leaves'),
                Tab(text: 'Denied'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLeaveRequestList(leaveRequests),
            LeaveBalancePage(),
            _buildWFHRequestList(wfhRequests),
            _buildApprovedRequestList(
                [...approvedLeaveRequests, ...approvedWfhRequests]),
            UpcomingLeaveRequestPage(),
            _buildDeniedRequestList(
                [...deniedLeaveRequests, ...deniedWfhRequests]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {}
  }

  Widget _buildLeaveRequestList(List<dynamic> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No data found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildLeaveRequestCard(requests[index], index);
      },
    );
  }

  Widget _buildLeaveRequestCard(dynamic leaveRequest, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Color.fromARGB(255, 206, 236, 255),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leaveRequest['employee_name'] ?? 'Unknown Employee',
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      leaveRequest['request_type'] ?? 'Unknown Request',
                      style: GoogleFonts.getFont(
                        'Lato',
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    leaveRequest['leave_status'] ?? 'Pending',
                    style: GoogleFonts.getFont(
                      'Lato',
                      textStyle: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From Date',
                      style: GoogleFonts.getFont(
                        'Lato',
                      ),
                    ),
                    Text(
                      leaveRequest['date_from'] ?? '',
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To Date',
                      style: GoogleFonts.getFont(
                        'Lato',
                      ),
                    ),
                    Text(
                      leaveRequest['date_to'] ?? '',
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leave Days',
                      style: GoogleFonts.getFont(
                        'Lato',
                      ),
                    ),
                    Text(
                      leaveRequest['no_of_days'] ?? '',
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Return to Office Date',
                      style: GoogleFonts.getFont(
                        'Lato',
                      ),
                    ),
                    Text(
                      leaveRequest['return_to_office'] ?? '',
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason for Leave:',
                  style: GoogleFonts.getFont(
                    'Lato',
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  leaveRequest['reason'] ?? "Reason not provided",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.getFont(
                    'Lato',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason for Approving or Rejecting:',
                  style: GoogleFonts.getFont(
                    'Lato',
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  leaveRequest['comment'] ?? "Reason not provided",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.getFont(
                    'Lato',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showStatusDialog(
                        (leaveRequest['leave_id'] ?? 0).toString(), '1', index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Approve',
                    style: GoogleFonts.getFont(
                      'Lato',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showStatusDialog(
                        (leaveRequest['leave_id'] ?? 0).toString(), '2', index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 207, 92, 69),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Reject',
                    style: GoogleFonts.getFont(
                      'Lato',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(String leaveId, String status, int index) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status == '1' ? 'Approve Leave ' : 'Reject Leave'),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(hintText: "Enter reason"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                String comment = reasonController.text;
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a reason'),
                    ),
                  );
                } else {
                  _updateLeaveStatus(leaveId, status, comment, index);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////

  Widget _buildWFHRequestList(List<dynamic> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No data found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildWFHRequestCard(requests[index]);
      },
    );
  }

  void _updateWFHStatus(String wfhId, String status, String comment) {
    ApiCalls.updateWFHStatus(wfhId, status, comment).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == '1'
              ? 'WFH request approved successfully'
              : 'WFH request rejected successfully'),
        ),
      );
      fetchWFHData();
    }).catchError((error) {
      print('Error updating WFH request status: $error');
    });
  }

  Widget _buildWFHRequestCard(dynamic wfhRequest) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Color.fromARGB(255, 206, 236, 255),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wfhRequest['employee_name'] ?? 'Unknown Employee',
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      wfhRequest['designation'] ?? 'Unknown Employee',
                      style: GoogleFonts.getFont(
                        'Lato',
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Work From Home',
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From Date',
                      style: GoogleFonts.getFont(
                        'Lato',
                      ),
                    ),
                    Text(
                      wfhRequest['date_from'],
                      style: GoogleFonts.getFont(
                        'Lato',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To Date'),
                    Text(
                      wfhRequest['date_to'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WFH Days'),
                    Text(
                      wfhRequest['no_of_days'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Return to Office Date:'),
                Text(
                  wfhRequest['return_to_office'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason:'),
                SizedBox(height: 4.0),
                Text(
                  wfhRequest['reason'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showWfhStatusDialog(wfhRequest['wfh_id'].toString(), '1');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showWfhStatusDialog(wfhRequest['wfh_id'].toString(), '2');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 207, 92, 69),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  void _showWfhStatusDialog(String wfhId, String status) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status == '1' ? 'Approve WFH' : 'Reject WFH'),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(hintText: "Enter reason"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                String comment = reasonController.text;
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a reason'),
                    ),
                  );
                } else {
                  ApiCalls.updateWFHStatus(wfhId, status, comment).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(status == '1'
                            ? 'WFH approved successfully'
                            : 'WFH rejected successfully'),
                      ),
                    );
                    Navigator.of(context).pop();
                    fetchWFHData();
                  }).catchError((error) {
                    print('Error updating WFH status: $error');
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateLeaveStatus(
      String leaveId, String status, String comment, int index) {
    ApiCalls.updateLeaveStatus(leaveId, status, comment).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == '1'
              ? 'Leave approved successfully'
              : 'Leave rejected successfully'),
        ),
      );
      fetchData();
    }).catchError((error) {
      print('Error updating leave status: $error');
    });
  }

//   void _removeItemWithAnimation(int index) {
//     final removedItem = leaveRequests.removeAt(index);
//     _listKey.currentState?.removeItem(
//       index,
//       (context, animation) =>
//           _buildLeaveRequestCard(removedItem, index, animation),
//       duration: Duration(milliseconds: 300),
//     );
//   }
// }

//--------------------------------------------------------------------------------------------//
  Widget _buildApprovedRequestList(List<dynamic> requests) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildApprovedRequestCard(requests[index]);
      },
    );
  }

  Widget _buildApprovedRequestCard(dynamic approvedRequest) {
    bool isLeaveRequest = approvedRequest.containsKey('request_type');

    return Appstyles.cardStyle(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approvedRequest['employee_name'] ?? 'null',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(approvedRequest['designation'] ?? 'Unknown Employee'),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Approved',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 76, 175, 172),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From Date'),
                    Text(
                      approvedRequest['date_from'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To Date'),
                    Text(
                      approvedRequest['date_to'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLeaveRequest
                          ? approvedRequest['request_type']
                          : 'WFH Request',
                    ),
                    Text(
                      approvedRequest['no_of_days'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Return to Office Date:'),
                Text(
                  approvedRequest['return_to_office'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason:'),
                SizedBox(height: 4.0),
                Text(
                  approvedRequest['reason'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 16.0),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text('Comment:'),
            //     SizedBox(height: 4.0),
            //     Text(
            //       approvedRequest['comment'],
            //       textAlign: TextAlign.left,
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

//---------------------------------------------------------------------------------------------------//
  Widget _buildDeniedRequestList(List<dynamic> requests) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildDeniedRequestCard(requests[index]);
      },
    );
  }

  Widget _buildDeniedRequestCard(dynamic deniedRequest) {
    bool isLeaveRequest = deniedRequest.containsKey('request_type');
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Color.fromARGB(255, 206, 236, 255),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deniedRequest['employee_name'] ?? "null",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(deniedRequest['designation']),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Denied',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 214, 122, 122),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From Date'),
                    Text(
                      deniedRequest['date_from'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To Date'),
                    Text(
                      deniedRequest['date_to'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLeaveRequest
                          ? deniedRequest['request_type']
                          : 'WFH Request',
                    ),
                    Text(
                      deniedRequest['no_of_days'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Return to Office Date:'),
                Text(
                  deniedRequest['return_to_office'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason:'),
                SizedBox(height: 4.0),
                Text(
                  deniedRequest['reason'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String filePath;

  PdfViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
