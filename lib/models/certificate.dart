
/// Model for storing certificate completion data
class Certificate {
  final String id;
  final String courseName;
  final String courseUrl;
  final String studentName;
  final DateTime completionDate;
  final DateTime issueDate;
  final String certificateNumber;
  final bool isVerified;
  final String? notes;

  const Certificate({
    required this.id,
    required this.courseName,
    required this.courseUrl,
    required this.studentName,
    required this.completionDate,
    required this.issueDate,
    required this.certificateNumber,
    this.isVerified = false,
    this.notes,
  });

  /// Create a certificate from JSON
  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      courseName: json['courseName'] as String,
      courseUrl: json['courseUrl'] as String,
      studentName: json['studentName'] as String,
      completionDate: DateTime.parse(json['completionDate'] as String),
      issueDate: DateTime.parse(json['issueDate'] as String),
      certificateNumber: json['certificateNumber'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Convert certificate to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'courseUrl': courseUrl,
      'studentName': studentName,
      'completionDate': completionDate.toIso8601String(),
      'issueDate': issueDate.toIso8601String(),
      'certificateNumber': certificateNumber,
      'isVerified': isVerified,
      'notes': notes,
    };
  }

  /// Create a copy of the certificate with updated fields
  Certificate copyWith({
    String? id,
    String? courseName,
    String? courseUrl,
    String? studentName,
    DateTime? completionDate,
    DateTime? issueDate,
    String? certificateNumber,
    bool? isVerified,
    String? notes,
  }) {
    return Certificate(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      courseUrl: courseUrl ?? this.courseUrl,
      studentName: studentName ?? this.studentName,
      completionDate: completionDate ?? this.completionDate,
      issueDate: issueDate ?? this.issueDate,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      isVerified: isVerified ?? this.isVerified,
      notes: notes ?? this.notes,
    );
  }

  /// Generate a unique certificate number
  static String generateCertificateNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'LON-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
  }

  /// Format completion date for display
  String get formattedCompletionDate {
    return '${completionDate.day}/${completionDate.month}/${completionDate.year}';
  }

  /// Format issue date for display
  String get formattedIssueDate {
    return '${issueDate.day}/${issueDate.month}/${issueDate.year}';
  }

  @override
  String toString() {
    return 'Certificate(id: $id, courseName: $courseName, studentName: $studentName, completionDate: $completionDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Certificate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
