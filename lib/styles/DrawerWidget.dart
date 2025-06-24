import 'dart:io';

import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Screens/Authentication/Logout.dart';
import 'package:ecomed/Screens/Authentication/loginPage.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveRequest.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveTracker.dart';
import 'package:ecomed/Screens/DashBoardScreen.dart';
import 'package:ecomed/Screens/UserDashboardScreen.dart';
import 'package:ecomed/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String profileUrl = '';
  int roleId = 0;
  bool customerSection = false;

  @override
  void initState() {
    getProfileImage();
    roleid();
    // TODO: implement initState
    super.initState();
  }

  void roleid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? storedRoleId = sharedPreferences.getInt("role_id");
    print(
        "role id >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$storedRoleId");

    // setState(() {
    //   roleId = storedRoleId ?? 0;
    //   customerSection = (storedRoleId == 5); // Corrected assignment
    // });

    setState(() {
      roleId = storedRoleId ?? 0;

      // Set customerSection to true if roleId is 5 or 2
      customerSection = (roleId == 5 || roleId == 2);

      // Add logic here if roleId is 1 or 2
      if (roleId == 1 || roleId == 2) {
        // Your additional logic here
      }
    });
  }

  void getProfileImage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      profileUrl = sharedPreferences.getString('profile_path') ?? "";
      // true if role_id is 5, else false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6,
      // shadowColor: Colors.blue.shade900,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Appstyles
                .secondaryColor, // You can change this to any color you prefer
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ProfilePage(
                          //       name:
                          //           "${SharedPreferencesService.getString("user_full_name")}",
                          //       profileUrl:
                          //           "${ApiCalls.basestorage}$profileUrl",
                          //     ),
                          //   ),
                          // );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: profileUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    "${ApiCalls.basestorage}$profileUrl",
                                    width: 78,
                                    height: 78,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const SizedBox(
                                        width: 78,
                                        height: 78,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.account_circle,
                                          size: 78, color: Colors.blue);
                                    },
                                  ),
                                )
                              : const Icon(Icons.account_circle,
                                  size: 76, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   SharedPreferencesService.getString("user_full_name") ??
                      //       "",
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SizedBox(
          //   height: MediaQuery.of(context).size.width * 0.1,
          // ),
          ListTile(
            title: const Text("Home"),
            leading: const Icon(
              Icons.home,
              color: Colors.orange, // Set your desired color here
            ),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int roleId = prefs.getInt('role_id') ?? 0;

              Widget targetScreen;
              if ([1, 2, 3, 11].contains(roleId)) {
                targetScreen = HRDashboardScreen();
              } else {
                targetScreen = UserDashboardScreen();
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => targetScreen),
                (Route<dynamic> route) => false, // Removes all previous routes
              );
            },
          ),

          // Visibility(
          //   visible: roleId == 1,
          //   child:
          // ListTile(
          //   title: const Text("Projects"),
          //   leading: const Icon(Icons.add_box),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ProjectManagementScreen(),
          //       ),
          //     );
          //   },
          // ),
          // Visibility(
          //   visible: !customerSection, // Show only if customerSection is false
          //   child: ListTile(
          //     title: const Text("Attendance"),
          //     leading: const Icon(
          //       Icons.edit_document,
          //       color: Colors.red, // Set your desired color here
          //     ),
          //     onTap: () {
          //       Navigator.pop(context);

          //       Navigator.pushAndRemoveUntil(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => AttendanceReportPage()),
          //         (Route<dynamic> route) =>
          //             route.settings.name == '/HomeScreen' || route.isFirst,
          //       );
          //     },
          //   ),
          // ),

          // Visibility(
          //   visible: roleId == 1,
          //   child: ListTile(
          //     title: const Text("Project"),
          //     leading: Icon(
          //       Icons.add_task,
          //       color: Colors.purple, // or Colors.indigo, etc.
          //     ),
          //     onTap: () {
          //       //       Navigator.push(
          //       //   context,
          //       //   MaterialPageRoute(
          //       //     builder: (context) => ProjectManagementScreen(),
          //       //   ),
          //       // );

          //       Navigator.pushAndRemoveUntil(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => ProjectManagementScreen()),
          //         (Route<dynamic> route) =>
          //             route.settings.name == '/HomeScreen' || route.isFirst,
          //       );
          //     },
          //   ),
          // ),
          // Visibility(
          //   visible: (roleId==1),
          //   child: ListTile(
          //     title: const Text("PM Sheet"),
          //     leading: const Icon(Icons.manage_search),
          //     onTap: () {
          //       Navigator.pop(context);
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => ProjectManagerSheet(planid: null,)));
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: const Text("Daily plans"),
          //   leading: const Icon(
          //     Icons.manage_search,
          //     color: Colors.green, // Set your desired color here
          //   ),
          //   onTap: () {
          //     Navigator.pop(context);
          //     // Navigator.push(
          //     //     context,
          //     //     MaterialPageRoute(
          //     // builder: (context) => DailyTasks(
          //     //       title: "Daily PLans",
          //     //       today: true,
          //     //     )));

          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const DailyTasks(
          //                 title: "Daily PLans",
          //                 today: true,
          //               )),
          //       (Route<dynamic> route) =>
          //           route.settings.name == '/HomeScreen' || route.isFirst,
          //     );
          //   },
          // ),
          // Visibility(
          //   visible: !customerSection, // Hide if customerSection is true
          //   child: ListTile(
          //     title: const Text("Project Overview"),
          //     leading: const Icon(
          //       Icons.edit_document,
          //       color: Colors.grey, // Set your desired color here
          //     ),
          //     onTap: () {
          //       Navigator.pop(context);
          //       // Navigator.push(
          //       //     context,
          //       //     MaterialPageRoute(
          //       // builder: (context) => DailyTasks(
          //       //       title: "Daily PLans",
          //       //       today: true,
          //       //     )));

          //       Navigator.pushAndRemoveUntil(
          //         context,
          //         MaterialPageRoute(builder: (context) => ProjectDashboard()),
          //         (Route<dynamic> route) =>
          //             route.settings.name == '/HomeScreen' || route.isFirst,
          //       );
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: const Text("Face verification"),
          //   leading: const Icon(Icons.face),
          //   onTap: () async {
          //     Navigator.pop(context);
          //     SharedPreferences prefs = await SharedPreferences.getInstance();
          //     int? employeeId = prefs.getInt('employee_id');

          //     if (employeeId == null) {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => FaceVerificationPage()),
          //       );
          //     } else {
          //       Navigator.pushReplacement(
          //         context,
          //         MaterialPageRoute(builder: (context) => CheckInPage()),
          //       );
          //     }
          //   },
          // ),

          ExpansionTile(
            title: Text("CRM"),
            leading: const Icon(
              Icons.person_outline_outlined,
              color: Colors.blueAccent, // Set your desired color here
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: ListTile(
                  title: const Text(
                    "Enquiries",
                    style: TextStyle(fontSize: 15),
                  ),
                  leading: const Icon(
                    Icons.question_answer_outlined,
                    color: Colors.lightBlue,
                    size: 20,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => MyEnquire()));

                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const MyEnquire()),
                    //   (Route<dynamic> route) =>
                    //       route.settings.name == '/HomeScreen' || route.isFirst,
                    // );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: ListTile(
                  title: const Text("Contact",
                      style: TextStyle(
                        fontSize: 15,
                      )),
                  leading: const Icon(Icons.contact_page_rounded,
                      color: Colors.lightBlue, size: 20),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => ContactsPage()));

                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ContactsPage()),
                    //   (Route<dynamic> route) =>
                    //       route.settings.name == '/HomeScreen' || route.isFirst,
                    // );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: ListTile(
                  title:
                      const Text("Companies", style: TextStyle(fontSize: 15)),
                  leading: const Icon(
                    Icons.apartment_outlined,
                    size: 20,
                    color: Colors.lightBlue,
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => CompaniesPage()));

                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => CompaniesPage()),
                    //   (Route<dynamic> route) =>
                    //       route.settings.name == '/HomeScreen' || route.isFirst,
                    // );
                  },
                ),
              ),
            ],
          ),

          // Visibility(
          //   visible: roleId == 1,
          //   child:
          Visibility(
            visible: !customerSection, // Hide if customerSection is true
            child: ListTile(
              title: const Text("My Leaves "),
              leading: const Icon(
                Icons.work,
                color: Colors.teal,
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => LeaveTracker()));

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LeaveTracker()),
                  (Route<dynamic> route) =>
                      route.settings.name == '/HomeScreen' || route.isFirst,
                );
              },
            ),
          ),

          Visibility(
            visible: roleId == 1,
            child: ListTile(
              title: const Text("Leave Management "),
              leading: const Icon(
                Icons.work,
                color: Colors.teal,
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaveRequest()));
              },
            ),
          ),

          //lms navigation
          // ExpansionTile(
          //   title: Text("LMS"),
          //   leading: Icon(Icons.person_outline_outlined),
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
          //       child: ListTile(
          //           title: const Text(
          //             "LMS Admin",
          //             style: TextStyle(fontSize: 15),
          //           ),
          //           leading: const Icon(
          //             Icons.manage_accounts,
          //             size: 20,
          //           ),
          //           onTap: () {
          //             Get.offAll(() => AdminDashboardScreen(),
          //                 predicate: (route) =>
          //                     route.settings.name == '/HomeScreen' ||
          //                     route.isFirst);
          //           }),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
          //       child: ListTile(
          //           title:
          //               const Text("LMS User", style: TextStyle(fontSize: 15)),
          //           leading: const Icon(Icons.person, size: 20),
          //           onTap: () {
          //             Get.offAll(() => HomepageScreen(),
          //                 predicate: (route) =>
          //                     route.settings.name == '/HomeScreen' ||
          //                     route.isFirst);
          //           }),
          //     ),
          //   ],
          // ),

          // ListTile(
          //   title: const Text("Request to Delete Account "),
          //   leading: const Icon(Icons.delete),
          //   onTap: () async {
          //     // if (await canLaunchUrl(Uri.parse(
          //     //     "https://portalwiz.com/privacy-policy/#deletion"))) {
          //     //   launchUrl(Uri.parse(
          //     //       "https://portalwiz.com/privacy-policy/#deletion"));
          //     // } else {
          //     //   Fluttertoast.showToast(msg: "Sorry Please try again Later");
          //     // }

          //     final confirm = await showDialog<bool>(
          //       context: context,
          //       builder: (context) => AlertDialog(
          //         title: const Text("Confirm Deletion"),
          //         content: const Text(
          //             "Are you sure you want to request account deletion?"),
          //         actions: [
          //           TextButton(
          //             onPressed: () => Navigator.pop(context, false),
          //             child: const Text("Cancel"),
          //           ),
          //           TextButton(
          //             onPressed: () => Navigator.pop(context, true),
          //             child: const Text("Yes, Request"),
          //           ),
          //         ],
          //       ),
          //     );

          //     if (confirm == true) {
          //       // You can optionally hit an API or perform logic here

          //       Fluttertoast.showToast(
          //         msg: "Your delete request has been received and forwarded.",
          //         toastLength: Toast.LENGTH_SHORT,
          //         gravity: ToastGravity.BOTTOM,
          //         backgroundColor: Colors.red,
          //         textColor: Colors.white,
          //         fontSize: 14.0,
          //       );

          //       await Future.delayed(
          //           const Duration(seconds: 3)); // Wait before next toast

          //       Fluttertoast.showToast(
          //         msg: "You will receive a follow-up response via email.",
          //         toastLength: Toast.LENGTH_SHORT,
          //         gravity: ToastGravity.BOTTOM,
          //         backgroundColor: Colors.red,
          //         textColor: Colors.white,
          //         fontSize: 14.0,
          //       );
          //       // Or use Fluttertoast instead
          //       // Fluttertoast.showToast(
          //       //   msg: "Your delete request is submitted and will be approved in time.",
          //       //   toastLength: Toast.LENGTH_LONG,
          //       //   gravity: ToastGravity.BOTTOM,
          //       // );
          //     }
          //   },
          // ),

          ListTile(
            title: const Text("Log Out"),
            leading: const Icon(
              Icons.logout_outlined,
              color: Colors.redAccent, // Set your desired color here
            ),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Logout()));
            },
          ),
          ListTile(
            title: const Text("Version 1.1.0(91)"),
            leading: const Icon(
              Icons.mobile_friendly,
              color: Color.fromARGB(
                  255, 230, 220, 42), // Set your desired color here
            ),
            onTap: () async {
              showAboutDialog(context: context);
            },
          ),
        ],
      ),
    );
  }
}
