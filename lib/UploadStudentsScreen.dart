import 'package:epams/Url.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'dart:io';
import 'package:http/http.dart' as http;

class UploadStudentsScreen extends StatefulWidget {
  const UploadStudentsScreen({super.key});

  @override
  State<UploadStudentsScreen> createState() => _UploadStudentsScreenState();
}

class _UploadStudentsScreenState extends State<UploadStudentsScreen> {
  String? selectedSession;

  List<String> sessions = ['Fall 2025', 'Spring 2025'];
  PlatformFile? file;

  Future<void> uploadFile({required PlatformFile file}) async {
    final uri = Uri.parse(
      '$Url/student/upload', // change endpoint
    );

    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: file.name,
      ),
    );

    // Optional: headers
    request.headers.addAll({'Accept': 'application/json'});

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Upload success: $responseBody');
      } else {
        print('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        setState(() {
          file = result.files.first;
        });

        debugPrint('File name: ${file!.name}');
        debugPrint('File path: ${file!.path}');
        debugPrint('File size: ${file!.size}');
      } else {
        debugPrint('User canceled file picking');
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Upload Students',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Upload students list using Excel file',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE8F8EE),
              backgroundImage: AssetImage('assets/images/logo.jpeg'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
                initialValue: selectedSession,
                hint: const Text('Select Session'),
                items: sessions
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedSession = val);
                },
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 16),

            InkWell(
              onTap: _pickExcelFile,
              borderRadius: BorderRadius.circular(12),
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
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      file == null
                          ? 'Supported format: .xlsx'
                          : 'File selected successfully',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (file != null) {
                    await uploadFile(file: file!);
                  }
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Uploaded Files',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            if (file != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility, color: Colors.green),
                    ),
                  ],
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
