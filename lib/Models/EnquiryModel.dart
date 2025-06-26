class Enquiry {
  final int enquiryId;
  final String firstName;
  final String lastName;
  final String email;
  final String companyName;
  final String? note;
  final String? attachment;
  final String? purchaseTimeline;
  final String? createdAt;
  final dynamic? mobNo;

  Enquiry({
    required this.enquiryId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.companyName,
    this.note,
    this.attachment,
    this.purchaseTimeline,
    this.createdAt,
    this.mobNo,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      enquiryId: json['enquiry_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      companyName: json['company_name'] ?? '',
      note: json['note'],
      attachment: json['enq_attachment'],
      purchaseTimeline: json['purchase_timeline'],
      createdAt: json['created_at'],
      mobNo: json['mob_no'],
    );
  }
}
