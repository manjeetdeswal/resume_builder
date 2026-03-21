import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/template_registry.dart';
import '../providers/resume_provider.dart';
import 'editor_screen.dart';

class TemplateSearchScreen extends StatefulWidget {
  const TemplateSearchScreen({Key? key}) : super(key: key);

  @override
  State<TemplateSearchScreen> createState() => _TemplateSearchScreenState();
}

class _TemplateSearchScreenState extends State<TemplateSearchScreen> {
  String searchQuery = '';

  // Matches the 50 templates to your 5 collections
  Map<String, List<ResumeTemplate>> get _collections {
    return {
      'THE CORPORATE COLLECTION': appTemplates.sublist(0, 10),
      'THE CREATIVE COLLECTION': appTemplates.sublist(10, 20),
      'THE STARTUP COLLECTION': appTemplates.sublist(20, 30),
      'THE ACADEMIC COLLECTION': appTemplates.sublist(30, 40),
      'THE ELITE COLLECTION': appTemplates.sublist(40, 50),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // --- DARK THEME COLORS MATCHING YOUR SCREENSHOT ---
    const bgColor = Color(0xFF10212B);
    const cardColor = Color(0xFF1A3644);
    const pillColor = Color(0xFF4A346A);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('TEMPLATES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textColor)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40.0 : 16.0, vertical: 16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: cardColor,
                hintText: 'Search templates...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          // --- CATEGORIZED TEMPLATE LIST ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40.0 : 16.0, vertical: 8.0),
              children: _collections.entries.map((entry) {
                final collectionName = entry.key;
                final templates = entry.value.where((template) {
                  final matchesName = template.name.toLowerCase().contains(searchQuery.toLowerCase());
                  final matchesTag = template.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
                  return matchesName || matchesTag;
                }).toList();

                if (templates.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- COLLECTION PILL HEADER ---
                    Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: pillColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        collectionName,
                        style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
                      ),
                    ),

                    // --- RESPONSIVE GRID ---
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 4 : 2, // 4 columns on PC, 2 on Phone
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final template = templates[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            context.read<ResumeProvider>().createNewResume(template);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EditorScreen()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                    child: Image.asset(
                                      'assets/images/templates/${template.id}.png',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0, left: 8, right: 8),
                                  child: Text(
                                    template.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}