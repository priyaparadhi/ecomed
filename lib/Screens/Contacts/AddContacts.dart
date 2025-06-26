
// import 'package:ecomed/ApiCalls/ApiCalls.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // class AddContactForm extends StatefulWidget {
// //   final VoidCallback onContactAdded;
// //   AddContactForm({required this.onContactAdded});
// //   @override
// //   _AddContactFormState createState() => _AddContactFormState();
// // }
// class AddContactForm extends StatefulWidget {
//   final int? contactId; // Optional contactId

//   AddContactForm({
//     this.contactId, // optional named parameter
//     Key? key,
//   }) : super(key: key);

//   @override
//   _AddContactFormState createState() => _AddContactFormState();
// }

// class _AddContactFormState extends State<AddContactForm> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for the form fields
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController alternatePhoneController =
//       TextEditingController();
//   final TextEditingController alternateEmailController =
//       TextEditingController();
//   final TextEditingController gstNumberController = TextEditingController();
//   final TextEditingController panNoController = TextEditingController();
//   final TextEditingController displayNameController = TextEditingController();
//   final TextEditingController designationController = TextEditingController();
//   final TextEditingController address1Controller = TextEditingController();
//   final TextEditingController address2Controller = TextEditingController();
//   final TextEditingController cityController = TextEditingController();
//   final TextEditingController stateController = TextEditingController();
//   final TextEditingController pinController = TextEditingController();
//   final TextEditingController countryController = TextEditingController();

//   int? userId;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserId();
//     binddata();
//   }

//   void binddata() async {
//     if (widget.contactId == null) return;

//     final result = await ApiCalls.fetchContactDetails(
//       accountId: "${SharedPreferencesService.getInt("account_id")}",
//       contactId: widget.contactId!,
//     );

//     if (result != null) {
//       // Use null-aware assignment to avoid assigning null values
//       firstNameController.text = result['first_name'] ?? '';
//       lastNameController.text = result['last_name'] ?? '';
//       emailController.text = result['email'] ?? '';
//       phoneController.text = result['phone']?.toString() ?? '';
//       alternatePhoneController.text =
//           result['alternate_phone']?.toString() ?? '';
//       alternateEmailController.text = result['alternate_email'] ?? '';
//       gstNumberController.text = result['gst_number'] ?? '';
//       panNoController.text = result['pan_no']?.toString() ?? "";
//       displayNameController.text = result['display_name'] ?? '';
//       designationController.text = result['designation'] ?? '';
//       address1Controller.text = result['address_1'] ?? '';
//       address2Controller.text = result['address_2'] ?? '';
//       cityController.text = result['city'] ?? '';
//       stateController.text = result['state'] ?? '';
//       pinController.text = result['pin']?.toString() ?? '';
//       countryController.text = result['country_id']?.toString() ?? '';

//       userId = result['user_id']; // if you need to use it later
//     } else {
//       print('No contact details found.');
//     }
//   }

//   Future<void> _loadUserId() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userId = prefs.getInt('user_id');
//     });
//   }

//   void submitContactUpdate() async {
//     final contactData = {
//       "contact_id": widget.contactId,
//       "first_name": firstNameController.text,
//       "last_name": lastNameController.text,
//       "email": emailController.text,
//       "phone": phoneController.text,
//       "alternate_phone": alternatePhoneController.text,
//       "alternate_email": alternateEmailController.text,
//       "gst_number": gstNumberController.text,
//       "pan_no": panNoController.text,
//       "designation": designationController.text,
//       "display_name": displayNameController.text,
//       "address_1": address1Controller.text,
//       "address_2": address2Controller.text,
//       "city": cityController.text,
//       "state_id": stateController.text,
//       "pin": pinController.text,
//       "country_id": countryController.text,
//       "created_by": "${userId ?? SharedPreferencesService.getInt("user_id")}",
//       "account_id": "${SharedPreferencesService.getInt("account_id")}",
//     };

//      print("response >>>>>>>>>>>>>>>>>>>>>>>>>$contactData");


//     try {
//       final response = await ApiCalls.updateContact(contactData);
//      if (response['success'] == true) {
//   Get.snackbar(
//     'Success',
//     response['message'] ?? 'Contact updated successfully',
//     snackPosition: SnackPosition.BOTTOM,
//     backgroundColor: Colors.green,
//     colorText: Colors.white,
//   );

//   // ✅ Trigger contact reload
//   final controller = Get.find<BmsAppController>();
//   controller.fetchContacts('1100'); // Use dynamic ID if needed

//   Navigator.pop(context, true);
// } else {
//   Get.snackbar(
//     'Failed',
//     response['message'] ?? 'Failed to update contact',
//     snackPosition: SnackPosition.BOTTOM,
//     backgroundColor: Colors.red,
//     colorText: Colors.white,
//   );
// }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Error: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   Future<void> _saveContact() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (_formKey.currentState!.validate()) {
//       if (userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('User ID not found')),
//         );
//         return;
//       }

