import 'package:flutter/material.dart';

class Chrpointssettingscreen extends StatefulWidget {
  const Chrpointssettingscreen({super.key});

  @override
  State<Chrpointssettingscreen> createState() => _ChrpointssettingscreenState();
}

class _ChrpointssettingscreenState extends State<Chrpointssettingscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with title and logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CHR Points Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Set point values for class activity to \ncalculate teacher performance',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 40, // adjust size as needed
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Green info container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A8F3C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Configure how CHR activities effect teachers performance',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Add the PointsCard here
              PointsCard(
                title: "Class Held",
                tagText: "Positive",
                tagColor: Colors.green,
                description:
                    "Points awarded when a class is conducted as scheduled",
                pointLabel: "Point Value",
                initialPoints: 1,
                footerText: "+1 points per occurrence",
              ),

              PointsCard(
                title: "Class Not Held",
                tagText: "Negative",
                tagColor: Colors.red,
                description:
                    "Points deducted when scheduled class is not conducted",
                pointLabel: "Point Value",
                initialPoints: 1,
                footerText: "-1 points per occurrence",
              ),

              PointsCard(
                title: "Late In",
                tagText: "Negative",
                tagColor: Colors.red,
                description:
                    "Pints deducted when teacher arrives late to class",
                pointLabel: "Point Value",
                initialPoints: 1,
                footerText: "-1 points per occurrence",
              ),

              PointsCard(
                title: "Early Left",
                tagText: "Negative",
                tagColor: Colors.red,
                description:
                    "Points deducted when teacher leaves class before secheduled time",
                pointLabel: "Point Value",
                initialPoints: 1,
                footerText: "-1 points per occurrence",
              ),

              PointsCard(
                title: "Held On Time",
                tagText: "Positive",
                tagColor: Colors.green,
                description:
                    "Bouns Points for conducting class on time without delays",
                pointLabel: "Point Value",
                initialPoints: 1,
                footerText: "+1 points per occurrence",
              ),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Button background color
                    // foregroundColor: Colors.white, // Text and icon color
                  ),
                  onPressed: () {},
                  child: Text(
                    'Save CHR Points Setting',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // Add more cards here if you want...
            ],
          ),
        ),
      ),
    );
  }
}

// Reuse the PointsCard widget here
class PointsCard extends StatelessWidget {
  final String title;
  final String tagText;
  final Color tagColor;
  final String description;
  final String pointLabel;
  final int initialPoints;
  final String footerText;

  const PointsCard({
    super.key,
    required this.title,
    required this.tagText,
    required this.tagColor,
    required this.description,
    required this.pointLabel,
    required this.initialPoints,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE6F6E9), // Light green background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Tag Row
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tagText,
                    style: TextStyle(
                      color: tagColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description text
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),

            const SizedBox(height: 12),

            // Point Value Label
            Text(
              pointLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),

            const SizedBox(height: 8),

            // Input and points text row
            Row(
              children: [
                SizedBox(
                  width: 70,
                  height: 35,
                  child: TextFormField(
                    initialValue: initialPoints.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.green.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.green.shade400),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("points"),
              ],
            ),

            const SizedBox(height: 16),

            // Footer box with light green background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                footerText,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
