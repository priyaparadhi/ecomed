import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:flutter/material.dart';

class AddContactForm extends StatefulWidget {
  const AddContactForm({Key? key}) : super(key: key);

  @override
  State<AddContactForm> createState() => _AddContactFormState();
}

class _AddContactFormState extends State<AddContactForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _designation = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _anniversary = TextEditingController();
  final TextEditingController _address = TextEditingController();

  List<Map<String, dynamic>> designationList = [];
  int? selectedDesignationId;

  @override
  void initState() {
    super.initState();
    fetchDesignations();
  }

  void fetchDesignations() async {
    final designations = await ApiCalls.fetchCustomerDesignations();
    setState(() {
      designationList = designations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Add Contact'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            color: Colors.white,
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Wrap(
                  runSpacing: 20,
                  spacing: 20,
                  children: [
                    buildTextField(_firstName, "First Name*", Icons.person),
                    buildTextField(_lastName, "Last Name*", Icons.person),
                    buildDropdown(),
                    buildTextField(_email, "Email Address*", Icons.email),
                    buildTextField(_mobile, "Mobile No.*", Icons.phone),
                    buildDateField(_dob, "Date of Birth", Icons.cake),
                    buildDateField(_anniversary, "Anniversary", Icons.favorite),
                    buildMultilineField(_address, "Address"),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Save logic
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 280 : double.infinity,
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildDateField(
      TextEditingController controller, String label, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 280 : double.infinity,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate:
                DateTime.now().subtract(const Duration(days: 365 * 20)),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            controller.text =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          }
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<int>(
        value: selectedDesignationId,
        decoration: const InputDecoration(
          labelText: 'Designation*',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: designationList.map((designation) {
          return DropdownMenuItem<int>(
            value: designation['cust_designation_id'],
            child: Text(designation['cust_designation']),
          );
        }).toList(),
        onChanged: (int? newId) {
          setState(() {
            selectedDesignationId = newId;
          });
        },
        validator: (value) =>
            value == null ? 'Please select a designation' : null,
      ),
    );
  }

  Widget buildMultilineField(TextEditingController controller, String label) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 580 : double.infinity,
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
