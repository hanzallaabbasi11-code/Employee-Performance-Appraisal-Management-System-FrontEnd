import 'dart:convert';
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadEnrollmentScreen extends StatefulWidget {
  const UploadEnrollmentScreen({super.key});

  @override
  State<UploadEnrollmentScreen> createState() => _UploadEnrollmentScreenState();
}

class _UploadEnrollmentScreenState extends State<UploadEnrollmentScreen> {
  late Future<List<Session>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions(); // 👈 called only once
  }

  Session? selectedSession;
  PlatformFile? file;

  // ================= FETCH SESSIONS =================
  Future<List<Session>> fetchSessions() async {
    final response = await http.get(
      Uri.parse('$Url/PeerEvaluator/Sessions'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Session.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  // ================= UPLOAD FILE + SESSION =================
  Future<void> uploadFile({
    required PlatformFile file,
    required int sessionId,
  }) async {
    final uri = Uri.parse('$Url/Enrollment/UploadEnrollment');

    var request = http.MultipartRequest('POST', uri);

    // file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: file.name,
      ),
    );

    // session id
    request.fields['sessionId'] = sessionId.toString();

    request.headers.addAll({'Accept': 'application/json'});

    try {
      final response = await request.send();

      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        debugPrint('Upload success: $respStr');
      } else {
        debugPrint('Upload failed: ${response.statusCode}, Response: $respStr');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // ================= PICK FILE =================
  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        file = result.files.first;
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Upload Enrollment',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ================= SESSION DROPDOWN =================
            FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text('Failed to load sessions');
                }

                final sessions = snapshot.data!;

                return DropdownButtonFormField<Session>(
                  value: selectedSession,
                  hint: const Text('Select Session'),
                  items: sessions.map((s) {
                    return DropdownMenuItem<Session>(
                      value: s,
                      child: Text(s.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSession = val;
                    });
                  },
                  decoration: _inputDecoration(),
                );
              },
            ),

            const SizedBox(height: 16),

            // ================= FILE PICKER =================
            InkWell(
              onTap: _pickExcelFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      file == null ? Icons.upload_file : Icons.description,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      file == null ? 'Upload Excel File' : file!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= UPLOAD BUTTON =================
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (file != null && selectedSession != null) {
                    uploadFile(file: file!, sessionId: selectedSession!.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select session and file'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3F8F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