//       final contactData = {
//         "first_name": firstNameController.text,
//         "last_name": lastNameController.text,
//         "email": emailController.text,
//         "phone": phoneController.text,
//         "alternate_phone": alternatePhoneController.text,
//         "alternate_email": alternateEmailController.text,
//         "gst_number": gstNumberController.text,
//         "pan_no": panNoController.text,
//         "designation": designationController.text,
//         "display_name": displayNameController.text,
//         "address_1": address1Controller.text,
//         "address_2": address2Controller.text,
//         "city": cityController.text,
//         "state_id": stateController.text,
//         "pin": pinController.text,
//         "country_id": countryController.text,
//         "created_by": userId.toString(), // Ensure it's a String
//         "account_id": "${prefs.getInt("account_id")}",
//       };

    
//        try {
//   final response = await ApiCalls.addContact(contactData);

//   if (response['success']) {
//     Get.snackbar(
//       'Success',
//       response['message'] ?? 'Contact added successfully',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );

//     final controller = Get.find<BmsAppController>();
//     controller.fetchContacts('${SharedPreferencesService.getInt("account_id")}');

//     Navigator.pop(context); // Close the form
//   } else {
//     Get.snackbar(
//       'Failed',
//       'Failed to add contact',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }
// } catch (e) {
//   Get.snackbar(
//     'Error',
//     'Error: $e',
//     snackPosition: SnackPosition.BOTTOM,
//     backgroundColor: Colors.red,
//     colorText: Colors.white,
//        );
//      }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Appstyles.primaryColor,
//       appBar: AppBar(
//          backgroundColor: Appstyles.primaryColor,
//         title: Text('Add Contact'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [

//                       Appstyles.cardStyle(
//                         margin: EdgeInsets.all(0), 
//                 child: Padding(
//                 padding: EdgeInsets.all(14.0), // or any other EdgeInsets value
//   child: Column(
//      crossAxisAlignment: CrossAxisAlignment.start,
//     children:[
//                       Text(
//                         'Personal Details',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               controller: firstNameController,
//                               label: 'First Name',
//                               icon: Icons.person,
//                               isMandatory: true,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: _buildTextField(
//                               controller: lastNameController,
//                               label: 'Last Name',
//                               icon: Icons.person,
//                               isMandatory: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               controller: emailController,
//                               label: 'Email Address',
//                               icon: Icons.email,
//                               isEmail: true,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: _buildTextField(
//                               controller: phoneController,
//                               label: 'Phone No.',
//                               icon: Icons.phone,
//                               isMandatory: true,
//                               isPhoneNumber: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               controller: alternateEmailController,
//                               label: 'Alternate Email',
//                               icon: Icons.email,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: _buildTextField(
//                               controller: alternatePhoneController,
//                               label: 'Alternate Phone',
//                               icon: Icons.phone,
//                               isPhoneNumber: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               controller: gstNumberController,
//                               label: 'GST Number',
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: _buildTextField(
//                               controller: panNoController,
//                               label: 'PAN No.',
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               controller: displayNameController,
//                               label: 'Display Name',
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: _buildTextField(
//                               controller: designationController,
//                               label: 'Designation',
//                             ),
//                           ),
//                         ],
//                       ),
//     ], 
//   ),
//                 ),
//                       ),

//                       SizedBox(height: 16),
// Appstyles.cardStyle(margin: EdgeInsets.all(0), 
//                 child: Padding(
//                 padding: EdgeInsets.all(14.0), // or any other EdgeInsets value
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.start,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children:[

//                       Text(
//                         'Address Details',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       _buildTextField(
//                         controller: address1Controller,
//                         label: 'Address 1',
//                       ),
//                       SizedBox(height: 8),
//                       _buildTextField(
//                         controller: address2Controller,
//                         label: 'Address 2',
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               controller: cityController,
//                               label: 'City',
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: _buildTextField(
//                               controller: stateController,
//                               label: 'State',
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               controller: pinController,
//                               label: 'PIN Code',
//                               isPhoneNumber: true,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: _buildTextField(
//                               controller: countryController,
//                               label: 'Country',
//                             ),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 16.0),
//                         child: Center(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (widget.contactId == null) {
//                                 _saveContact(); // Call function to create a new contact
//                               } else {
//                                 submitContactUpdate(); // Call function to update existing contact
//                               }
//                             },
//                             child: Text('Save Contact'),
//                             style: Appstyles.blueButtonStyle(),
//                           ),
//                          ),
//                       ),
//                         ],
//                    ),
//                 ),
//                ),
             

//                     ],
//                   ),
//                 ),
//               ),
//               // Save button
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// Widget _buildTextField({
//   required TextEditingController controller,
//   required String label,
//   IconData? icon,
//   bool isMandatory = false,
//   bool isEmail = false,
//   bool isPhoneNumber = false,
// }) {
//   return TextFormField(
//     controller: controller,
//     keyboardType: isPhoneNumber
//         ? TextInputType.phone
//         : isEmail
//             ? TextInputType.emailAddress
//             : TextInputType.text,
//     decoration: Appstyles.inputtextfield(
//       label: label,
//      // icon: icon != null ? Icon(icon) : null,
//     ),

//     validator: (value) {
//       if (isMandatory && (value == null || value.isEmpty)) {
//         return '$label is required';
//       }
//       if (isEmail && value != null && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//         return 'Enter a valid email address';
//       }
//       // if (isPhoneNumber && value != null && (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value))) {
//       //   return 'Enter a valid 10-digit phone number';
//       // }
//       return null;
//     },
//   );
// }

// }
