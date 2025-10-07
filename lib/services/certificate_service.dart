import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/certificate.dart';
import 'user_profile_service.dart';

/// Service for managing course completion certificates
class CertificateService {
  static const String _certificatesKey = 'user_certificates';
  static const String _lonelinessCourseKey = 'loneliness_course_completion';
  static const String _baseUrl = 'https://strivehigh.thirdvizion.com';

  /// Generate a new certificate for course completion
  static Future<Certificate> generateCertificate({
    required String studentName,
    required String courseName,
    required String courseUrl,
    String? notes,
  }) async {
    final now = DateTime.now();
    final certificate = Certificate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseName: courseName,
      courseUrl: courseUrl,
      studentName: studentName,
      completionDate: now,
      issueDate: now,
      certificateNumber: Certificate.generateCertificateNumber(),
      isVerified: true,
      notes: notes,
    );

    // Save certificate to local storage
    await _saveCertificate(certificate);

    // Mark loneliness course as completed
    await _markLonelinessCourseCompleted();

    return certificate;
  }

  /// Get all certificates for the user from API and local
  static Future<List<Certificate>> getAllCertificates() async {
    final apiCertificates = await _fetchCertificatesFromAPI();
    final localCertificates = await _getLocalCertificates();

    // Combine API and local certificates, avoiding duplicates by ID
    final allCertificates = <String, Certificate>{};
    for (final cert in apiCertificates) {
      allCertificates[cert.id] = cert;
    }
    for (final cert in localCertificates) {
      allCertificates[cert.id] = cert;
    }

    return allCertificates.values.toList();
  }

  /// Fetch certificates from API
  static Future<List<Certificate>> _fetchCertificatesFromAPI() async {
    try {
      final email = await UserProfileService.getUserEmail();
      if (email.isEmpty) {
        print('No user email found for fetching certificates');
        return [];
      }

      final dio = Dio();
      final response = await dio.get('$_baseUrl/api/getcertificate/$email');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final studentName = await UserProfileService.getUserName();
        final now = DateTime.now();

        return data.map((json) {
          final certificatePath = json['certificate'] as String;
          final fullUrl = '$_baseUrl$certificatePath';

          // Parse course name from filename
          // e.g., "/media/certificates/certificate_email_Course Name.jpg" -> "Course Name"
          final filename = certificatePath.split('/').last;
          final parts = filename.split('_');
          String courseName = 'Certificate';
          if (parts.length >= 3) {
            // Remove 'certificate' and email, take the rest
            final courseParts = parts.sublist(2);
            courseName = courseParts.join(' ').replaceAll('.jpg', '').replaceAll('%20', ' ');
          }

          return Certificate(
            id: json['id'].toString(),
            courseName: courseName,
            courseUrl: fullUrl,
            studentName: studentName.isNotEmpty ? studentName : email,
            completionDate: now, // API doesn't provide date
            issueDate: now,
            certificateNumber: 'API-${json['id']}',
            isVerified: true,
            notes: 'Fetched from API',
          );
        }).toList();
      } else {
        print('Failed to fetch certificates: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching certificates from API: $e');
      return [];
    }
  }

  /// Get local certificates
  static Future<List<Certificate>> _getLocalCertificates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final certificatesJson = prefs.getStringList(_certificatesKey) ?? [];

      return certificatesJson
          .map((json) => Certificate.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading local certificates: $e');
      return [];
    }
  }

  /// Get certificates for a specific course
  static Future<List<Certificate>> getCertificatesForCourse(String courseName) async {
    final allCertificates = await getAllCertificates();
    return allCertificates
        .where((cert) => cert.courseName.toLowerCase().contains(courseName.toLowerCase()))
        .toList();
  }

  /// Check if loneliness course is completed
  static Future<bool> isLonelinessCourseCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_lonelinessCourseKey) ?? false;
    } catch (e) {
      print('Error checking course completion: $e');
      return false;
    }
  }

  /// Mark loneliness course as completed
  static Future<void> _markLonelinessCourseCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_lonelinessCourseKey, true);
    } catch (e) {
      print('Error marking course as completed: $e');
    }
  }

  /// Save certificate to local storage
  static Future<void> _saveCertificate(Certificate certificate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingCertificates = await _getLocalCertificates();

      // Add new certificate
      existingCertificates.add(certificate);

      // Convert to JSON strings
      final certificatesJson = existingCertificates
          .map((cert) => jsonEncode(cert.toJson()))
          .toList();

      await prefs.setStringList(_certificatesKey, certificatesJson);
    } catch (e) {
      print('Error saving certificate: $e');
      rethrow;
    }
  }

  /// Delete a certificate
  static Future<bool> deleteCertificate(String certificateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingCertificates = await _getLocalCertificates();

      // Remove certificate with matching ID
      existingCertificates.removeWhere((cert) => cert.id == certificateId);

      // Save updated list
      final certificatesJson = existingCertificates
          .map((cert) => jsonEncode(cert.toJson()))
          .toList();

      await prefs.setStringList(_certificatesKey, certificatesJson);
      return true;
    } catch (e) {
      print('Error deleting certificate: $e');
      return false;
    }
  }

  /// Get the latest loneliness certificate
  static Future<Certificate?> getLatestLonelinessCertificate() async {
    final lonelinessCertificates = await getCertificatesForCourse('loneliness');
    if (lonelinessCertificates.isEmpty) return null;

    // Sort by completion date (newest first)
    lonelinessCertificates.sort((a, b) => b.completionDate.compareTo(a.completionDate));
    return lonelinessCertificates.first;
  }

  /// Verify if user has completed the loneliness academy
  static Future<bool> hasCompletedLonelinessAcademy() async {
    final certificate = await getLatestLonelinessCertificate();
    return certificate != null;
  }

  /// Get completion statistics
  static Future<Map<String, dynamic>> getCompletionStats() async {
    final certificates = await getAllCertificates();
    final lonelinessCertificates = await getCertificatesForCourse('loneliness');

    return {
      'totalCertificates': certificates.length,
      'lonelinessCertificates': lonelinessCertificates.length,
      'hasLonelinessCertificate': lonelinessCertificates.isNotEmpty,
      'latestCompletion': lonelinessCertificates.isNotEmpty
          ? lonelinessCertificates.first.completionDate
          : null,
    };
  }

  /// Clear all certificates (for testing/reset)
  static Future<void> clearAllCertificates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_certificatesKey);
      await prefs.remove(_lonelinessCourseKey);
    } catch (e) {
      print('Error clearing certificates: $e');
    }
  }

  /// Export certificates as JSON
  static Future<String> exportCertificates() async {
    final certificates = await getAllCertificates();
    final certificatesJson = certificates.map((cert) => cert.toJson()).toList();
    return jsonEncode(certificatesJson);
  }

  /// Import certificates from JSON
  static Future<bool> importCertificates(String jsonData) async {
    try {
      final List<dynamic> certificatesJson = jsonDecode(jsonData);
      final certificates = certificatesJson
          .map((json) => Certificate.fromJson(json as Map<String, dynamic>))
          .toList();

      // Save imported certificates
      final prefs = await SharedPreferences.getInstance();
      final certificatesJsonList = certificates
          .map((cert) => jsonEncode(cert.toJson()))
          .toList();

      await prefs.setStringList(_certificatesKey, certificatesJsonList);
      return true;
    } catch (e) {
      print('Error importing certificates: $e');
      return false;
    }
  }
}
