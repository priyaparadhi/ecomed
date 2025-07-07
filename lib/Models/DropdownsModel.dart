// models/enquiry_dropdown_model.dart
class EnquiryDropdownModel {
  final List<EnquiryType> enquiryTypes;
  final List<EnquiryMode> enquiryModes;
  final List<LeadLevel> leadLevels;

  EnquiryDropdownModel({
    required this.enquiryTypes,
    required this.enquiryModes,
    required this.leadLevels,
  });

  factory EnquiryDropdownModel.fromJson(Map<String, dynamic> json) {
    return EnquiryDropdownModel(
      enquiryTypes: (json['enquiry_types'] as List)
          .map((e) => EnquiryType.fromJson(e))
          .toList(),
      enquiryModes: (json['enquiry_mode'] as List)
          .map((e) => EnquiryMode.fromJson(e))
          .toList(),
      leadLevels: (json['lead_level'] as List)
          .map((e) => LeadLevel.fromJson(e))
          .toList(),
    );
  }
}

class EnquiryType {
  final int enquiryTypeId;
  final String enquiryType;

  EnquiryType({required this.enquiryTypeId, required this.enquiryType});

  factory EnquiryType.fromJson(Map<String, dynamic> json) {
    return EnquiryType(
      enquiryTypeId: json['enquiry_type_id'],
      enquiryType: json['enquiry_type'].trim(),
    );
  }
}

class EnquiryMode {
  final int enquiryModeId;
  final String enquiryMode;

  EnquiryMode({required this.enquiryModeId, required this.enquiryMode});

  factory EnquiryMode.fromJson(Map<String, dynamic> json) {
    return EnquiryMode(
      enquiryModeId: json['enquiry_mode_id'],
      enquiryMode: json['enquiry_mode'],
    );
  }
}

class LeadLevel {
  final int leadLevelId;
  final String leadLevel;

  LeadLevel({required this.leadLevelId, required this.leadLevel});

  factory LeadLevel.fromJson(Map<String, dynamic> json) {
    return LeadLevel(
      leadLevelId: json['lead_level_id'],
      leadLevel: json['lead_level'],
    );
  }
}
