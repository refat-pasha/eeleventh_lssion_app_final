import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionView extends StatefulWidget {
  final String quizId;

  const AddQuestionView({super.key, required this.quizId});

  @override
  State<AddQuestionView> createState() => _AddQuestionViewState();
}

class _AddQuestionViewState extends State<AddQuestionView> {

  final questionController = TextEditingController();

  final optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  int correctIndex = 0;
  int _savedCount = 0;
  bool _isSaving = false;

  bool get _formHasContent {
    if (questionController.text.trim().isNotEmpty) return true;
    for (final c in optionControllers) {
      if (c.text.trim().isNotEmpty) return true;
    }
    return false;
  }

  String? _validate() {
    if (questionController.text.trim().isEmpty) {
      return "Question text is required";
    }
    final filledOptions =
        optionControllers.where((c) => c.text.trim().isNotEmpty).length;
    if (filledOptions < 2) {
      return "Please fill at least 2 options";
    }
    if (optionControllers[correctIndex].text.trim().isEmpty) {
      return "The selected correct option is empty";
    }
    return null;
  }

  /// Returns true on success, false otherwise.
  Future<bool> _saveQuestion({bool showSnackBar = true}) async {
    if (_isSaving) return false;

    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return false;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .add({
        "question": questionController.text.trim(),
        "options": optionControllers.map((e) => e.text.trim()).toList(),
        "correctIndex": correctIndex,
        "createdAt": FieldValue.serverTimestamp(),
      });

      questionController.clear();
      for (final c in optionControllers) {
        c.clear();
      }

      if (!mounted) return true;
      setState(() {
        correctIndex = 0;
        _savedCount++;
      });

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Question $_savedCount added")),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed: $e")),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _finishQuiz() async {
    if (_isSaving) return;

    if (_formHasContent) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Unsaved question"),
          content: const Text(
            "You have typed a question but haven't added it yet. "
            "Save it before finishing?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'discard'),
              child: const Text("Discard"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text("Save & Finish"),
            ),
          ],
        ),
      );

      if (!mounted || action == null || action == 'cancel') return;

      if (action == 'save') {
        final ok = await _saveQuestion(showSnackBar: false);
        if (!ok) return;
      }
    }

    if (_savedCount == 0) {
      if (!mounted) return;
      final leave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("No questions saved"),
          content: const Text(
            "This quiz has no questions yet. Leave anyway?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Stay"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Leave"),
            ),
          ],
        ),
      );
      if (leave != true) return;
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Question"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                "Saved: $_savedCount",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: "Question"),
            ),

            const SizedBox(height: 20),

            ...List.generate(4, (index) {
              return Row(
                children: [
                  Radio<int>(
                    value: index,
                    groupValue: correctIndex,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              correctIndex = value!;
                            });
                          },
                  ),
                  Expanded(
                    child: TextField(
                      controller: optionControllers[index],
                      decoration: InputDecoration(
                        labelText: "Option ${index + 1}",
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSaving ? null : () => _saveQuestion(),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Add Question"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _isSaving ? null : _finishQuiz,
              child: const Text("Finish Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}
