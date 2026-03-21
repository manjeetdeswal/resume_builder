import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../models/resume_data.dart';

class ExperienceCard extends StatefulWidget {
  final int index;
  final Experience experience;

  const ExperienceCard({Key? key, required this.index, required this.experience}) : super(key: key);

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  late TextEditingController _startController;
  late TextEditingController _endController;
  late TextEditingController _descController;

  static const List<String> _roleSuggestions = [
    // 💻 Tech Roles
    'Software Engineer', 'Senior Software Engineer',
    'Frontend Developer', 'Backend Developer', 'Full Stack Developer',
    'Flutter Developer', 'Android Developer', 'iOS Developer',
    'Web Developer', 'Game Developer', 'DevOps Engineer',
    'Cloud Engineer', 'System Administrator',
    'QA Engineer', 'Automation Tester',

    // 🧠 Data & AI
    'Data Scientist', 'Data Analyst', 'Machine Learning Engineer',
    'AI Engineer', 'Business Intelligence Analyst',

    // 🎨 Design
    'UI Designer', 'UX Designer', 'UI/UX Designer',
    'Graphic Designer', 'Product Designer',

    // 📊 Business & Management
    'Product Manager', 'Project Manager', 'Business Analyst',
    'Operations Manager',

    // 📈 Marketing & Sales
    'Marketing Manager', 'Digital Marketing Specialist',
    'SEO Specialist', 'Content Strategist',
    'Sales Executive', 'Sales Manager',

    // 💰 Finance
    'Accountant', 'Financial Analyst', 'Auditor',

    // 👥 HR
    'HR Manager', 'Recruiter', 'Talent Acquisition Specialist',

    // 🏥 Others
    'Teacher', 'Professor', 'Consultant',
    'Customer Support Executive'
  ];
  static const List<String> _companySuggestions = [
    // 🌍 Global Tech
    'Google', 'Amazon', 'Microsoft', 'Apple', 'Meta', 'Netflix',
    'IBM', 'Oracle', 'Intel', 'Adobe', 'Salesforce',

    // 🇮🇳 Indian Companies
    'TCS', 'Infosys', 'Wipro', 'HCL Technologies',
    'Tech Mahindra', 'Cognizant', 'Accenture', 'Capgemini',
    'Deloitte', 'Reliance Industries', 'Adani Group',
    'Flipkart', 'Zomato', 'Swiggy', 'Paytm',

    // 🚀 Startups
    'Startup', 'Stealth Startup', 'Self-Employed', 'Freelance',

    // 🏢 Generic
    'Private Company', 'Government Organization', 'NGO'
  ];

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: widget.experience.startDate);
    _endController = TextEditingController(text: widget.experience.endDate);
    _descController = TextEditingController(text: widget.experience.description);
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _descController.dispose();
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
                const Text('Work Experience', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.removeExperience(widget.index),
                )
              ],
            ),

            // Autocomplete for Job Title
            Autocomplete<String>(
              initialValue: TextEditingValue(text: widget.experience.role),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _roleSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => provider.updateExperience(widget.index, role: selection),
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextFormField(
                  controller: controller, focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                  onChanged: (val) => provider.updateExperience(widget.index, role: val),
                );
              },
            ),

            // Autocomplete for Company
            Autocomplete<String>(
              initialValue: TextEditingValue(text: widget.experience.companyName),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _companySuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => provider.updateExperience(widget.index, companyName: selection),
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextFormField(
                  controller: controller, focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Company / Location'),
                  onChanged: (val) => provider.updateExperience(widget.index, companyName: val),
                );
              },
            ),

            Row(
              children: [
                Expanded(child: TextField(controller: _startController, decoration: const InputDecoration(labelText: 'Start Date'), onChanged: (val) => provider.updateExperience(widget.index, startDate: val))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _endController, decoration: const InputDecoration(labelText: 'End Date (or Present)'), onChanged: (val) => provider.updateExperience(widget.index, endDate: val))),
              ],
            ),
            TextField(
              controller: _descController, decoration: const InputDecoration(labelText: 'Description (Use - for bullets)'),
              maxLines: 4,
              onChanged: (val) => provider.updateExperience(widget.index, description: val),
            ),
          ],
        ),
      ),
    );
  }
}