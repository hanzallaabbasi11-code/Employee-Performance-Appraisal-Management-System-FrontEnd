import 'dart:convert';
import 'package:epams/Director/DirectorDashboard.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailModel {
  final int id;
  final String mail;
  final bool isActive;
  final String? password;

  EmailModel({
    required this.id,
    required this.mail,
    required this.isActive,
    required this.password
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id: json['id'],
      mail: json['mail'],
      isActive: json['isActive'],
      password: json['password'],
    );
  }
}

class Emailsetting extends StatefulWidget {
  const Emailsetting({super.key});

  @override
  State<Emailsetting> createState() => _EmailsettingState();
}

class _EmailsettingState extends State<Emailsetting> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController=TextEditingController();

  List<EmailModel> emails = [];
  bool isLoading = true;

  final String baseUrl = "$Url/email/";

  @override
  void initState() {
    super.initState();
    fetchEmails();
  }

  // ✅ FETCH ALL EMAILS
  Future<void> fetchEmails() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}getall"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          emails = data.map((e) => EmailModel.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // ✅ ADD EMAIL
  Future<void> addEmail(String email,String password) async {
    final response = await http.post(
      Uri.parse("${baseUrl}add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mail": email,
                        "password":password}),
    );

    if (response.statusCode == 200) {
      emailController.clear();
      fetchEmails();
    }
  }

  // ✅ DELETE EMAIL
  Future<void> deleteEmail(int id) async {
    await http.delete(Uri.parse("${baseUrl}delete/$id"));
    fetchEmails();
  }

  // ✅ ACTIVATE EMAIL
  Future<void> activateEmail(int id) async {
    final response =
        await http.put(Uri.parse("${baseUrl}activate/$id"));

    if (response.statusCode == 200) {
      fetchEmails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Another email is already active. Deactivate it first."),
        ),
      );
    }
  }

  // ✅ DEACTIVATE EMAIL
  Future<void> deactivateEmail(int id) async {
    await http.put(Uri.parse("${baseUrl}deactivate/$id"));
    fetchEmails();
  }

  EmailModel? get activeEmail =>
      emails.firstWhere((e) => e.isActive, orElse: () => EmailModel(id: 0, mail: "No Active Email", isActive: false,password: "Not matched"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Directordashboard()),
            );
          },
        ),
        title: const Text(
          "Email Settings",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// CURRENT ACTIVE EMAIL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Current Active Recipient",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                activeEmail!.mail,
                                style: const TextStyle(
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ADD EMAIL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add New Recipient",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "example@university.edu",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Text(
                          "Enter Password",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: "123",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                addEmail(emailController.text,passwordController.text);
                                
                              }
                            },
                            child: const Text("Add Email"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Saved Recipient Emails",
                    style:
                        TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// EMAIL LIST
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: emails.length,
                    itemBuilder: (context, index) {
                      final email = emails[index];

                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(email.mail)),

                            /// TOGGLE SWITCH
                            Switch(
                              value: email.isActive,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                if (value) {
                                  activateEmail(email.id);
                                } else {
                                  deactivateEmail(email.id);
                                }
                              },
                            ),

                            /// DELETE
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                deleteEmail(email.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}