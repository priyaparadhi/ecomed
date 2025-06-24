import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Screens/DashBoardScreen.dart';
import 'package:ecomed/Screens/UserDashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Key for the form
  final _formKey = GlobalKey<FormState>();

  // Variable to toggle password visibility
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      int roleId = prefs.getInt('role_id') ?? 0;

      if ([1, 2, 3, 11].contains(roleId)) {
        // Navigate to HR Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HRDashboardScreen()),
        );
      } else {
        // Navigate to User Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen size for responsive design
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ECOMED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // You can choose your brand color
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 40),
              AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        autofillHints: [AutofillHints.username],
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Email or Phone Number',
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email or phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Password TextField
                      TextFormField(
                        controller: passwordController,
                        autofillHints: [AutofillHints.password],
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          // Toggle visibility icon
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      // Login Button
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                // Call the login API
                                final response = await ApiCalls.login(
                                  emailController.text,
                                  passwordController.text,
                                );

                                // Check if the login was successful
                                if (response['success']) {
                                  // Show success snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Login successful!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // Extract user details from the response
                                  final userData =
                                      response['user_data']; // ✅ correct

                                  // Store user details in SharedPreferences
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setInt(
                                      'user_id', userData['user_id'] ?? 0);
                                  await prefs.setInt('employee_id',
                                      userData['employee_id'] ?? 0);
                                  await prefs.setInt('account_id',
                                      userData['account_id'] ?? 0);
                                  await prefs.setInt(
                                      'role_id', userData['role_id'] ?? 0);

                                  await prefs.setString('first_name',
                                      userData['first_name'] ?? '');
                                  await prefs.setString(
                                      'last_name', userData['last_name'] ?? '');

                                  await prefs.setString(
                                    'profile_path',
                                    userData['profile_path'] ?? '',
                                  );

                                  // await prefs.setString('min_version',
                                  //     userData['min_version'] ?? '');
                                  // String minVersion =
                                  //     userData['min_version'] ?? '';
                                  // String currentVersion = '1.0.0';

                                  // bool needsUpdate = _isUpdateRequired(
                                  //     currentVersion, minVersion);

                                  // if (needsUpdate) {
                                  //   showDialog(
                                  //     context: context,
                                  //     barrierDismissible: false,
                                  //     builder: (context) => AlertDialog(
                                  //       title: Text('Update Required'),
                                  //       content: Text(
                                  //         'A new version of the app is available. Please update to continue.',
                                  //       ),
                                  //       actions: [
                                  //         TextButton(
                                  //           onPressed: () async {
                                  //             const String playStoreUrl =
                                  //                 'https://play.google.com/store/apps/details?id=com.relationrealtech.rrpl&hl=en';
                                  //             const String appStoreUrl =
                                  //                 'https://apps.apple.com/in/app/rrpl-nxt/id6738840059';

                                  //             final Uri playStoreUri =
                                  //                 Uri.parse(playStoreUrl);
                                  //             final Uri appStoreUri =
                                  //                 Uri.parse(appStoreUrl);

                                  //             if (Theme.of(context).platform ==
                                  //                 TargetPlatform.android) {
                                  //               if (await canLaunchUrl(
                                  //                   playStoreUri)) {
                                  //                 await launchUrl(playStoreUri,
                                  //                     mode: LaunchMode
                                  //                         .externalApplication);
                                  //               }
                                  //             } else if (Theme.of(context)
                                  //                     .platform ==
                                  //                 TargetPlatform.iOS) {
                                  //               if (await canLaunchUrl(
                                  //                   appStoreUri)) {
                                  //                 await launchUrl(appStoreUri,
                                  //                     mode: LaunchMode
                                  //                         .externalApplication);
                                  //               }
                                  //             }
                                  //           },
                                  //           child: Text('Update Now'),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   );
                                  //   return;
                                  // }

                                  await prefs.setString('user_email',
                                      userData['user_email'] ?? '');

                                  List<String> permissions =
                                      (userData['permissions']
                                                  as List<dynamic>?)
                                              ?.map((e) => e.toString())
                                              .toList() ??
                                          [];
                                  await prefs.setStringList(
                                      'permissions', permissions);
                                  // Set login status
                                  await prefs.setBool('isLoggedIn', true);

                                  // Navigate to HomeScreen
                                  int roleId = userData['role_id'] ?? 0;

                                  // int channelPartnerId =
                                  //     userData['channel_partner_id'] ?? 0;
                                  // int cpExecutiveId =
                                  //     userData['cp_executive_id'] ?? 0;

                                  if ([1, 2, 3, 11].contains(roleId)) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HRDashboardScreen(),
                                      ),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserDashboardScreen(),
                                      ),
                                    );
                                  }
                                } else {
                                  // Show error snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Login failed: ${response['message']}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Show error snackbar for exceptions
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

// Forgot Password
                      TextButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => ForgotPasswordScreen()),
                          // );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Sign Up Prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          GestureDetector(
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             SignUpSelectionPage()),
                            //   );
                            // },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.poppins(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isUpdateRequired(String current, String minimum) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> minParts = minimum.split('.').map(int.parse).toList();

    for (int i = 0; i < minParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (currentParts[i] < minParts[i]) return true;
      if (currentParts[i] > minParts[i]) return false;
    }
    return false;
  }
}
