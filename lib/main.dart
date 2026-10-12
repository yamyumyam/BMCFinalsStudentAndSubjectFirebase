import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'page_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF80549E),
        ),
        scaffoldBackgroundColor: const Color(0xFFE5D0F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB58ACD),
          foregroundColor: Color(0xFF321344),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF80549E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(15),
          ),
        ),
      ),
      home: const StudentRegistrationPage(),
    );
  }
}

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  State<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final sectionController = TextEditingController();
  final yearLevelController = TextEditingController();

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter your ${label.toLowerCase()}.';
          }
          return null;
        },
      ),
    );
  }

  void nextPage() {
    if (!formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectSchedulePage(
          name: nameController.text.trim(),
          section: sectionController.text.trim(),
          yearLevel: yearLevelController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    yearLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
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
                inputField('Name', nameController),
                inputField('Section', sectionController),
                inputField('Year Level', yearLevelController),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: nextPage,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}