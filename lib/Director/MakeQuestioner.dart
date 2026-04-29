import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'CreateNewQuestionnaier.dart';
import 'EditEvaluationQuestionnaire.dart';

/// ================= API CONFIG =================
final String baseUrl = '$Url/Questionnaire';

/// ================= MODEL =================
class QuestionnaireModel {
  final int id;
  final String type;
  final int questionCount;
  bool isActive;

  QuestionnaireModel({
    required this.id,
    required this.type,
    required this.questionCount,
    required this.isActive,
  });

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['Id'],
      type: json['Type'],
      questionCount: json['QuestionCount'],
      isActive: json['Flag'] == "1",
    );
  }
}

/// ================= API METHODS =================
Future<List<QuestionnaireModel>> getAllQuestionnaires() async {
  final response = await http.get(Uri.parse('$baseUrl/GetAll'));

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => QuestionnaireModel.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load questionnaires");
  }
}

Future<String?> toggleQuestionnaire({
  required int questionnaireId,
  required bool turnOn,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/Toggle"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"QuestionnaireId": questionnaireId, "TurnOn": turnOn}),
  );

  if (response.statusCode == 200) {
    return null;
  } else {
    final body = jsonDecode(response.body);
    return body["Message"] ?? "Something went wrong";
  }
}

/// ================= MAIN SCREEN =================
class Makequestioner extends StatefulWidget {
  const Makequestioner({super.key});

  @override
  State<Makequestioner> createState() => _MakequestionerState();
}

class _MakequestionerState extends State<Makequestioner>
    with SingleTickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _error;
  List<QuestionnaireModel> _allItems = [];
  bool _archiveExpanded = false;

  // Archive folder animation controller
  late final AnimationController _archiveAnimCtrl;
  late final Animation<double> _archiveRotation;

  @override
  void initState() {
    super.initState();
    _archiveAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _archiveRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _archiveAnimCtrl, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _archiveAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await getAllQuestionnaires();
      setState(() {
        _allItems = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Called by each card when toggle succeeds — moves item between lists reactively
  void _onItemToggled(QuestionnaireModel model, bool newValue) {
    setState(() {
      final index = _allItems.indexWhere((e) => e.id == model.id);
      if (index != -1) {
        _allItems[index].isActive = newValue;
      }
    });
  }

  void _toggleArchive() {
    setState(() => _archiveExpanded = !_archiveExpanded);
    if (_archiveExpanded) {
      _archiveAnimCtrl.forward();
    } else {
      _archiveAnimCtrl.reverse();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Retry',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final activeList =
        _allItems.where((q) => q.isActive).toList();
    final archivedList =
        _allItems.where((q) => !q.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ────────────────────────────────────────────────────
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    "Evaluation Questionnaires",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.asset('assets/images/logo.jpeg', height: 40),
              ],
            ),

            const SizedBox(height: 16),

            // ── INFO BAR ──────────────────────────────────────────────────
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${activeList.length} Questionnaires Available",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Createnewquestionnaier(),
                          ),
                        );
                      },
                      child: const Text(
                        "+ Create New",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── ACTIVE LIST ───────────────────────────────────────────────
            if (activeList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No active questionnaires.",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ...activeList.map(
                (q) => QuestionnaireCard(
                  model: q,
                  onToggled: _onItemToggled,
                ),
              ),

            const SizedBox(height: 8),

            // ── ARCHIVE FOLDER ────────────────────────────────────────────
            _buildArchiveFolder(archivedList),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Archive Folder Widget ──────────────────────────────────────────────────
  Widget _buildArchiveFolder(List<QuestionnaireModel> archivedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Folder Tab Header
        GestureDetector(
          onTap: _toggleArchive,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    Radius.circular(_archiveExpanded ? 0 : 12),
                bottomRight:
                    Radius.circular(_archiveExpanded ? 0 : 12),
              ),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                // Folder icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _archiveExpanded
                          ? Icons.folder_open
                          : Icons.folder,
                      color: Colors.amber.shade700,
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  "Archive",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(width: 8),
                // Badge count
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: archivedList.isEmpty
                        ? Colors.grey.shade400
                        : Colors.red.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${archivedList.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Chevron
                RotationTransition(
                  turns: _archiveRotation,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Folder Body (animated expand/collapse)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildArchiveBody(archivedList),
          crossFadeState: _archiveExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 280),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildArchiveBody(List<QuestionnaireModel> archivedList) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: archivedList.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_off,
                        color: Colors.grey.shade400, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      "Archive is empty",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    "Inactive questionnaires — toggle ON to restore",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                ...archivedList.map(
                  (q) => QuestionnaireCard(
                    model: q,
                    onToggled: _onItemToggled,
                    isInArchive: true,
                  ),
                ),
              ],
            ),
    );
  }
}

/// ================= CARD =================
class QuestionnaireCard extends StatefulWidget {
  final QuestionnaireModel model;
  final void Function(QuestionnaireModel model, bool newValue) onToggled;
  final bool isInArchive;

  const QuestionnaireCard({
    super.key,
    required this.model,
    required this.onToggled,
    this.isInArchive = false,
  });

  @override
  State<QuestionnaireCard> createState() => _QuestionnaireCardState();
}

class _QuestionnaireCardState extends State<QuestionnaireCard> {
  late bool isActive;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isActive = widget.model.isActive;
  }

  // Keep local state in sync when parent rebuilds
  @override
  void didUpdateWidget(covariant QuestionnaireCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.isActive != widget.model.isActive) {
      isActive = widget.model.isActive;
    }
  }

  Future<void> onToggle(bool value) async {
    setState(() {
      loading = true;
      isActive = value;
    });

    final error = await toggleQuestionnaire(
      questionnaireId: widget.model.id,
      turnOn: value,
    );

    setState(() {
      loading = false;
    });

    if (error != null) {
      // Revert on failure
      setState(() => isActive = !value);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      // Success — update model and notify parent to move the card
      widget.model.isActive = value;
      widget.onToggled(widget.model, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // Slightly muted elevation for archive cards
      elevation: widget.isInArchive ? 0.5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isInArchive
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      color: widget.isInArchive ? const Color(0xFFF9F9F9) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.model.type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Slightly muted text in archive
                      color: widget.isInArchive
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Text("Questions",
                        style: TextStyle(fontSize: 12)),
                    Text(
                      widget.model.questionCount.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: isActive,
                        onChanged: onToggle,
                        activeColor: Colors.green,
                      ),
              ],
            ),

            const SizedBox(height: 10),

            /// EDIT BUTTON — disabled in archive (inactive)
            OutlinedButton.icon(
              onPressed: isActive
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditQuestionnaireScreen(
                            questionnaireId: widget.model.id,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),
          ],
        ),
      ),
    );
  }
}
