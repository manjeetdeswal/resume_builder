import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/resume_data.dart';
import '../models/template_registry.dart';

class ResumeProvider extends ChangeNotifier {
  // 1. The list of all saved resumes
  List<ResumeData> allResumes = [];

  // 2. The resume CURRENTLY being edited
  late ResumeData currentResume;

  // 3. The currently selected template
  ResumeTemplate? selectedTemplate;

  // 4. The unique key for local storage
  final String _storageKey = 'jeet_studio_resumes_list';

  // Constructor runs when the app starts
  ResumeProvider() {
    _loadFromStorage();
  }

  // ==========================================
  // STORAGE & DASHBOARD LOGIC
  // ==========================================

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_storageKey);

    // 1. Load the user's saved resumes if they exist
    if (dataString != null) {
      final List<dynamic> decoded = jsonDecode(dataString);
      allResumes = decoded.map((item) => ResumeData.fromMap(item)).toList();
    } else {
      allResumes = [];
    }

    // 2. ALWAYS ENSURE THE EXAMPLES EXIST!
    final hasExample1 = allResumes.any((r) => r.id == 'example_1');
    final hasExample2 = allResumes.any((r) => r.id == 'example_2');

    if (!hasExample1) {
      allResumes.add(_createExampleResume());
    }
    if (!hasExample2) {
      allResumes.add(_createTechExampleResume());
    }

    // 3. Set the active resume to the first one in the list
    if (allResumes.isNotEmpty) {
      currentResume = allResumes.first;
    }

    notifyListeners();
  }


  Future<bool> exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? dataString = prefs.getString(_storageKey);

      if (dataString == null || dataString.isEmpty) return false;

      // Create a temporary file to hold the JSON data
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/jeet_resume_backup.json');
      await file.writeAsString(dataString);

      // Open the native share menu so the user can save it anywhere!
      await Share.shareXFiles([XFile(file.path)], text: 'My Resume Backup');
      return true;
    } catch (e) {
      debugPrint("Export error: $e");
      return false;
    }
  }

  Future<String> importData() async {
    try {
      // Open the device file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Safest option for Android file pickers
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final String jsonString = await file.readAsString();

        // Try to decode the file to make sure it's valid JSON
        final List<dynamic> decoded = jsonDecode(jsonString);

        // Basic validation to ensure it's actually our resume data
        if (decoded.isNotEmpty && decoded.first is Map && decoded.first.containsKey('id')) {

          // Merge data intelligently! If a resume already exists, update it. If it's new, add it.
          for (var item in decoded) {
            final importedResume = ResumeData.fromMap(item);
            final existingIndex = allResumes.indexWhere((r) => r.id == importedResume.id);

            if (existingIndex != -1) {
              allResumes[existingIndex] = importedResume; // Update existing
            } else {
              allResumes.add(importedResume); // Add new
            }
          }

          await _saveAllToStorage();
          notifyListeners();
          return 'Success! Resumes imported.';
        } else {
          return 'Invalid backup file format.';
        }
      }
      return 'Import canceled.';
    } catch (e) {
      debugPrint("Import error: $e");
      return 'Error reading file. Make sure it is a valid JSON backup.';
    }
  }

  Future<void> _saveAllToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(allResumes.map((r) => r.toMap()).toList());
    await prefs.setString(_storageKey, encodedList);
  }

  // Called when a user taps a resume on the Home Screen
  void setActiveResume(ResumeData resume) {
    currentResume = resume;
    selectedTemplate = appTemplates.firstWhere(
            (t) => t.id == resume.templateId,
        orElse: () => appTemplates.first
    );
    notifyListeners();
  }

  // Called when creating a brand new resume
  void createNewResume(ResumeTemplate template) {
    final newResume = ResumeData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Untitled Resume',
      templateId: template.id,
    );

    allResumes.add(newResume);
    currentResume = newResume;
    selectedTemplate = template;

    _saveAllToStorage();
    notifyListeners();
  }

  // Called to delete a resume from the Home Screen
  void deleteResume(String id) {
    allResumes.removeWhere((r) => r.id == id);
    _saveAllToStorage();
    notifyListeners();
  }

  // --- NEW: Rename a Resume ---
  void renameResume(String id, String newTitle) {
    final index = allResumes.indexWhere((r) => r.id == id); // FIXED: Changed to allResumes
    if (index != -1) {
      allResumes[index].title = newTitle;                 // FIXED: Changed to allResumes
      notifyListeners();
      _saveAllToStorage();
    }
  }

  // --- NEW: Duplicate a Resume ---
  void duplicateResume(ResumeData original) {
    final Map<String, dynamic> dataMap = original.toMap();
    final newResume = ResumeData.fromMap(dataMap);

    newResume.id = DateTime.now().millisecondsSinceEpoch.toString();
    newResume.title = '${original.title} (Copy)';

    allResumes.add(newResume);                          // FIXED: Changed to allResumes
    notifyListeners();
    _saveAllToStorage();
  }

  void setTemplate(ResumeTemplate template) {
    selectedTemplate = template;
    currentResume.templateId = template.id;
    _saveAllToStorage();
    notifyListeners();
  }

  // ==========================================
  // DESIGN & FORMATTING LOGIC
  // ==========================================

  void updateThemeColor(Color color) {
    currentResume.themeColor = color.value;
    _saveAllToStorage();
    notifyListeners();
  }

  void updateFontFamily(String font) {
    currentResume.fontFamily = font;
    notifyListeners();
    _saveAllToStorage();
  }

  void updateFontSize(double size) {
    currentResume.fontSize = size;
    notifyListeners();
    _saveAllToStorage();
  }

  void updateSectionSpacing(double spacing) {
    currentResume.sectionSpacing = spacing;
    notifyListeners();
    _saveAllToStorage();
  }

  void updateParagraphSpacing(double spacing) {
    currentResume.paragraphSpacing = spacing;
    notifyListeners();
    _saveAllToStorage();
  }

  void updateLineSpacing(double spacing) {
    currentResume.lineSpacing = spacing;
    notifyListeners();
    _saveAllToStorage();
  }

  void updateBodyTextStyle(String style) {
    currentResume.bodyTextStyle = style;
    notifyListeners();
    _saveAllToStorage();
  }

  // --- DRAG AND DROP REORDERING ---
  void reorderLeftColumn(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = currentResume.leftColumn.removeAt(oldIndex);
    currentResume.leftColumn.insert(newIndex, item);
    notifyListeners();
    _saveAllToStorage();
  }

  void reorderRightColumn(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = currentResume.rightColumn.removeAt(oldIndex);
    currentResume.rightColumn.insert(newIndex, item);
    notifyListeners();
    _saveAllToStorage();
  }

  void reorderSingleColumn(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = currentResume.singleColumn.removeAt(oldIndex);
    currentResume.singleColumn.insert(newIndex, item);
    notifyListeners();
    _saveAllToStorage();
  }

  void moveSectionToColumn(String section, bool toLeft) {
    currentResume.leftColumn.remove(section);
    currentResume.rightColumn.remove(section);
    if (toLeft) {
      currentResume.leftColumn.add(section);
    } else {
      currentResume.rightColumn.add(section);
    }
    notifyListeners();
    _saveAllToStorage();
  }

  // ==========================================
  // DATA UPDATE LOGIC
  // ==========================================

  void updateProfileImage(String path) {
    currentResume.personalInfo.imagePath = path;
    notifyListeners();
    _saveAllToStorage();
  }

  void updatePersonalInfo({String? title, String? fullName, String? jobTitle, String? email, String? phone, String? location, String? summary}) {
    if (title != null) currentResume.title = title;
    if (fullName != null) currentResume.personalInfo.fullName = fullName;
    if (jobTitle != null) currentResume.personalInfo.jobTitle = jobTitle;
    if (email != null) currentResume.personalInfo.email = email;
    if (phone != null) currentResume.personalInfo.phone = phone;
    if (location != null) currentResume.personalInfo.location = location;
    if (summary != null) currentResume.personalInfo.summary = summary;
    notifyListeners();
    _saveAllToStorage();
  }

  void addExperience() {
    currentResume.experiences.add(Experience(companyName: '', role: '', startDate: '', endDate: '', description: ''));
    notifyListeners();
    _saveAllToStorage();
  }

  void updateExperience(int index, {String? companyName, String? role, String? startDate, String? endDate, String? description}) {
    if (index >= 0 && index < currentResume.experiences.length) {
      final exp = currentResume.experiences[index];
      if (companyName != null) exp.companyName = companyName;
      if (role != null) exp.role = role;
      if (startDate != null) exp.startDate = startDate;
      if (endDate != null) exp.endDate = endDate;
      if (description != null) exp.description = description;
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void removeExperience(int index) {
    if (index >= 0 && index < currentResume.experiences.length) {
      currentResume.experiences.removeAt(index);
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void addEducation() {
    currentResume.educations.add(Education(institution: '', degree: '', year: ''));
    notifyListeners();
    _saveAllToStorage();
  }

  void updateEducation(int index, {String? institution, String? degree, String? year}) {
    if (index >= 0 && index < currentResume.educations.length) {
      final edu = currentResume.educations[index];
      if (institution != null) edu.institution = institution;
      if (degree != null) edu.degree = degree;
      if (year != null) edu.year = year;
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void removeEducation(int index) {
    if (index >= 0 && index < currentResume.educations.length) {
      currentResume.educations.removeAt(index);
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void addSkill() {
    currentResume.skills.add(Skill(name: ''));
    notifyListeners();
    _saveAllToStorage();
  }

  void updateSkill(int index, {String? name, double? proficiency}) {
    if (index >= 0 && index < currentResume.skills.length) {
      final skill = currentResume.skills[index];
      if (name != null) skill.name = name;
      if (proficiency != null) skill.proficiency = proficiency;
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void removeSkill(int index) {
    if (index >= 0 && index < currentResume.skills.length) {
      currentResume.skills.removeAt(index);
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void addProject() {
    currentResume.projects.add(Project(title: '', description: '', link: ''));
    notifyListeners();
    _saveAllToStorage();
  }

  void updateProject(int index, {String? title, String? description, String? link}) {
    if (index >= 0 && index < currentResume.projects.length) {
      final project = currentResume.projects[index];
      if (title != null) project.title = title;
      if (description != null) project.description = description;
      if (link != null) project.link = link;
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void removeProject(int index) {
    if (index >= 0 && index < currentResume.projects.length) {
      currentResume.projects.removeAt(index);
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void addCustomSection({String title = 'Custom Section'}) {
    currentResume.customSections.add(CustomSection(sectionTitle: title));
    currentResume.singleColumn.add(title);
    currentResume.rightColumn.add(title);
    notifyListeners();
    _saveAllToStorage();
  }

  void updateCustomSectionTitle(int sectionIndex, String newTitle) {
    if (sectionIndex >= 0 && sectionIndex < currentResume.customSections.length) {
      // Also update the names in the layout columns if the user renames the section!
      final oldTitle = currentResume.customSections[sectionIndex].sectionTitle;

      final singleIdx = currentResume.singleColumn.indexOf(oldTitle);
      if (singleIdx != -1) currentResume.singleColumn[singleIdx] = newTitle;

      final leftIdx = currentResume.leftColumn.indexOf(oldTitle);
      if (leftIdx != -1) currentResume.leftColumn[leftIdx] = newTitle;

      final rightIdx = currentResume.rightColumn.indexOf(oldTitle);
      if (rightIdx != -1) currentResume.rightColumn[rightIdx] = newTitle;

      currentResume.customSections[sectionIndex].sectionTitle = newTitle;
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void removeCustomSection(int sectionIndex) {
    if (sectionIndex >= 0 && sectionIndex < currentResume.customSections.length) {
      final oldTitle = currentResume.customSections[sectionIndex].sectionTitle;
      currentResume.singleColumn.remove(oldTitle);
      currentResume.leftColumn.remove(oldTitle);
      currentResume.rightColumn.remove(oldTitle);

      currentResume.customSections.removeAt(sectionIndex);
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void addCustomItem(int sectionIndex) {
    if (sectionIndex >= 0 && sectionIndex < currentResume.customSections.length) {
      currentResume.customSections[sectionIndex].items.add(CustomItem(title: ''));
      notifyListeners();
      _saveAllToStorage();
    }
  }

  void updateCustomItem(int sectionIndex, int itemIndex, {String? title, String? subtitle, String? date, String? description}) {
    if (sectionIndex >= 0 && sectionIndex < currentResume.customSections.length) {
      final items = currentResume.customSections[sectionIndex].items;
      if (itemIndex >= 0 && itemIndex < items.length) {
        if (title != null) items[itemIndex].title = title;
        if (subtitle != null) items[itemIndex].subtitle = subtitle;
        if (date != null) items[itemIndex].date = date;
        if (description != null) items[itemIndex].description = description;
        notifyListeners();
        _saveAllToStorage();
      }
    }
  }

  void removeCustomItem(int sectionIndex, int itemIndex) {
    if (sectionIndex >= 0 && sectionIndex < currentResume.customSections.length) {
      final items = currentResume.customSections[sectionIndex].items;
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
        notifyListeners();
        _saveAllToStorage();
      }
    }
  }

  // ==========================================
  // THE OUT-OF-THE-BOX EXAMPLE DATA
  // ==========================================
  ResumeData _createExampleResume() {
    return ResumeData(
      id: 'example_1',
      title: 'Retail & Management Example',
      templateId: 't3', // Green Sidebar Avatar
      themeColor: 0xFF689F38,
      fontSize: 11.0,
      sectionSpacing: 15.0,
      paragraphSpacing: 4.0,
      lineSpacing: 1.5,
      fontFamily: 'Open Sans',
      bodyTextStyle: 'normal',
      personalInfo: PersonalInfo(
        fullName: 'Sean Patel',
        jobTitle: 'Store Manager',
        email: 'saanvi.patel@sample.in',
        phone: '+919999999999',
        location: 'New Delhi, India 110044',
        summary: 'Results-driven Store Manager with 5+ years of retail experience. Proven track record of boosting sales, optimizing store merchandising, and fostering customer loyalty. Adept at leading teams of 15+ employees and managing high-volume operations while maintaining strict quality standards.',
      ),
      skills: [
        Skill(name: 'Team Leadership'), Skill(name: 'Visual Merchandising'),
        Skill(name: 'Inventory Management'), Skill(name: 'Sales Strategy'),
        Skill(name: 'Customer Experience & CRM'), Skill(name: 'Conflict Resolution'),
      ],
      experiences: [
        Experience(
          companyName: 'H&M, New Delhi', role: 'Assistant Store Manager', startDate: 'May 2022', endDate: 'Present',
          description: '• Directed daily store operations, overseeing a staff of 12 associates and optimizing shift schedules.\n• Exceeded quarterly sales targets by 15% through strategic floor layout adjustments.\n• Reduced inventory shrinkage by 8% by implementing new stock auditing protocols.',
        ),
        Experience(
          companyName: 'Starbucks, New Delhi', role: 'Shift Supervisor', startDate: 'January 2021', endDate: 'March 2022',
          description: '• Managed high-traffic shifts, ensuring rapid order fulfillment and high customer satisfaction scores.\n• Trained 8 new baristas on equipment maintenance, recipe compliance, and customer service standards.',
        ),
      ],
      educations: [
        Education(institution: 'Delhi University', degree: 'Bachelor of Business Administration', year: 'May 2020'),
        Education(institution: 'Oxford School of English', degree: 'Diploma in Retail Management', year: 'June 2018'),
      ],
      projects: [
        Project(title: 'Holiday Campaign Rollout', description: 'Spearheaded local marketing initiatives for the 2023 winter season, resulting in a 22% year-over-year revenue increase.', link: ''),
      ],
      customSections: [
        CustomSection(
            sectionTitle: 'Languages',
            items: [
              CustomItem(title: 'English', subtitle: 'Fluent (Bilingual)'),
              CustomItem(title: 'Hindi', subtitle: 'Native Proficiency'),
            ]
        ),
        CustomSection(
            sectionTitle: 'Certifications',
            items: [
              CustomItem(title: 'Certified Retail Manager (CRM)', subtitle: 'Retail Association of India', date: '2021'),
            ]
        )
      ],
      // Tell the dynamic router exactly where to place all these new sections!
      singleColumn: ['Experience', 'Education', 'Projects', 'Skills', 'Languages', 'Certifications'],
      leftColumn: ['Skills', 'Languages', 'Certifications'],
      rightColumn: ['Experience', 'Projects', 'Education'],
    );
  }

  ResumeData _createTechExampleResume() {
    return ResumeData(
      id: 'example_2',
      title: 'Software Engineer Example',
      templateId: 't27', // Navy Left Half-Split
      themeColor: 0xFF1976D2,
      fontSize: 11.0,
      sectionSpacing: 15.0,
      paragraphSpacing: 5.0,
      lineSpacing: 1.5,
      fontFamily: 'Roboto',
      bodyTextStyle: 'normal',
      personalInfo: PersonalInfo(
        fullName: 'Manjeet Deswal',
        jobTitle: 'Cross-Platform Developer',
        email: 'manjeet@sample.com',
        phone: '+91 98765 43210',
        location: 'Bengaluru, India',
        summary: 'Detail-oriented Software Engineer specializing in cross-platform mobile and desktop applications. Experienced in Flutter, C# (Avalonia), and native Android development. ',
      ),
      skills: [
        Skill(name: 'Flutter & Dart'), Skill(name: 'C# & .NET (Avalonia)'),
        Skill(name: 'Android Native (Java/Kotlin)'), Skill(name: 'ADB & Android TV'),
        Skill(name: 'Python Scripting'), Skill(name: 'State Management (Provider)'),
      ],
      experiences: [
        Experience(
          companyName: 'Jeet Studio', role: 'Lead Developer & Founder', startDate: 'Aug 2023', endDate: 'Present',
          description: '• Architected and launched multiple cross-platform utility applications, serving Linux, Windows, and Android ecosystems.\n• '
              'Built "Use As", converting mobile phones into dynamic PC peripherals'
              ' (mouse/keyboard/camera) utilizing Python server websockets.\n• Developed robust'
              ' Android TV toolsets leveraging advanced ADB commands for remote configuration.',
        ),
        Experience(
          companyName: 'TechNova Solutions', role: 'Mobile App Developer', startDate: 'Jan 2021', endDate: 'Jul 2023',
          description: '• Spearheaded development of a scalable Flutter e-commerce application equipped with a dedicated admin panel.\n•'
              ' Reduced application load time by 40% via lazy loading and optimal state management strategies.',
        ),
      ],
      educations: [
        Education(institution: 'Visvesvaraya Technological University',
            degree: 'B.Tech in Computer Science', year: 'May 2020'),
      ],
      projects: [
        Project(
            title: 'LocalStream Server',
            description: 'Developed a local UPnP and HTTP media server for Windows, macOS, and Linux using C# and Avalonia UI.',
            link: 'https://github.com/manjeetdeswal/Local-Stream-Upnp---Http-Server-'
        ),
        Project(
            title: 'Habity - Habit Tracker',
            description: 'Created a sleek, performance-focused habit-tracking application using Flutter and Dart.',
            link: 'https://github.com/manjeetdeswal/Habity-Habit-Tracker'
        ),
      ],
      customSections: [
        CustomSection(
            sectionTitle: 'Achievements',
            items: [
              CustomItem(title: 'Open Source Contributor', subtitle: 'Maintained and deployed multiple Linux & Windows packages.', date: '2024'),
            ]
        ),
        CustomSection(
            sectionTitle: 'Interests',
            items: [
              CustomItem(title: 'Robotics & Unreal Engine', subtitle: 'Prototyping automated workflows and exploring 3D environments.'),
            ]
        )
      ],
      // Tell the dynamic router exactly where to place all these new sections!
      singleColumn: ['Experience', 'Projects', 'Education', 'Skills', 'Achievements', 'Interests'],
      leftColumn: ['Skills', 'Achievements', 'Interests'],
      rightColumn: ['Experience', 'Projects', 'Education'],
    );
  }
}