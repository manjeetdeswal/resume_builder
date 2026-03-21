import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/resume_data.dart';
import '../providers/resume_provider.dart';

class EducationCard extends StatefulWidget {
  final int index;
  final Education education;

  const EducationCard({Key? key, required this.index, required this.education}) : super(key: key);

  @override
  State<EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<EducationCard> {
  late TextEditingController _yearController;

  static const List<String> _institutionSuggestions = [
    // 🇮🇳 India - Top Universities
    'Indian Institute of Technology (IIT)', 'National Institute of Technology (NIT)',
    'Indian Institute of Information Technology (IIIT)',
    'Delhi University', 'Jawaharlal Nehru University (JNU)',
    'Banaras Hindu University (BHU)', 'Aligarh Muslim University (AMU)',
    'Anna University', 'Mumbai University', 'Calcutta University',
    'Pune University (SPPU)', 'Osmania University',
    'Vellore Institute of Technology (VIT)', 'BITS Pilani',
    'Manipal Institute of Technology', 'Amity University',
    'SRM Institute of Science and Technology', 'Lovely Professional University (LPU)',

    // 🌍 Global Universities
    'Harvard University', 'Stanford University',
    'Massachusetts Institute of Technology (MIT)',
    'University of Oxford', 'University of Cambridge',
    'University of California, Berkeley',
    'California Institute of Technology (Caltech)',
    'Princeton University', 'Yale University',
    'University of Chicago', 'Columbia University',

    // 🌐 Generic / Others
    'State University', 'Private University',
    'Community College', 'Open University',
    'Online University (Coursera / edX)'
  ];

  static const List<String> _degreeSuggestions = [
    // 🎓 Bachelor Degrees
    'B.Tech in Computer Science', 'B.Tech in Information Technology',
    'B.Tech in Electronics Engineering', 'B.Tech in Mechanical Engineering',
    'B.Tech in Civil Engineering', 'B.Tech in Electrical Engineering',
    'Bachelor of Science (B.Sc)', 'Bachelor of Arts (B.A.)',
    'Bachelor of Commerce (B.Com)', 'Bachelor of Business Administration (BBA)',
    'Bachelor of Computer Applications (BCA)',

    // 🎓 Master Degrees
    'Master of Technology (M.Tech)', 'Master of Science (M.Sc)',
    'Master of Computer Applications (MCA)',
    'Master of Business Administration (MBA)',
    'Master of Arts (M.A.)', 'Master of Commerce (M.Com)',

    // 🎓 Doctorate
    'Doctor of Philosophy (Ph.D.)',

    // 🏫 Schooling
    'High School Diploma', 'Senior Secondary (12th)',
    'Secondary School (10th)',

    // 📜 Certifications
    'Diploma in Engineering', 'Post Graduate Diploma (PGDM)',
    'Certification in Data Science', 'Certification in Digital Marketing',
    'Certification in Cloud Computing'
  ];

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: widget.education.year);
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ResumeProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.removeEducation(widget.index),
                )
              ],
            ),

            // Autocomplete for Institution
            Autocomplete<String>(
              initialValue: TextEditingValue(text: widget.education.institution),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _institutionSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => provider.updateEducation(widget.index, institution: selection),
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextFormField(
                  controller: controller, focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Institution (e.g. University of Tech)'),
                  onChanged: (val) => provider.updateEducation(widget.index, institution: val),
                );
              },
            ),

            // Autocomplete for Degree
            Autocomplete<String>(
              initialValue: TextEditingValue(text: widget.education.degree),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _degreeSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => provider.updateEducation(widget.index, degree: selection),
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextFormField(
                  controller: controller, focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Degree (e.g. B.Tech in Computer Science)'),
                  onChanged: (val) => provider.updateEducation(widget.index, degree: val),
                );
              },
            ),

            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Graduation Year (e.g. 2020 - 2024)'),
              onChanged: (val) => provider.updateEducation(widget.index, year: val),
            ),
          ],
        ),
      ),
    );
  }
}