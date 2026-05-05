import 'dart:convert';
//import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Ensure these paths match your project structure
import 'package:epams/Session.dart'; 
import 'package:epams/Url.dart';

class Uploadchr extends StatefulWidget {
  const Uploadchr({super.key});

  @override
  State<Uploadchr> createState() => _UploadchrState();
}

class _UploadchrState extends State<Uploadchr> {
  late Future<List<Session>> _sessionsFuture;
  Session? selectedSession;
  PlatformFile? file;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
  }

  // ================= 1. GET SESSIONS FROM BACKEND =================
  Future<List<Session>> fetchSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$Url/CHR/GetSessions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Session.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  // ================= 2. PICK EXCEL FILE =================
  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
      // withData: true is required for Web to get file bytes
      withData: true, 
    );

    if (result != null) {
      setState(() {
        file = result.files.first;
      });
    }
  }

  // ================= 3. UPLOAD LOGIC (Multipart) =================
  Future<void> uploadFile() async {
    if (selectedSession == null) {
      _showSnackBar("Please select a session first", Colors.orange);
      return;
    }
    if (file == null) {
      _showSnackBar("Please select an Excel file", Colors.orange);
      return;
    }

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$Url/CHR/upload'));

      // Add the file based on platform (Web uses bytes, Mobile can use path)
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file', // Key matches backend httpRequest.Files[0]
          file!.bytes!,
          filename: file!.name,
          contentType: MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file!.path!,
          contentType: MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        ));
      }

      // Add Session ID field to match backend: httpRequest.Form["sessionID"]
      request.fields['sessionID'] = selectedSession!.id.toString();

      request.headers.addAll({
        'Accept': 'application/json',
      });

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        _showSnackBar(
          "${responseData['Message']} (${responseData['Count']} rows)", 
          Colors.green
        );
        setState(() => file = null);
      } else {
        // Parse error message from C# InternalServerError or BadRequest
        Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = errorData['ExceptionMessage'] ?? errorData['Message'] ?? "Server Error";
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
      _showSnackBar("Could not connect to server", Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ================= 4. UI DESIGN =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Upload CHR Data', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Step 1: Select Session", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(color: Colors.green);
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red));
                }

                return DropdownButtonFormField<Session>(
                  isExpanded: true,
                  decoration: _inputStyle(),
                  hint: const Text("Select Session"),
                  value: selectedSession,
                  items: snapshot.data?.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s.name));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedSession = val),
                );
              },
            ),

            const SizedBox(height: 30),
            const Text("Step 2: Upload Excel", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _isUploading ? null : _pickExcelFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green.withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    Icon(
                      file == null ? Icons.file_present_rounded : Icons.check_circle, 
                      size: 48, 
                      color: file == null ? Colors.grey : Colors.green
                    ),
                    const SizedBox(height: 12),
                    Text(
                      file?.name ?? "Select CHR Excel File",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: file == null ? Colors.grey[700] : Colors.green[700],
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isUploading ? null : uploadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUploading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text("Confirm & Upload to Database", 
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}