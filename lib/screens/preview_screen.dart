import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import '../models/resume_data.dart';
import '../models/template_registry.dart';
import '../providers/resume_provider.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final resumeData = provider.currentResume;
    final selectedTemplate = provider.selectedTemplate;
    final pdfColor = PdfColor.fromInt(resumeData.themeColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.tune, color: Colors.blue),
              label: const Text('Customize', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () => _showCustomizationSheet(context),
            ),
          )
        ],
      ),
      body: selectedTemplate == null
          ? const Center(child: Text('No Template Selected'))
          : LayoutBuilder(
          builder: (context, constraints) {
            // A4 aspect ratio is 1 : 1.414.
            // We divide the available height by 1.45 (adding a tiny buffer) to
            // calculate the exact maximum width needed to fit the whole page on screen!
            final maxFitWidth = constraints.maxHeight / 1.45;

            return PdfPreview(
              maxPageWidth: maxFitWidth, // <-- THIS IS THE MAGIC FIX
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
              build: (format) async {
                final pdfDocument = await selectedTemplate.builder(resumeData, pdfColor);
                return pdfDocument.save();
              },
            );
          }
      ),
    );
  }

  void _showCustomizationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      // Removes the dimming effect so you can see the PDF clearly behind the menu
      barrierColor: Colors.black12,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const CustomizationBottomSheet(),
    );
  }
}

class CustomizationBottomSheet extends StatefulWidget {
  const CustomizationBottomSheet({Key? key}) : super(key: key);
  @override
  State<CustomizationBottomSheet> createState() => _CustomizationBottomSheetState();
}

class _CustomizationBottomSheetState extends State<CustomizationBottomSheet> {
  bool _showAllColors = false;

  final List<Color> _fullPalette = [
    Colors.grey, Colors.indigo[900]!, Colors.deepPurple, Colors.lightBlue, Colors.tealAccent[700]!, Colors.green[800]!, Colors.brown[700]!, Colors.redAccent[100]!, Colors.amber,
    Colors.blueGrey[900]!, Colors.blueGrey, Colors.indigoAccent[100]!, Colors.indigo[800]!, Colors.teal, Colors.lightGreen, Colors.orange, Colors.brown[600]!, Colors.orange[700]!,
    Colors.grey[300]!, Colors.black, Colors.blue, Colors.pinkAccent, Colors.cyan, Colors.deepOrange, Colors.red, Colors.yellow,
  ];

