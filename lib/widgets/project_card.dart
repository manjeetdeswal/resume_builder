import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/resume_data.dart';
import '../providers/resume_provider.dart';

class ProjectCard extends StatefulWidget {
  final int index;
  final Project project;

  const ProjectCard({Key? key, required this.index, required this.project}) : super(key: key);

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late TextEditingController _descController;
  late TextEditingController _linkController;

  static const List<String> _projectSuggestions = [
    // 💻 Development
    'E-Commerce Application', 'Portfolio Website',
    'Task Management App', 'Chat Application',
    'Social Media App', 'Blog Platform',
    'Job Portal', 'Online Learning Platform',

    // 📱 Mobile Apps
    'Weather App', 'Fitness Tracker App',
    'Expense Tracker App', 'Notes App',
    'Food Delivery App',

    // 🧠 AI / ML
    'Machine Learning Model', 'Recommendation System',
    'Image Classification System', 'Chatbot',

    // 📊 Data Projects
    'Data Dashboard', 'Sales Analytics Dashboard',

    // 🎮 Game Dev
    '2D Game', '3D Game', 'Ludo Game',
    'Endless Runner Game',

    // 🛠️ Systems
    'Inventory Management System',
    'Library Management System',
    'Hospital Management System',

    // 🌐 Others
    'Automation Script', 'API Service',
    'Open Source Contribution'
  ];
  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.project.description);
    _linkController = TextEditingController(text: widget.project.link);
  }

  @override
  void dispose() {
    _descController.dispose();
    _linkController.dispose();
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
                const Text('Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.removeProject(widget.index),
                )
              ],
            ),

            // Autocomplete for Project Title
            Autocomplete<String>(
              initialValue: TextEditingValue(text: widget.project.title),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _projectSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => provider.updateProject(widget.index, title: selection),
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextFormField(
                  controller: controller, focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Project Title (e.g., E-Commerce App)'),
                  onChanged: (val) => provider.updateProject(widget.index, title: val),
                );
              },
            ),

            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Short Description'),
              maxLines: 2,
              onChanged: (val) => provider.updateProject(widget.index, description: val),
            ),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(labelText: 'Link (GitHub, Play Store, etc.)'),
              onChanged: (val) => provider.updateProject(widget.index, link: val),
            ),
          ],
        ),
      ),
    );
  }
}