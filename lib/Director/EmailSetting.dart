import 'package:epams/Director/DirectorDashboard.dart';
import 'package:flutter/material.dart';

class Emailsetting extends StatefulWidget {
  const Emailsetting({super.key});

  @override
  State<Emailsetting> createState() => _EmailsettingState();
}

class _EmailsettingState extends State<Emailsetting> {
  final TextEditingController emailController = TextEditingController();

  int activeIndex = 0;

  List<String> emails = [
    "confidentialreports@university.edu",
    "director@biit.edu.pk",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Directordashboard()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // pushes text and image to ends
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Email Settings",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Confidential Evaluations",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            Image.asset('assets/images/logo.jpeg', height: 40),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Current Session
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Current Session:  Fall 2025",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),
            /// Title
            const Text(
              "Confidential Evaluation Email Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Manage recipient emails for confidential evaluation reports",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// Current Active Recipient Card
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
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          emails[activeIndex],
                          style: const TextStyle(color: Colors.green),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "All confidential evaluation results will be sent to this email.",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Add New Recipient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text(
                        "Add New Recipient",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Email Address"),
                  const SizedBox(height: 5),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "example@university.edu",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (emailController.text.isNotEmpty) {
                          setState(() {
                            emails.add(emailController.text);
                            emailController.clear();
                          });
                        }
                      },
                      icon: const Icon(Icons.mail_outline),
                      label: const Text("Add Email"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Saved Emails
            Text(
              "Saved Recipient Emails (${emails.length})",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: emails.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: activeIndex == index
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio(
                        value: index,
                        groupValue: activeIndex,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            activeIndex = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emails[index]),
                            if (activeIndex == index)
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Active Recipient",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            emails.removeAt(index);
                            if (activeIndex >= emails.length) {
                              activeIndex = 0;
                            }
                          });
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
