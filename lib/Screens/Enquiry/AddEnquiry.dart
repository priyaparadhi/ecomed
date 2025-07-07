import 'dart:io';

import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/DropdownsModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEnquiryForm extends StatefulWidget {
  @override
  State<AddEnquiryForm> createState() => _AddEnquiryFormState();
}

class _AddEnquiryFormState extends State<AddEnquiryForm> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final preferredContactController = TextEditingController();

  final companyNameController = TextEditingController();
  final companyEmailController = TextEditingController();
  final companyMobileController = TextEditingController();

  String? typeOfEnquiry;
  String? sourceOfEnquiry;
  String? enquiryLevel;
  final purchaseTimelineController = TextEditingController();
  DateTime? preferredMeetingDate;
  final notesController = TextEditingController();

  String? attachmentFilePath;
  int? preferredContactMethodId;
  final Map<int, String> preferredContactOptions = {
    1: 'Mobile',
    2: 'Email',
  };
  List<EnquiryType> enquiryTypes = [];
  List<EnquiryMode> enquiryModes = [];
  List<LeadLevel> leadLevels = [];

  int? selectedEnquiryTypeId;
  int? selectedEnquiryModeId;
  int? selectedLeadLevelId;
  @override
  void initState() {
    super.initState();
    loadDropdownData();
  }

  void loadDropdownData() async {
    try {
      final data = await ApiCalls.fetchEnquiryDropdownData();
      setState(() {
        enquiryTypes =
            data.enquiryTypes.where((e) => e.enquiryType.isNotEmpty).toList();
        enquiryModes = data.enquiryModes;
        leadLevels = data.leadLevels;
      });
    } catch (e) {
      print("Error loading dropdown data: $e");
    }
  }

  Future<void> pickAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => attachmentFilePath = result.files.single.path);
    }
  }

  Future<void> selectMeetingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => preferredMeetingDate = picked);
  }

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await ApiCalls.submitEnquiryForm(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        mobNo: mobileController.text.trim(),
        companyName: companyNameController.text.trim(),
        companyEmail: companyEmailController.text.trim(),
        companyMobNo: companyMobileController.text.trim(),
        categoryEnqId: selectedEnquiryTypeId.toString(),
        sourceEnqId: selectedEnquiryModeId.toString(),
        enquiryLevelId: selectedLeadLevelId.toString(),
        purchaseTimeline: purchaseTimelineController.text.trim(),
        preferredMeetingDate:
            DateFormat('yyyy-MM-dd').format(preferredMeetingDate!),
        note: notesController.text.trim(),
        preferredContactMethod: preferredContactMethodId.toString(),
        //accountId: '6',
        attachmentFile:
            attachmentFilePath != null ? File(attachmentFilePath!) : null,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Success')),
        );
        Navigator.pop(context); // or reset form
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Submission failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lato(fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: _inputDecoration(label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Add Enquiry"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildSection("Customer Details", [
                buildTextField(firstNameController, "First Name *"),
                buildTextField(lastNameController, "Last Name *"),
                buildTextField(emailController, "Email ID *"),
                buildTextField(mobileController, "Mobile Number *"),
                _buildDropdown(
                  label: "Preferred Contact Method *",
                  items: preferredContactOptions.values.toList(),
                  value: preferredContactMethodId == null
                      ? null
                      : preferredContactOptions[preferredContactMethodId],
                  onChanged: (selected) {
                    setState(() {
                      preferredContactMethodId = preferredContactOptions.entries
                          .firstWhere((entry) => entry.value == selected)
                          .key;
                    });
                  },
                ),
              ]),
              buildSection("Company Details", [
                buildTextField(companyNameController, "Company Name *"),
                buildTextField(companyEmailController, "Company Email"),
                buildTextField(
                    companyMobileController, "Company Mobile Number"),
              ]),
              buildSection("Enquiry Details", [
                _buildDropdown(
                  label: "Type of Enquiry *",
                  items: enquiryTypes.map((e) => e.enquiryType).toList(),
                  value: selectedEnquiryTypeId == null
                      ? null
                      : enquiryTypes
                          .firstWhere(
                              (e) => e.enquiryTypeId == selectedEnquiryTypeId)
                          .enquiryType,
                  onChanged: (val) {
                    setState(() {
                      selectedEnquiryTypeId = enquiryTypes
                          .firstWhere((e) => e.enquiryType == val)
                          .enquiryTypeId;
                    });
                  },
                ),
                _buildDropdown(
                  label: "Source Of Enquiry *",
                  items: enquiryModes.map((e) => e.enquiryMode).toList(),
                  value: selectedEnquiryModeId == null
                      ? null
                      : enquiryModes
                          .firstWhere(
                              (e) => e.enquiryModeId == selectedEnquiryModeId)
                          .enquiryMode,
                  onChanged: (val) {
                    setState(() {
                      selectedEnquiryModeId = enquiryModes
                          .firstWhere((e) => e.enquiryMode == val)
                          .enquiryModeId;
                    });
                  },
                ),
                _buildDropdown(
                  label: "Enquiry Level *",
                  items: leadLevels.map((e) => e.leadLevel).toList(),
                  value: selectedLeadLevelId == null
                      ? null
                      : leadLevels
                          .firstWhere(
                              (e) => e.leadLevelId == selectedLeadLevelId)
                          .leadLevel,
                  onChanged: (val) {
                    setState(() {
                      selectedLeadLevelId = leadLevels
                          .firstWhere((e) => e.leadLevel == val)
                          .leadLevelId;
                    });
                  },
                ),
                buildTextField(
                    purchaseTimelineController, "Purchase Timeline *"),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: selectMeetingDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: preferredMeetingDate == null
                              ? ''
                              : DateFormat('yyyy-MM-dd')
                                  .format(preferredMeetingDate!),
                        ),
                        decoration: _inputDecoration("Preferred Meeting Date *")
                            .copyWith(suffixIcon: Icon(Icons.calendar_today)),
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ),
                ),
                buildTextField(notesController, "Notes / Requirements"),
              ]),
              buildSection("Attachments", [
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: pickAttachment,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        attachmentFilePath?.split('/').last ??
                            'No file selected',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submitForm,
                      child: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green,
                        textStyle: GoogleFonts.lato(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: GoogleFonts.lato(fontSize: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(label),
        validator: (val) =>
            label.contains('*') && val!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget buildSection(String title, List<Widget> fields) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...fields,
        ],
      ),
    );
  }
}
