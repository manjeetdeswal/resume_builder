import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../models/resume_data.dart';

class SkillCard extends StatelessWidget {
  final int index;
  final Skill skill;

  const SkillCard({Key? key, required this.index, required this.skill}) : super(key: key);

  static const List<String> _skillSuggestions = [
    // 💻 Programming & Tech
    'Flutter', 'Dart', 'Java', 'Kotlin', 'Python', 'C', 'C++', 'C#',
    'JavaScript', 'TypeScript', 'Go', 'Rust', 'Swift', 'PHP',
    'HTML', 'CSS', 'React', 'Angular', 'Vue.js', 'Node.js',
    'Express.js', 'Next.js', 'Redux',

    // 📱 Mobile Development
    'Android Development', 'iOS Development', 'React Native',
    'Flutter Development', 'Xamarin',

    // 🧠 Data & AI
    'Machine Learning', 'Deep Learning', 'Artificial Intelligence',
    'Data Science', 'Data Analysis', 'NLP', 'Computer Vision',
    'TensorFlow', 'PyTorch', 'Pandas', 'NumPy',

    // 🗄️ Databases
    'SQL', 'MySQL', 'PostgreSQL', 'MongoDB', 'Firebase',
    'SQLite', 'Redis', 'Oracle DB',

    // ☁️ Cloud & DevOps
    'AWS', 'Google Cloud', 'Azure', 'Docker', 'Kubernetes',
    'CI/CD', 'Jenkins', 'GitHub Actions', 'Linux', 'Shell Scripting',

    // 🔐 Cybersecurity
    'Ethical Hacking', 'Penetration Testing', 'Network Security',
    'Cryptography', 'OWASP', 'Security Auditing',

    // 🎨 Design
    'UI Design', 'UX Design', 'Figma', 'Adobe XD', 'Photoshop',
    'Illustrator', 'Canva', 'Graphic Design', 'Wireframing',
    'Prototyping',

    // 📊 Business & Management
    'Project Management', 'Product Management', 'Agile',
    'Scrum', 'Kanban', 'Business Analysis', 'Strategic Planning',
    'Operations Management',

    // 📈 Marketing & Sales
    'Digital Marketing', 'SEO', 'SEM', 'Content Marketing',
    'Email Marketing', 'Social Media Marketing',
    'Google Ads', 'Facebook Ads', 'Sales Strategy',
    'Lead Generation', 'CRM',

    // 💰 Finance & Accounting
    'Accounting', 'Financial Analysis', 'Budgeting',
    'Taxation', 'Tally', 'QuickBooks', 'Investment Analysis',
    'Auditing',

    // 🏥 Healthcare
    'Patient Care', 'Clinical Research', 'Nursing',
    'Medical Coding', 'Phlebotomy', 'Healthcare Management',

    // ⚙️ Engineering
    'AutoCAD', 'SolidWorks', 'MATLAB', 'Circuit Design',
    'Mechanical Design', 'Electrical Engineering',
    'Civil Engineering', 'Robotics',

    // 🧑‍🏫 Education & Teaching
    'Teaching', 'Curriculum Development',
    'Classroom Management', 'Online Tutoring',

    // ✍️ Writing & Communication
    'Technical Writing', 'Copywriting', 'Content Writing',
    'Editing', 'Public Speaking', 'Presentation Skills',

    // 🌍 Languages
    'English', 'Hindi', 'Spanish', 'French', 'German',
    'Chinese', 'Japanese',

    // 🧩 Soft Skills
    'Communication', 'Leadership', 'Problem Solving',
    'Critical Thinking', 'Time Management',
    'Teamwork', 'Adaptability', 'Creativity',
    'Decision Making', 'Conflict Resolution',

    // 🛠️ Tools
    'Git', 'GitHub', 'GitLab', 'Jira', 'Trello',
    'Notion', 'Slack', 'Microsoft Office', 'Excel',
    'PowerPoint', 'Word',

    // 🎮 Game Development
    'Unreal Engine', 'Unity', 'Game Design',
    '3D Modeling', 'Blender', 'Level Design',

    // 📦 Misc / Other Professions
    'Customer Service', 'Event Management',
    'Supply Chain Management', 'Logistics',
    'Human Resources', 'Recruitment',
    'Legal Research', 'Negotiation'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Autocomplete<String>(
                initialValue: TextEditingValue(text: skill.name),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                  return _skillSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  context.read<ResumeProvider>().updateSkill(index, name: selection);
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Skill Name', border: InputBorder.none),
                    onChanged: (val) => context.read<ResumeProvider>().updateSkill(index, name: val),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => context.read<ResumeProvider>().removeSkill(index),
            )
          ],
        ),
      ),
    );
  }
}