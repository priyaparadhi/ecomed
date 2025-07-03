import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/LeaveModel.dart';
import 'package:ecomed/Models/WFHModel.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveForm.dart';
import 'package:ecomed/Screens/EmployeeLeave/WfhForm.dart';
import 'package:ecomed/Screens/EmployeeLeave/leavehistory.dart';
import 'package:ecomed/styles/DrawerWidget.dart';
import 'package:ecomed/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: DrawerWidget(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Leave Tracker', style: GoogleFonts.lato()),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Stack(
              children: [
                Container(
                  color: Appstyles.tabcolor,
                  child: const TabBar(
                    isScrollable: false,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Leave'),
                      Tab(text: 'WFH'),
                      Tab(text: 'Holidays'),
                    ],
                  ),
                ),
                // Overlay dividers manually (adjust left offsets based on screen width / tab count)
                Positioned(
                  left: MediaQuery.of(context).size.width / 3,
                  top: 6,
                  bottom: 6,
                  child: Container(width: 1, color: Colors.grey),
                ),
                Positioned(
                  left: (MediaQuery.of(context).size.width / 3) * 2,
                  top: 6,
                  bottom: 6,
                  child: Container(width: 1, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            LeaveSection(),
            WorkFromHomeForm(),
            HolidayCalendarSection(),
            // AttendanceScreen(),
          ],
        ),
      ),
    );
  }

//   Widget _buildTabItem(String label) {
//   return Expanded(
//     child: Tab(
//       child: Center(
//         child: Text(
//           label,
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//     ),
//   );
// }

// Widget _verticalDivider() {
//   return Container(
//     height: kToolbarHeight,
//     width: 2,
//     color: Appstyles.primaryColor,
//   );
// }
}

class LeaveSection extends StatefulWidget {
  @override
  _LeaveSectionState createState() => _LeaveSectionState();
}

class _LeaveSectionState extends State<LeaveSection> {
  late Future<Map<String, dynamic>> futureCasualLeaves;
  late Future<Map<String, dynamic>> futureSickLeaves;
  late Future<Map<String, dynamic>> futureElectiveLeaves;
  Map<String, dynamic> leavedataemp = {};
  Future<List<LeaveHistory>>? futureLeaveHistory;
  Future<List<WfhHistory>>? futureWfhHistory;

  @override
  void initState() {
    //_fetchAndStoreEmployeeId();
    super.initState();
    futureCasualLeaves = ApiCalls.fetchCasualLeaves();
    futureSickLeaves = ApiCalls.fetchSickLeaves();
    futureElectiveLeaves = ApiCalls.fetchElectiveLeaves();
    callFunction();
  }

