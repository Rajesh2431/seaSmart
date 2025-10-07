import 'package:flutter/material.dart';
import '../models/certificate.dart';
import '../services/certificate_service.dart';
import '../widgets/certificate_widget.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  late Future<List<Certificate>> _certificatesFuture;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  void _loadCertificates() {
    _certificatesFuture = CertificateService.getAllCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Certificate>>(
        future: _certificatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading certificates: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadCertificates();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No certificates found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete courses to earn certificates',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final certificates = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final certificate = certificates[index];
                return CertificateWidget(
                  certificate: certificate,
                  onTap: () {
                    // Navigate to detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CertificateDetailScreen(
                          certificate: certificate,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
