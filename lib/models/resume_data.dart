import 'dart:convert';

class CustomItem {
  String title;
  String subtitle;
  String date;
  String description;

  CustomItem({this.title = '', this.subtitle = '', this.date = '', this.description = ''});

  Map<String, dynamic> toMap() => {'title': title, 'subtitle': subtitle, 'date': date, 'description': description};
  factory CustomItem.fromMap(Map<String, dynamic> map) => CustomItem(
      title: map['title'] ?? '', subtitle: map['subtitle'] ?? '', date: map['date'] ?? '', description: map['description'] ?? ''
  );
}

class CustomSection {
  String sectionTitle;
  List<CustomItem> items;

  // FIX 1: Use a growable list instead of const []
  CustomSection({required this.sectionTitle, List<CustomItem>? items})
      : items = items ?? [];

  Map<String, dynamic> toMap() => {
    'sectionTitle': sectionTitle,
    'items': items.map((x) => x.toMap()).toList(),
  };

  factory CustomSection.fromMap(Map<String, dynamic> map) => CustomSection(
    sectionTitle: map['sectionTitle'] ?? 'New Section',
    items: List<CustomItem>.from((map['items'] ?? []).map((x) => CustomItem.fromMap(x))),
  );
}



class ResumeData {
  String id;
  String title;
  String templateId;
  int themeColor;
  double fontSize;
  double sectionSpacing;
  double paragraphSpacing;
  double lineSpacing;
  String fontFamily;
  String bodyTextStyle; // <-- NEW: 'normal', 'bold', or 'italic'
  List<String> singleColumn; // <-- NEW: For 1-column templates
  List<String> leftColumn;
  List<String> rightColumn;
  // ... (keep your PersonalInfo, Experience, etc. lists here)
  PersonalInfo personalInfo;
  List<Experience> experiences;
  List<Education> educations;
  List<Skill> skills;
  List<Project> projects;
  List<CustomSection> customSections;

  ResumeData({
    required this.id,
    this.title = 'Untitled Resume',
    this.templateId = 'clas_c',
    this.themeColor = 0xFF1976D2,
    this.fontSize = 11.0,
    this.sectionSpacing = 15.0,
    this.paragraphSpacing = 4.0,
    this.lineSpacing = 1.5,
    this.fontFamily = 'Roboto',
    this.bodyTextStyle = 'normal', // <-- NEW DEFAULT
    List<String>? singleColumn,    // <-- NEW
    List<String>? leftColumn,
    List<String>? rightColumn,
    PersonalInfo? personalInfo,
    List<Experience>? experiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Project>? projects,
    List<CustomSection>? customSections,
  }) :
        personalInfo = personalInfo ?? PersonalInfo(),
  // DEFAULT LAYOUT ORDERS
        singleColumn = singleColumn ?? ['Skills', 'Experience', 'Education', 'Projects'],
        leftColumn = leftColumn ?? ['Skills', 'Languages'],
        rightColumn = rightColumn ?? ['Experience', 'Education', 'Projects'],
        experiences = experiences ?? [], educations = educations ?? [], skills = skills ?? [], projects = projects ?? [], customSections = customSections ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'title': title, 'templateId': templateId, 'themeColor': themeColor,
      'fontSize': fontSize, 'sectionSpacing': sectionSpacing, 'paragraphSpacing': paragraphSpacing, 'lineSpacing': lineSpacing,
      'fontFamily': fontFamily, 'bodyTextStyle': bodyTextStyle, // <-- NEW
      'singleColumn': singleColumn, 'leftColumn': leftColumn, 'rightColumn': rightColumn,
      'personalInfo': personalInfo.toMap(),
      'experiences': experiences.map((x) => x.toMap()).toList(),
      'educations': educations.map((x) => x.toMap()).toList(),
      'skills': skills.map((x) => x.toMap()).toList(),
      'projects': projects.map((x) => x.toMap()).toList(),
      'customSections': customSections.map((x) => x.toMap()).toList(),
    };
  }

  factory ResumeData.fromMap(Map<String, dynamic> map) {
    return ResumeData(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? 'Untitled Resume', templateId: map['templateId'] ?? 'clas_c',
      themeColor: map['themeColor'] ?? 0xFF1976D2,
      fontSize: map['fontSize']?.toDouble() ?? 11.0, sectionSpacing: map['sectionSpacing']?.toDouble() ?? 15.0,
      paragraphSpacing: map['paragraphSpacing']?.toDouble() ?? 4.0, lineSpacing: map['lineSpacing']?.toDouble() ?? 1.5,
      fontFamily: map['fontFamily'] ?? 'Roboto', bodyTextStyle: map['bodyTextStyle'] ?? 'normal', // <-- NEW
      singleColumn: List<String>.from(map['singleColumn'] ?? ['Skills', 'Experience', 'Education', 'Projects']),
      leftColumn: List<String>.from(map['leftColumn'] ?? ['Skills', 'Languages']),
      rightColumn: List<String>.from(map['rightColumn'] ?? ['Experience', 'Education', 'Projects']),
      personalInfo: PersonalInfo.fromMap(map['personalInfo'] ?? {}),
      experiences: List<Experience>.from((map['experiences'] ?? []).map((x) => Experience.fromMap(x))),
      educations: List<Education>.from((map['educations'] ?? []).map((x) => Education.fromMap(x))),
      skills: List<Skill>.from((map['skills'] ?? []).map((x) => Skill.fromMap(x))),
      projects: List<Project>.from((map['projects'] ?? []).map((x) => Project.fromMap(x))),
      customSections: List<CustomSection>.from((map['customSections'] ?? []).map((x) => CustomSection.fromMap(x))),
    );
  }
}

class PersonalInfo {
  String fullName;
  String jobTitle;
  String email;
  String phone;
  String location;
  String summary;
  String imagePath; // <-- 1. ADD THIS

  PersonalInfo({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.summary = '',
    this.imagePath = '', // <-- 2. ADD THIS
  });

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'jobTitle': jobTitle,
    'email': email,
    'phone': phone,
    'location': location,
    'summary': summary,
    'imagePath': imagePath,
  };

  factory PersonalInfo.fromMap(Map<String, dynamic> map) => PersonalInfo(
    fullName: map['fullName'] ?? '',
    jobTitle: map['jobTitle'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    location: map['location'] ?? '',
    summary: map['summary'] ?? '',
    imagePath: map['imagePath'] ?? '',
  );
}

class Experience {
  String companyName;
  String role;
  String startDate;
  String endDate;
  String description;

  Experience({
    required this.companyName,
    required this.role,
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'role': role,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      companyName: map['companyName'] ?? '',
      role: map['role'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class Education {
  String institution;
  String degree;
  String year;

  Education({
    required this.institution,
    required this.degree,
    this.year = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'institution': institution,
      'degree': degree,
      'year': year,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      institution: map['institution'] ?? '',
      degree: map['degree'] ?? '',
      year: map['year'] ?? '',
    );
  }
}

class Skill {
  String name;
  double? proficiency;

  Skill({
    required this.name,
    this.proficiency
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'proficiency': proficiency,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      // Use .toDouble() here just in case SharedPreferences saves a whole number as an int instead of a double
      proficiency: map['proficiency']?.toDouble(),
    );
  }
}

class Project {
  String title;
  String description;
  String link;

  Project({
    required this.title,
    this.description = '',
    this.link = ''
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'link': link,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      link: map['link'] ?? '',
    );
  }
}