  final List<String> fonts = ['Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Merriweather', 'EB Garamond', 'Playfair Display', 'Ubuntu', 'Poppins', 'Lora'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final data = provider.currentResume;
    final bool isTwoColumn = provider.selectedTemplate?.tags.any((t) => ['sidebar', 'split', 'column', 'two-column'].contains(t.toLowerCase())) ?? false;

    return SizedBox(
      // --- REDUCED HEIGHT TO 55% OF SCREEN SO PDF IS VISIBLE ---
      height: MediaQuery.of(context).size.height * 0.55,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
              child: Column(
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  const TabBar(
                    labelColor: Colors.blue, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue,
                    tabs: [Tab(icon: Icon(Icons.dashboard_customize), text: 'Layout'), Tab(icon: Icon(Icons.color_lens), text: 'Colors'), Tab(icon: Icon(Icons.tune), text: 'Format')],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildLayoutGrid(provider), _buildColorPicker(provider, data), _buildFormattingSettings(provider, data, isTwoColumn)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutGrid(ResumeProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.70
      ),
      itemCount: appTemplates.length,
      itemBuilder: (context, index) {
        final template = appTemplates[index];
        final isSelected = provider.selectedTemplate?.id == template.id;
        final themeColor = Color(provider.currentResume.themeColor);

        return GestureDetector(
          onTap: () => provider.setTemplate(template),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? themeColor : Colors.grey[300]!, width: isSelected ? 3 : 1),
              boxShadow: isSelected ? [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      // --- FIX: THIS MAKES THE PAPER PURE WHITE! ---
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[200]!)
                    ),
                    child: Image.asset(
                      'assets/images/templates/${template.id}.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, left: 4, right: 4),
                    child: Text(
                        template.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey[700]
                        )
                    )
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker(ResumeProvider provider, ResumeData data) {
    final displayedColors = _showAllColors ? _fullPalette : _fullPalette.take(18).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Theme Accent Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: displayedColors.map((color) {
              final isSelected = data.themeColor == color.value;
              return GestureDetector(
                onTap: () => provider.updateThemeColor(color),
                child: Container(width: 45, height: 45, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.white, width: 2) : Border.all(color: Colors.transparent), boxShadow: [if (isSelected) BoxShadow(color: Colors.black38, blurRadius: 4, spreadRadius: 1)]), child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null),
              );
            }).toList(),
          ),
          TextButton(onPressed: () => setState(() => _showAllColors = !_showAllColors), child: Text(_showAllColors ? 'See less ^' : 'See more v', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // ==========================================
  // UPDATED: COLLAPSIBLE FORMATTING TABS
  // ==========================================
  Widget _buildFormattingSettings(ResumeProvider provider, ResumeData data, bool isTwoColumn) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        // 1. SECTION ORDER ACCORDION
        ExpansionTile(
          initiallyExpanded: true, // Keep the first one open by default
          iconColor: Colors.blue,
          collapsedIconColor: Colors.grey,
          title: const Text('Section Order', style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: isTwoColumn
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Left column', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)), const SizedBox(height: 10),
                    ReorderableListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.leftColumn.length, onReorder: (o, n) => provider.reorderLeftColumn(o, n), itemBuilder: (c, i) => _buildDraggableCard(data.leftColumn[i], true, provider, isTwoColumn)),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Right column', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)), const SizedBox(height: 10),
                    ReorderableListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.rightColumn.length, onReorder: (o, n) => provider.reorderRightColumn(o, n), itemBuilder: (c, i) => _buildDraggableCard(data.rightColumn[i], false, provider, isTwoColumn)),
                  ])),
                ],
              )
                  : ReorderableListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.singleColumn.length,
                onReorder: (o, n) => provider.reorderSingleColumn(o, n),
                itemBuilder: (c, i) => _buildDraggableCard(data.singleColumn[i], true, provider, isTwoColumn),
              ),
            ),
          ],
        ),

        // 2. TYPOGRAPHY ACCORDION
        ExpansionTile(
          iconColor: Colors.blue,
          collapsedIconColor: Colors.grey,
          title: const Text('Typography', style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Family Dropdown
                  const Text('Font Family', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: fonts.contains(data.fontFamily) ? data.fontFamily : 'Roboto', isExpanded: true, items: fonts.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (val) => provider.updateFontFamily(val!))),
                  ),
                  const SizedBox(height: 15),

                  // Font Style Buttons (Compact Row)
                  Row(
                    children: [
                      _buildFontStyleBox('Normal', 'normal', data.bodyTextStyle, provider), const SizedBox(width: 10),
                      _buildFontStyleBox('Bold', 'bold', data.bodyTextStyle, provider), const SizedBox(width: 10),
                      _buildFontStyleBox('Italic', 'italic', data.bodyTextStyle, provider),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Font Size Slider
                  _buildSlider('Font Size', data.fontSize, 9, 14, (val) => provider.updateFontSize(val)),
                ],
              ),
            ),
          ],
        ),

        // 3. SPACING ACCORDION
        ExpansionTile(
          iconColor: Colors.blue,
          collapsedIconColor: Colors.grey,
          title: const Text('Spacing', style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildSlider('Section Spacing', data.sectionSpacing, 10, 30, (val) => provider.updateSectionSpacing(val)),
                  const SizedBox(height: 10),
                  _buildSlider('Paragraph Spacing', data.paragraphSpacing, 2, 15, (val) => provider.updateParagraphSpacing(val)),
                  const SizedBox(height: 10),
                  _buildSlider('Line Spacing', data.lineSpacing, 1.0, 2.5, (val) => provider.updateLineSpacing(val)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- COMPACT UI HELPERS ---

  Widget _buildDraggableCard(String title, bool isLeft, ResumeProvider provider, bool isTwoColumn) {
    return Card(
      key: ValueKey(title), margin: const EdgeInsets.only(bottom: 8), elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8), leading: const Icon(Icons.drag_indicator, color: Colors.grey), title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        // Only show cross-column arrows if it's a 2-column layout
        trailing: isTwoColumn ? IconButton(icon: Icon(isLeft ? Icons.arrow_forward : Icons.arrow_back, size: 16, color: Colors.blue), onPressed: () => provider.moveSectionToColumn(title, !isLeft)) : null,
      ),
    );
  }

  Widget _buildFontStyleBox(String label, String styleValue, String currentStyle, ResumeProvider provider) {
    final isSelected = currentStyle == styleValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.updateBodyTextStyle(styleValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10), // Made more compact
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text('Aa', style: TextStyle(fontSize: 16, color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: styleValue == 'bold' ? FontWeight.bold : FontWeight.normal,
                fontStyle: styleValue == 'italic' ? FontStyle.italic : FontStyle.normal,
              )),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.blue : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)), Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))]),
        SliderTheme(
          data: SliderThemeData(trackHeight: 2, activeTrackColor: Colors.blue, inactiveTrackColor: Colors.grey[200], thumbColor: Colors.blue, overlayColor: Colors.blue.withOpacity(0.2), thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

// ==============================================================
// SMART THUMBNAIL ENGINE (Zero memory load!)
// ==============================================================
class SmartTemplateThumbnail extends StatelessWidget {
  final List<String> tags;
  final Color themeColor;

  const SmartTemplateThumbnail({Key? key, required this.tags, required this.themeColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate fake "text lines" for the wireframe
    Widget mockTextLines() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (i) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        height: 4,
        width: double.infinity,
        color: Colors.grey.withOpacity(0.3),
      )),
    );

    // 1. SIDEBAR LAYOUTS
    if (tags.contains('sidebar')) {
      final isRight = tags.contains('right');
      return Row(
        children: [
          if (!isRight) Container(width: 25, color: themeColor.withOpacity(0.8)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 8, width: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  mockTextLines(),
                  const SizedBox(height: 8),
                  mockTextLines(),
                ],
              ),
            ),
          ),
          if (isRight) Container(width: 25, color: themeColor.withOpacity(0.8)),
        ],
      );
    }

    // 2. BANNER LAYOUTS
    if (tags.contains('banner')) {
      return Column(
        children: [
          Container(height: 25, color: themeColor.withOpacity(0.8)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mockTextLines(),
                  const SizedBox(height: 8),
                  mockTextLines(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 3. SPLIT / TWO-COLUMN / GRID LAYOUTS
    if (tags.contains('split') || tags.contains('column') || tags.contains('grid')) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 10, width: double.infinity, color: themeColor.withOpacity(0.8)),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: mockTextLines()),
                  const SizedBox(width: 8),
                  Expanded(child: mockTextLines()),
                ],
              ),
            )
          ],
        ),
      );
    }

    // 4. CENTERED / DEFAULT LAYOUTS
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 12, width: 60, color: themeColor.withOpacity(0.8)),
          const SizedBox(height: 8),
          Container(height: 4, width: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          mockTextLines(),
          const SizedBox(height: 8),
          mockTextLines(),
        ],
      ),
    );
  }
}