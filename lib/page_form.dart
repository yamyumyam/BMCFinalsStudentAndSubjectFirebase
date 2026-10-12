import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectSchedulePage extends StatefulWidget {
  final String name;
  final String section;
  final String yearLevel;

  const SubjectSchedulePage({
    super.key,
    required this.name,
    required this.section,
    required this.yearLevel,
  });

  @override
  State<SubjectSchedulePage> createState() => _SubjectSchedulePageState();
}

class _SubjectSchedulePageState extends State<SubjectSchedulePage> {
  final formKey = GlobalKey<FormState>();
  final subject1Controller = TextEditingController();
  final schedule1Controller = TextEditingController();
  final subject2Controller = TextEditingController();
  final schedule2Controller = TextEditingController();
  final subject3Controller = TextEditingController();
  final schedule3Controller = TextEditingController();

  bool isSaving = false;
  bool isSaved = false;

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: !isSaving && !isSaved,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter ${label.toLowerCase()}.';
          }
          return null;
        },
      ),
    );
  }

  Future<void> saveRegistration() async {
    if (isSaving || isSaved || !formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('student_registrations')
          .add({
        'name': widget.name,
        'section': widget.section,
        'yearLevel': widget.yearLevel,
        'subjects': [
          {
            'subject': subject1Controller.text.trim(),
            'schedule': schedule1Controller.text.trim(),
          },
          {
            'subject': subject2Controller.text.trim(),
            'schedule': schedule2Controller.text.trim(),
          },
          {
            'subject': subject3Controller.text.trim(),
            'schedule': schedule3Controller.text.trim(),
          },
        ],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() => isSaved = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration saved to Firestore.'),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Save failed: ${e.code}. ${e.message ?? ""}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    subject1Controller.dispose();
    schedule1Controller.dispose();
    subject2Controller.dispose();
    schedule2Controller.dispose();
    subject3Controller.dispose();
    schedule3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subject Schedule'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FA),
              border: Border.all(
                color: const Color(0xFF80549E),
                width: 2,
              ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  inputField('Subject 1', subject1Controller),
                  inputField('Schedule 1', schedule1Controller),
                  const SizedBox(height: 10),
                  inputField('Subject 2', subject2Controller),
                  inputField('Schedule 2', schedule2Controller),
                  const SizedBox(height: 10),
                  inputField('Subject 3', subject3Controller),
                  inputField('Schedule 3', schedule3Controller),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isSaving || isSaved ? null : saveRegistration,
                      child: Text(
                        isSaving
                            ? 'Saving...'
                            : isSaved
                                ? 'Saved'
                                : 'Save',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}