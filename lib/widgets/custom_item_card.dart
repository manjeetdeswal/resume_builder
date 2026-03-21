import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../models/resume_data.dart';

// =======================================================
// CUSTOM ITEM CARD (Holds text controllers so keyboard stays open!)
// =======================================================
class CustomItemCard extends StatefulWidget {
  final int sectionIndex;
  final int itemIndex;
  final dynamic item; // We use dynamic here to avoid import issues, though CustomItem is better

  const CustomItemCard({
    Key? key,
    required this.sectionIndex,
    required this.itemIndex,
    required this.item,
  }) : super(key: key);

  @override
  State<CustomItemCard> createState() => _CustomItemCardState();
}

class _CustomItemCardState extends State<CustomItemCard> {
  late TextEditingController _titleCtrl;
  late TextEditingController _subCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current data
    _titleCtrl = TextEditingController(text: widget.item.title);
    _subCtrl = TextEditingController(text: widget.item.subtitle);
    _dateCtrl = TextEditingController(text: widget.item.date);
    _descCtrl = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subCtrl.dispose();
    _dateCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ResumeProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => provider.removeCustomItem(widget.sectionIndex, widget.itemIndex),
                ),
              ],
            ),
            TextField(
              controller: _titleCtrl,
              // Explains it is the primary, bolded text
              decoration: const InputDecoration(labelText: 'Item Title (Appears Bold on the Left)'),
              onChanged: (val) => provider.updateCustomItem(widget.sectionIndex, widget.itemIndex, title: val),
            ),
            TextField(
              controller: _subCtrl,
              // Explains it sits right under the title
              decoration: const InputDecoration(labelText: 'Subtitle / Issuer (Appears Italicized below Title)'),
              onChanged: (val) => provider.updateCustomItem(widget.sectionIndex, widget.itemIndex, subtitle: val),
            ),
            TextField(
              controller: _dateCtrl,
              // Explains it gets pushed to the far right edge
              decoration: const InputDecoration(labelText: 'Date / Year (Pushed to the Right edge)'),
              onChanged: (val) => provider.updateCustomItem(widget.sectionIndex, widget.itemIndex, date: val),
            ),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              // Explains it forms the bulk paragraph at the bottom
              decoration: const InputDecoration(labelText: 'Description (Main paragraph text at the bottom)'),
              onChanged: (val) => provider.updateCustomItem(widget.sectionIndex, widget.itemIndex, description: val),
            ),
          ],
        ),
      ),
    );
  }
}