  void callFunction() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    try {
      // ✅ Fetch employee_id and account_id from SharedPreferences
      int? employeeId = sharedPreferences.getInt("employee_id");
      int? accountId = sharedPreferences.getInt("account_id");

      if (employeeId == null || accountId == null) {
        print("employee_id or account_id not found in SharedPreferences.");
        return;
      }

      // Refresh leave futures
      setState(() {
        futureCasualLeaves = ApiCalls.fetchCasualLeaves();
        futureSickLeaves = ApiCalls.fetchSickLeaves();
        futureElectiveLeaves = ApiCalls.fetchElectiveLeaves();
        futureLeaveHistory = ApiCalls.fetchSingleEmployeeLeave();
        //futureWfhHistory = ApiCalls.fetchSingleEmployeeWFH();
      });

      // ✅ Call the API with the integer values
      leavedataemp = await ApiCalls.fetchyourownleaves(accountId, employeeId);

      print("data here $leavedataemp");
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<String> _fetchAndStoreEmployeeId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int? employeeId = prefs.getInt('employee_id');

  //   if (employeeId == null) {
  //     await ApiCalls.fetchAndStoreEmployeeId();
  //     employeeId = prefs.getInt('employee_id');
  //   }
  //   if (employeeId == null) {
  //     throw Exception('Employee ID not found after fetching and storing.');
  //   }
  //   return employeeId;
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([
        futureCasualLeaves,
        futureSickLeaves,
        futureElectiveLeaves,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          Map<String, dynamic>? casualLeaves = snapshot.data![0];
          Map<String, dynamic>? sickLeaves = snapshot.data![1];
          Map<String, dynamic>? electiveLeaves = snapshot.data![2];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Balance',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _modernLeaveCard(
                        "Casual",
                        casualLeaves['booked_casual_leaves'],
                        casualLeaves['balanced_casual_leaves'],
                        Icons.weekend,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _modernLeaveCard(
                        "Sick",
                        sickLeaves['booked_sick_leaves'],
                        sickLeaves['balanced_sick_leaves'],
                        Icons.healing,
                        Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _modernLeaveCard(
                        "Elective",
                        electiveLeaves['booked_elective_leaves'],
                        electiveLeaves['balanced_elective_leaves'],
                        Icons.event,
                        Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add, size: 18),
                    label: Text(
                      'Apply Leave',
                      style: GoogleFonts.lato(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaveForm(
                            refresh: () {
                              callFunction();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                LeaveHistorySection(
                  futureLeaveHistory: futureLeaveHistory ?? Future.value([]),
                  //futureWfhHistory: futureWfhHistory ?? Future.value([]),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        return SizedBox();
      },
    );
  }

  Widget _modernLeaveCard(
    String title,
    dynamic booked,
    dynamic balance,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.arrow_downward, size: 12, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                booked?.toString() ?? '0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 12, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                balance?.toString() ?? '0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method
}

class HolidayCalendarSection extends StatelessWidget {
  final List<Holiday> holidays = [
    Holiday(name: 'Republic Day', date: '2025-01-26', day: 'Sunday'),
    Holiday(
        name: 'Maha Shivaratri',
        date: '2025-02-26',
        day: 'Wednesday',
        isElective: true),
    Holiday(name: 'Holi', date: '2025-03-14', day: 'Friday'),
    Holiday(
        name: 'Good Friday',
        date: '2025-04-18',
        day: 'Friday',
        isElective: true),
    Holiday(name: 'Maharashtra Day', date: '2025-05-01', day: 'Thursday'),
    Holiday(
        name: 'Buddha Purnima',
        date: '2025-05-12',
        day: 'Monday',
        isElective: true),
    Holiday(
        name: 'Rakhi', date: '2025-08-09', day: 'Saturday', isElective: true),
    Holiday(name: 'Independence Day', date: '2025-08-15', day: 'Friday'),
    Holiday(name: 'Ganesh Chaturthi', date: '2025-08-27', day: 'Wednesday'),
    Holiday(
        name: 'Eid e Milad',
        date: '2025-09-05',
        day: 'Friday',
        isElective: true),
    Holiday(name: 'Gandhi Jayanti', date: '2025-10-02', day: 'Thursday'),
    Holiday(name: 'Diwali', date: '2025-10-20', day: 'Monday'),
    Holiday(name: 'Diwali', date: '2025-10-21', day: 'Tuesday'),
    Holiday(
        name: 'Guru Nanak Jayanti',
        date: '2025-11-05',
        day: 'Wednesday',
        isElective: true),
    Holiday(
        name: 'Christmas Day',
        date: '2025-12-25',
        day: 'Thursday',
        isElective: true),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children:
            holidays.map((holiday) => HolidayCard(holiday: holiday)).toList(),
      ),
    );
  }
}

class Holiday {
  final String name;
  final String date;
  final String day;
  final bool isElective;

  Holiday(
      {required this.name,
      required this.date,
      required this.day,
      this.isElective = false});
}

class HolidayCard extends StatelessWidget {
  final Holiday holiday;

  const HolidayCard({Key? key, required this.holiday}) : super(key: key);

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return parsedDate.day.toString();
    } catch (_) {
      return "";
    }
  }

  String _getMonthAbbreviation(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.MMM().format(date); // Jan, Feb, Mar, etc.
    } catch (_) {
      return '';
    }
  }

  String _getFirstThreeWords(String text) {
    List<String> words = text.split('');
    // Ensure we don't exceed the number of words available
    return words.take(3).join('');
  }

  @override
  Widget build(BuildContext context) {
    String initials = '';
    holiday.name.split(' ').forEach((word) {
      initials += word[0].toUpperCase();
    });

    return Appstyles.cardStyle(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Container
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //   decoration: BoxDecoration(
            //     color: Colors.blue.shade100,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Text(
            //     holiday.day,
            //     style: const TextStyle(
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.blue,
            //     ),
            //   ),
            // ),
            //  const SizedBox(height: 12),
            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date circle
                Container(
                    width: MediaQuery.of(context).size.width *
                        0.14, // 20% of screen width
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getMonthAbbreviation(
                              holiday.date), // Shows Jan, Feb, etc.
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          _formatDate(holiday.date), // eg: 25
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          _getFirstThreeWords(holiday.day),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ))),
                const SizedBox(width: 12),
                // Name and elective tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holiday.name,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
//                    SizedBox(
//   width: MediaQuery.of(context).size.width * 0.2,  // 20% of screen width
//   height: MediaQuery.of(context).size.height * 0.05, // 5% of screen height
// ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        holiday.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Date on top right corner
                if (holiday.isElective)
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Elective",
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
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
}

class LeaveCard extends StatelessWidget {
  final String title;
  final int balancedLeaves;
  final int bookedLeaves;
  Function refresh;

  LeaveCard({
    Key? key,
    required this.title,
    required this.balancedLeaves,
    required this.bookedLeaves,
    required this.refresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => LeaveForm()),
      //   );
      // },
      child: Container(
        width: 300,
        height: 160,
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_note, color: Colors.blue),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.lato(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Balance',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 16.0),
                            ),
                            Text(
                              '$balancedLeaves',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                color: Colors.green,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Expanded(
                      //   child: Column(
                      //     children: [
                      //       Text(
                      //         'Booked',
                      //         textAlign: TextAlign.center,
                      //         style: GoogleFonts.lato(fontSize: 16.0),
                      //       ),
                      //       Text(
                      //         '$bookedLeaves',
                      //         textAlign: TextAlign.center,
                      //         style: GoogleFonts.lato(
                      //           color: Colors.red,
                      //           fontSize: 20.0,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 1.0),
                  Center(
                    child: SizedBox(
                      width: 100.0,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LeaveForm(
                                      refresh: () => refresh(),
                                    )),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: Text(
                          'Apply',
                          style: TextStyle(fontSize: 12.0),
                        ),
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

// class WfhHistorySection extends StatefulWidget {
//   @override
//   _WfhHistorySectionState createState() => _WfhHistorySectionState();
// }

// class _WfhHistorySectionState extends State<WfhHistorySection> {
//   late Future<List<WfhHistory>> futureWfhHistory;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAndStoreEmployeeId();
//     futureWfhHistory = ApiCalls.fetchSingleEmployeeWFH();
//   }

//   Future<void> _fetchAndStoreEmployeeId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? employeeId = prefs.getString('employee_id');

//     // Print for debugging
//     print("Stored employee ID: $employeeId");

//     if (employeeId == null) {
//       await ApiCalls.fetchAndStoreEmployeeId('1100');
//       employeeId = prefs
//           .getString('employee_id'); // Fetch it again after attempting to store
//       print("Employee ID after fetching and storing: $employeeId");
//     } else {
//       print('Employee ID already found in SharedPreferences: $employeeId');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<WfhHistory>>(
//       future: futureWfhHistory,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           List<WfhHistory>? wfhHistory = snapshot.data;
//           return Column(
//             children:
//                 wfhHistory!.map((wfh) => WfhHistoryCard(wfh: wfh)).toList(),
//           );
//         } else if (snapshot.hasError) {
//           return Text("${snapshot.error}");
//         }
//         return CircularProgressIndicator();
//       },
//     );
//   }
// }


