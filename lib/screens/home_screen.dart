import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- Added url_launcher
import 'package:resume_builder/screens/thumbnail_generator_screen.dart';
import '../providers/resume_provider.dart';
import 'template_search_screen.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // --- ADDED: Patreon Launcher Method ---
  Future<void> _launchPatreon() async {
    final url = Uri.parse('https://www.patreon.com/cw/UnrealComponent');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch Patreon link');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Resumes', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          // --- ADDED: Donation Button in the Main Screen AppBar ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.favorite, size: 18),
              label: const Text('Support', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _launchPatreon,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _showSettingsDialog(context),
          ),
          if (isDesktop) const SizedBox(width: 20), // Extra padding on PC
        ],
      ),
      body: provider.allResumes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        // Extra padding on desktop so it doesn't touch the very edges
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16, vertical: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // --- RESPONSIVE GRID COLUMNS ---
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.65,
        ),
        itemCount: provider.allResumes.length,
        itemBuilder: (context, index) {
          final resume = provider.allResumes[index];
          final bool isExample = resume.id == 'example_1' || resume.id == 'example_2';

          return InkWell(
            onTap: () {
              provider.setActiveResume(resume);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditorScreen()));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12))
                      ),
                      child: Image.asset(
                        'assets/images/templates/${resume.templateId}.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.description, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(resume.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(resume.personalInfo.fullName.isEmpty ? "Unnamed" : resume.personalInfo.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => _showRenameDialog(context, provider, resume.id, resume.title),
                              child: const Icon(Icons.edit_outlined, color: Colors.blueGrey, size: 20),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => provider.duplicateResume(resume),
                              child: const Icon(Icons.copy, color: Colors.blueGrey, size: 20),
                            ),
                            const SizedBox(width: 12),
                            if (!isExample)
                              GestureDetector(
                                onTap: () => _showDeleteDialog(context, provider, resume.id),
                                child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              )
                            else
                              const SizedBox(width: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Create New'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateSearchScreen()));
        },
      ),
    );
  }

  // --- RENAME DIALOG ---
  void _showRenameDialog(BuildContext context, ResumeProvider provider, String id, String currentTitle) {
    final TextEditingController ctrl = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Resume'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Resume Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.renameResume(id, ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- DELETE DIALOG ---
  void _showDeleteDialog(BuildContext context, ResumeProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: const Text('Are you sure you want to delete this resume? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteResume(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- SETTINGS DIALOG ---
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.blue),
              title: const Text('Export Data (Backup)'),
              subtitle: const Text('Save all resumes to device', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing backup...')));

                final provider = context.read<ResumeProvider>();
                bool success = await provider.exportData();

                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to export data.'), backgroundColor: Colors.red));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('Import Data'),
              subtitle: const Text('Restore from backup file', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(dialogContext);

                final provider = context.read<ResumeProvider>();
                String resultMessage = await provider.importData();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(resultMessage),
                          backgroundColor: resultMessage.contains('Success') ? Colors.green : Colors.redAccent
                      )
                  );
                }
              },
            ),
            const Divider(),
            /* ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.purple),
              title: const Text('Generate Thumbnails', style: TextStyle(color: Colors.purple)),
              onTap: () {
                Navigator.pop(dialogContext);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ThumbnailGeneratorScreen()));
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.orange),
              title: const Text('Support / Feedback'),
              onTap: _launchPatreon    ,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }
}