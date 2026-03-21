import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../models/template_registry.dart';
import '../providers/resume_provider.dart';
import '../models/resume_data.dart';
import 'package:provider/provider.dart';


class ThumbnailGeneratorScreen extends StatefulWidget {
  const ThumbnailGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<ThumbnailGeneratorScreen> createState() => _ThumbnailGeneratorScreenState();
}

class _ThumbnailGeneratorScreenState extends State<ThumbnailGeneratorScreen> {
  double progress = 0;
  String currentTask = "Waiting to start...";
  bool isGenerating = false;

  Future<void> _generateAllThumbnails() async {
    setState(() => isGenerating = true);

    final provider = context.read<ResumeProvider>();

    // 1. THE FULL, RICH DATA (We try this first!)
    final fullData = provider.allResumes.firstWhere(
            (r) => r.id == 'example_2',
        orElse: () => provider.allResumes.first
    );

    // 2. THE SAFE, SHRUNKEN DATA (Our fallback for narrow templates)
    final safeData = ResumeData.fromMap(fullData.toMap());
    safeData.personalInfo.summary = "Detail-oriented Software Engineer specializing in cross-platform mobile and desktop applications. Passionate about building robust architectures.";
    if (safeData.experiences.isNotEmpty) safeData.experiences = [safeData.experiences.first];
    safeData.projects = [];
    safeData.customSections.removeWhere((s) => s.sectionTitle == 'Achievements' || s.sectionTitle == 'Interests');

    final Directory directory = await getApplicationDocumentsDirectory();
    final String folderPath = '${directory.path}/ResumeThumbnails';
    final Directory thumbnailDir = Directory(folderPath);

    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }

    int successCount = 0;

    for (int i = 0; i < appTemplates.length; i++) {
      final template = appTemplates[i];

      setState(() {
        currentTask = "Generating ${template.id}.png (${i + 1}/${appTemplates.length})...";
        progress = i / appTemplates.length;
      });

      try {
        // --- ATTEMPT 1: Try rendering with the massive, beautiful data ---
        final pdfDoc = await template.builder(fullData, template.defaultColor);
        final bytes = await pdfDoc.save();
        await _saveRasterizedPage(bytes, folderPath, template.id);
        successCount++;

      } catch (e) {
        debugPrint("Template ${template.id} overflowed! Retrying with safe data...");

        try {
          // --- ATTEMPT 2: It crashed! Fallback to the safe, short data ---
          final safePdfDoc = await template.builder(safeData, template.defaultColor);
          final safeBytes = await safePdfDoc.save();
          await _saveRasterizedPage(safeBytes, folderPath, template.id);
          successCount++;
          debugPrint("Template ${template.id} successfully saved using safe data.");
        } catch (e2) {
          debugPrint("Template ${template.id} failed completely: $e2");
        }
      }
    }

    setState(() {
      progress = 1.0;
      currentTask = "Done! Generated $successCount/${appTemplates.length} images.\nSaved to:\n$folderPath";
      isGenerating = false;
    });
  }

  // Helper function to keep our loop clean
  Future<void> _saveRasterizedPage(dynamic bytes, String folderPath, String templateId) async {
    await for (final page in Printing.raster(bytes, pages: [0], dpi: 150)) {
      final pngBytes = await page.toPng();
      final File imgFile = File('$folderPath/$templateId.png');
      await imgFile.writeAsBytes(pngBytes);
      break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secret Thumbnail Generator')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.photo_camera_back, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'This will safely generate all 50 PNG thumbnails using a Smart Fallback system for tight layouts.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (isGenerating) LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 20),
            Text(currentTask, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isGenerating ? null : _generateAllThumbnails,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('START GENERATING', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}