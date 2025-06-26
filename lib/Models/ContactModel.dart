// models/contact.dart

class Contact {
  final int contactId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobNo;
  final String? companyName;
  final String? designation;

  Contact({
    required this.contactId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobNo,
    this.companyName,
    this.designation,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactId: json['contact_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      mobNo: json['mob_no']?.toString(),
      companyName: json['company_name'],
      designation: json['designation'],
    );
  }
}
