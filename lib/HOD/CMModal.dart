import 'package:flutter/material.dart';

class EvaluateModal extends StatefulWidget {
  final String courseTitle;

  const EvaluateModal({super.key, required this.courseTitle});

  @override
  _EvaluateModalState createState() => _EvaluateModalState();
}

class _EvaluateModalState extends State<EvaluateModal> {
  // Example state variables for radio buttons or switches
  bool paperOnTime = true;
  bool folderOnTime = true;

  // Controller for comment input
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Evaluate ${widget.courseTitle}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),

          const SizedBox(height: 8),

          // Example submission on time row
          _buildSubmissionRow(
            title: 'Paper Submission on Time',
            value: paperOnTime,
            onChanged: (val) {
              setState(() {
                paperOnTime = val;
              });
            },
          ),

          const SizedBox(height: 12),

          _buildSubmissionRow(
            title: 'Folder Submission on Time',
            value: folderOnTime,
            onChanged: (val) {
              setState(() {
                folderOnTime = val;
              });
            },
          ),

          const SizedBox(height: 16),

          // Comment Box Label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Comment TextField
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your comments here...',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle Save Evaluation logic here
                  // You can access the comment via _commentController.text
                  Navigator.of(context).pop();
                },
                child: const Text('Save Evaluation'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic),
        ),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Yes (On Time)'),
              selected: value,
              onSelected: (selected) => onChanged(true),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('No (Late)'),
              selected: !value,
              onSelected: (selected) => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }
}
