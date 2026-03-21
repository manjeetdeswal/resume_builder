import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../widgets/custom_item_card.dart';
import '../widgets/education_card.dart';
import '../widgets/experience_card.dart';
import '../widgets/skill_card.dart';
import '../widgets/project_card.dart';
import 'preview_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String _activeSection = 'personal';

  static const List<String> _jobTitleSuggestions = [
    'Software Engineer', 'Frontend Developer', 'Backend Developer', 'Full Stack Developer',
    'Flutter Developer', 'Android Developer', 'iOS Developer', 'Data Scientist',
    'Product Manager', 'Project Manager', 'Graphic Designer', 'UI/UX Designer',
    'Marketing Manager', 'Sales Executive', 'Financial Analyst', 'Accountant'
  ];

  static const List<String> _standardSections = [
    'Certifications', 'Languages', 'Hobbies & Interests',
    'References', 'Achievements', 'Publications', 'Extracurricular Activities'
  ];

  void _setActiveSection(String sectionKey) {
    setState(() => _activeSection = sectionKey);
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      context.read<ResumeProvider>().updateProfileImage(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final data = provider.currentResume;


    // If the screen is wider than 900px, it's a PC/Tablet!
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final editorContent = ListView(
      children: [
        // ================= PERSONAL INFO =================
        ExpansionTile(
          key: Key('personal_${_activeSection == 'personal'}'),
          initiallyExpanded: _activeSection == 'personal',
          onExpansionChanged: (expanded) {
            if (expanded) _setActiveSection('personal');
          },
          title: const Text('Personal Details & Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          backgroundImage: data.personalInfo.imagePath.isNotEmpty ? FileImage(File(data.personalInfo.imagePath)) : null,
                          child: data.personalInfo.imagePath.isEmpty ? const Icon(Icons.add_a_photo, size: 30, color: Colors.blue) : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tap to add or change your professional photo', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            if (data.personalInfo.imagePath.isNotEmpty)
                              TextButton(
                                onPressed: () => context.read<ResumeProvider>().updateProfileImage(''),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), alignment: Alignment.centerLeft),
                                child: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontSize: 12)),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    initialValue: data.personalInfo.fullName,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    onChanged: (val) => context.read<ResumeProvider>().updatePersonalInfo(fullName: val),
                  ),

                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: data.personalInfo.jobTitle),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                      return _jobTitleSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) => context.read<ResumeProvider>().updatePersonalInfo(jobTitle: selection),
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return TextFormField(
                        key: const ValueKey('job_title_auto'),
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Target Job Title'),
                        onChanged: (val) => context.read<ResumeProvider>().updatePersonalInfo(jobTitle: val),
                      );
                    },
                  ),

                  TextFormField(
                    initialValue: data.personalInfo.email,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    onChanged: (val) => context.read<ResumeProvider>().updatePersonalInfo(email: val),
                  ),
                  TextFormField(
                    initialValue: data.personalInfo.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    onChanged: (val) => context.read<ResumeProvider>().updatePersonalInfo(phone: val),
                  ),
                  TextFormField(
                    initialValue: data.personalInfo.location,
                    decoration: const InputDecoration(labelText: 'Location (City, Country)'),
                    onChanged: (val) => context.read<ResumeProvider>().updatePersonalInfo(location: val),
                  ),
                  TextFormField(
                    initialValue: data.personalInfo.summary,
                    decoration: const InputDecoration(labelText: 'Objective / Professional Summary', alignLabelWithHint: true),
                    maxLines: 4,
                    onChanged: (val) => context.read<ResumeProvider>().updatePersonalInfo(summary: val),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ================= EXPERIENCE =================
        _buildCollapsibleSection(
          title: 'Work Experience', sectionKey: 'exp', addLabel: 'Add Experience',
          children: List.generate(data.experiences.length, (index) => ExperienceCard(key: ValueKey('exp_$index'), index: index, experience: data.experiences[index])),
          onAdd: () { provider.addExperience(); _setActiveSection('exp'); },
        ),

        // ================= EDUCATION =================
        _buildCollapsibleSection(
          title: 'Education', sectionKey: 'edu', addLabel: 'Add Education',
          children: List.generate(data.educations.length, (index) => EducationCard(key: ValueKey('edu_$index'), index: index, education: data.educations[index])),
          onAdd: () { provider.addEducation(); _setActiveSection('edu'); },
        ),

        // ================= SKILLS =================
        _buildCollapsibleSection(
          title: 'Skills', sectionKey: 'skills', addLabel: 'Add Skill',
          children: List.generate(data.skills.length, (index) => SkillCard(key: ValueKey('skill_$index'), index: index, skill: data.skills[index])),
          onAdd: () { provider.addSkill(); _setActiveSection('skills'); },
        ),

        // ================= PROJECTS =================
        _buildCollapsibleSection(
          title: 'Projects', sectionKey: 'proj', addLabel: 'Add Project',
          children: List.generate(data.projects.length, (index) => ProjectCard(key: ValueKey('proj_$index'), index: index, project: data.projects[index])),
          onAdd: () { provider.addProject(); _setActiveSection('proj'); },
        ),

        const Divider(height: 30, thickness: 2),


        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Add More Sections', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Wrap(
            spacing: 8.0, runSpacing: 8.0,
            children: _standardSections.map((title) {
              final bool alreadyAdded = data.customSections.any((s) => s.sectionTitle == title);
              if (alreadyAdded) return const SizedBox.shrink();

              return ActionChip(
                label: Text(title),
                avatar: const Icon(Icons.add, size: 16),
                backgroundColor: Colors.blue.withOpacity(0.05),
                side: const BorderSide(color: Colors.blue, width: 0.5),
                onPressed: () {
                  context.read<ResumeProvider>().addCustomSection(title: title);
                  _setActiveSection('custom_${data.customSections.length}');
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // ================= GENERATED SECTIONS LIST =================
        ...List.generate(data.customSections.length, (sIndex) {
          final section = data.customSections[sIndex];
          final sectionKey = 'custom_$sIndex';
          final isExpanded = _activeSection == sectionKey;

          return ExpansionTile(
            key: Key('${sectionKey}_$isExpanded'),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (expanded) { if (expanded) _setActiveSection(sectionKey); },
            title: Text(section.sectionTitle.isEmpty ? 'New Custom Section' : section.sectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('section_title_$sIndex'),
                        initialValue: section.sectionTitle,
                        decoration: const InputDecoration(labelText: 'Section Title'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        onChanged: (val) => context.read<ResumeProvider>().updateCustomSectionTitle(sIndex, val),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Delete Section', onPressed: () => context.read<ResumeProvider>().removeCustomSection(sIndex)),
                  ],
                ),
              ),
              ...List.generate(section.items.length, (iIndex) {
                return CustomItemCard(key: ValueKey('custom_item_${sIndex}_$iIndex'), sectionIndex: sIndex, itemIndex: iIndex, item: section.items[iIndex]);
              }),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: TextButton.icon(
                    icon: const Icon(Icons.add), label: const Text('Add Item to Section'),
                    onPressed: () { context.read<ResumeProvider>().addCustomItem(sIndex); _setActiveSection(sectionKey); }
                ),
              ),
            ],
          );
        }),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            icon: const Icon(Icons.post_add),
            label: const Text('CREATE BLANK CUSTOM SECTION'),
            onPressed: () {
              context.read<ResumeProvider>().addCustomSection(title: '');
              _setActiveSection('custom_${data.customSections.length}');
            },
          ),
        ),

        const SizedBox(height: 100), // padding for scrolling
      ],
    );


    //  RESPONSIVE SPLIT

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Row(
          children: [
            // Left Side: The Editor Form
            Expanded(
              flex: 4,
              child: Scaffold(
                appBar: AppBar(title: const Text('Edit Resume'), elevation: 1),
                body: editorContent,
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
            // Right Side: The LIVE PDF Preview
            const Expanded(
              flex: 5,
              child: PreviewScreen(), // Embeds your existing preview screen!
            ),
          ],
        ),
      );
    }

    // Standard Mobile Fallback Layout
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Resume'),
        actions: [
          IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Preview PDF',
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PreviewScreen()));
              }
          )
        ],
      ),
      body: editorContent,
    );
  }

  Widget _buildCollapsibleSection({required String title, required String sectionKey, required List<Widget> children, VoidCallback? onAdd, String? addLabel}) {
    final isExpanded = _activeSection == sectionKey;
    return ExpansionTile(
      key: Key('${sectionKey}_$isExpanded'),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) { if (expanded) _setActiveSection(sectionKey); },
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        ...children,
        if (onAdd != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: TextButton.icon(icon: const Icon(Icons.add_circle_outline), label: Text(addLabel ?? 'Add Item'), onPressed: onAdd)),
      ],
    );
  }
}