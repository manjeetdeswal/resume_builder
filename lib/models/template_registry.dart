import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/resume_data.dart';
import '../services/pdf_generator.dart';

class ResumeTemplate {
  final String id;
  final String name;
  final List<String> tags;
  final PdfColor defaultColor;
  final Future<pw.Document> Function(ResumeData, PdfColor) builder;

  ResumeTemplate({required this.id, required this.name, required this.tags, required this.defaultColor, required this.builder});
}

final List<ResumeTemplate> appTemplates = [
  // --- THE CORPORATE COLLECTION (1-10) ---
  ResumeTemplate(id: 't1', name: 'The Executive', tags: ['banner', 'purple'], defaultColor: const PdfColor.fromInt(0xFF7B1FA2), builder: buildT1BannerSummary),
  ResumeTemplate(id: 't2', name: 'The Professional', tags: ['green', 'centered', 'classic'], defaultColor: const PdfColor.fromInt(0xFF689F38), builder: buildT2TopBarCenter),
  ResumeTemplate(id: 't3', name: 'The Strategist', tags: ['sidebar', 'green', 'avatar'], defaultColor: const PdfColor.fromInt(0xFF689F38), builder: buildT3SidebarAvatar),
  ResumeTemplate(id: 't4', name: 'The Authority', tags: ['black', 'thick', 'header'], defaultColor: const PdfColor.fromInt(0xFF212121), builder: buildT4ThickHeader),
  ResumeTemplate(id: 't5', name: 'The Catalyst', tags: ['orange', 'split', 'avatar'], defaultColor: const PdfColor.fromInt(0xFFE65100), builder: buildT5AvatarSplit),
  ResumeTemplate(id: 't6', name: 'The Vanguard', tags: ['pink', 'banner', 'timeline'], defaultColor: const PdfColor.fromInt(0xFFD81B60), builder: buildT6BannerTimeline),
  ResumeTemplate(id: 't7', name: 'The Minimalist', tags: ['blue', 'minimal', 'lines'], defaultColor: const PdfColor.fromInt(0xFF039BE5), builder: buildT7MinimalLines),
  ResumeTemplate(id: 't8', name: 'The Director', tags: ['blue', 'banner', 'centered'], defaultColor: const PdfColor.fromInt(0xFF0D47A1), builder: buildT8BannerCenter),
  ResumeTemplate(id: 't9', name: 'The Innovator', tags: ['orange', 'rounded', 'modern'], defaultColor: const PdfColor.fromInt(0xFFF57C00), builder: buildT9RoundedBanner),
  ResumeTemplate(id: 't10', name: 'The Chronos', tags: ['teal', 'sidebar', 'timeline'], defaultColor: const PdfColor.fromInt(0xFF00BFA5), builder: buildT10SidebarTimeline),

  // --- THE CREATIVE COLLECTION (11-20) ---
  ResumeTemplate(id: 't11', name: 'The Artisan', tags: ['sidebar', 'light', 'red'], defaultColor: const PdfColor.fromInt(0xFF880E4F), builder: buildT11LightSidebar),
  ResumeTemplate(id: 't12', name: 'The Modernist', tags: ['navy', 'avatar', 'lines'], defaultColor: const PdfColor.fromInt(0xFF1A237E), builder: buildT12OverlappingAvatar),
  ResumeTemplate(id: 't13', name: 'The Profile', tags: ['green', 'sidebar', 'right'], defaultColor: const PdfColor.fromInt(0xFF1B5E20), builder: buildT13RightDarkSidebar),
  ResumeTemplate(id: 't14', name: 'The Timeline', tags: ['blue', 'timeline', 'header'], defaultColor: const PdfColor.fromInt(0xFF0D47A1), builder: buildT14RoundedHeaderTimeline),
  ResumeTemplate(id: 't15', name: 'The Clean Slate', tags: ['grey', 'minimal', 'sidebar'], defaultColor: const PdfColor.fromInt(0xFF424242), builder: buildT15GreySidebar),
  ResumeTemplate(id: 't16', name: 'The Headline', tags: ['cyan', 'banner', 'blue'], defaultColor: const PdfColor.fromInt(0xFF00B0FF), builder: buildT16BannerSummaryIn),
  ResumeTemplate(id: 't17', name: 'The Traditionalist', tags: ['classic', 'center', 'lines'], defaultColor: const PdfColor.fromInt(0xFF000000), builder: buildT17CenteredSplitContact),
  ResumeTemplate(id: 't18', name: 'The Editorial', tags: ['tan', 'block', 'split'], defaultColor: const PdfColor.fromInt(0xFFBCAAA4), builder: buildT18BlockTopLeft),
  ResumeTemplate(id: 't19', name: 'The Visionary', tags: ['purple', 'banner', 'split'], defaultColor: const PdfColor.fromInt(0xFF7B1FA2), builder: buildT19SplitBanner),
  ResumeTemplate(id: 't20', name: 'The Milestone', tags: ['gold', 'block', 'right'], defaultColor: const PdfColor.fromInt(0xFFFBC02D), builder: buildT20BlockTopRight),

  // --- THE STARTUP COLLECTION (21-30) ---
  ResumeTemplate(id: 't21', name: 'The Pioneer', tags: ['yellow', 'avatar', 'timeline'], defaultColor: const PdfColor.fromInt(0xFFFBC02D), builder: buildT21YellowTimeline),
  ResumeTemplate(id: 't22', name: 'The Dynamic', tags: ['red', 'split', 'column'], defaultColor: const PdfColor.fromInt(0xFFC62828), builder: buildT22RedTwoCol),
  ResumeTemplate(id: 't23', name: 'The Focal Point', tags: ['centered', 'yellow', 'timeline'], defaultColor: const PdfColor.fromInt(0xFFFBC02D), builder: buildT23CenteredTimeline),
  ResumeTemplate(id: 't24', name: 'The Essential', tags: ['rust', 'orange', 'minimal'], defaultColor: const PdfColor.fromInt(0xFFD84315), builder: buildT24RustMinimal),
  ResumeTemplate(id: 't25', name: 'The Streamline', tags: ['teal', 'banner', 'clean'], defaultColor: const PdfColor.fromInt(0xFF00897B), builder: buildT25TealSummaryBanner),
  ResumeTemplate(id: 't26', name: 'The Prestige', tags: ['gold', 'minimal', 'border'], defaultColor: const PdfColor.fromInt(0xFFF9A825), builder: buildT26GoldBorder),
  ResumeTemplate(id: 't27', name: 'The Formal', tags: ['black', 'classic', 'centered'], defaultColor: const PdfColor.fromInt(0xFF000000), builder: buildT27BlackClassic),
  ResumeTemplate(id: 't28', name: 'The Framework', tags: ['blue', 'border', 'column'], defaultColor: const PdfColor.fromInt(0xFF1976D2), builder: buildT28BlueTwoCol),
  ResumeTemplate(id: 't29', name: 'The Bold', tags: ['purple', 'banner', 'modern'], defaultColor: const PdfColor.fromInt(0xFF7B1FA2), builder: buildT29PurpleBanner),
  ResumeTemplate(id: 't30', name: 'The Signature', tags: ['maroon', 'banner', 'red'], defaultColor: const PdfColor.fromInt(0xFF880E4F), builder: buildT30MaroonBannerSummary),

  // --- THE ACADEMIC COLLECTION (31-40) ---
  ResumeTemplate(id: 't31', name: 'The Scholar', tags: ['navy', 'avatar', 'line'], defaultColor: const PdfColor.fromInt(0xFF1565C0), builder: buildT31AvatarLine),
  ResumeTemplate(id: 't32', name: 'The Impact', tags: ['yellow', 'thick', 'banner'], defaultColor: const PdfColor.fromInt(0xFFFBC02D), builder: buildT32ThickBanner),
  ResumeTemplate(id: 't33', name: 'The Spectrum', tags: ['pink', 'lines', 'banner'], defaultColor: const PdfColor.fromInt(0xFFE91E63), builder: buildT33SectionLines),
  ResumeTemplate(id: 't34', name: 'The Dualist', tags: ['purple', 'two-column', 'split'], defaultColor: const PdfColor.fromInt(0xFF7E57C2), builder: buildT34LeftTitles),
  ResumeTemplate(id: 't35', name: 'The Curator', tags: ['grey', 'sidebar', 'modern'], defaultColor: const PdfColor.fromInt(0xFF37474F), builder: buildT35GreySidebar),
  ResumeTemplate(id: 't36', name: 'The Clarity', tags: ['blue', 'light', 'centered'], defaultColor: const PdfColor.fromInt(0xFF03A9F4), builder: buildT36CenterTitles),
  ResumeTemplate(id: 't37', name: 'The Emblem', tags: ['red', 'box', 'sidebar'], defaultColor: const PdfColor.fromInt(0xFFB71C1C), builder: buildT37ColorSummaryBox),
  ResumeTemplate(id: 't38', name: 'The Navigator', tags: ['navy', 'accent', 'sidebar'], defaultColor: const PdfColor.fromInt(0xFF1A237E), builder: buildT38AccentLine),
  ResumeTemplate(id: 't39', name: 'The Motif', tags: ['white', 'dots', 'clean'], defaultColor: const PdfColor.fromInt(0xFF0D47A1), builder: buildT39WhiteDots),
  ResumeTemplate(id: 't40', name: 'The Focus', tags: ['green', 'right', 'box'], defaultColor: const PdfColor.fromInt(0xFF1B5E20), builder: buildT40RightBox),

  // --- THE ELITE COLLECTION (41-50) ---
  ResumeTemplate(id: 't41', name: 'The Prime', tags: ['green', 'right', 'block'], defaultColor: const PdfColor.fromInt(0xFF81C784), builder: buildT41RightHeaderGreen),
  ResumeTemplate(id: 't42', name: 'The Vertex', tags: ['red', 'right', 'timeline'], defaultColor: const PdfColor.fromInt(0xFF880E4F), builder: buildT42RightHeaderRed),
  ResumeTemplate(id: 't43', name: 'The Origin', tags: ['cyan', 'right', 'line'], defaultColor: const PdfColor.fromInt(0xFF00BCD4), builder: buildT43RightHeaderCyan),
  ResumeTemplate(id: 't44', name: 'The Ascent', tags: ['purple', 'lines', 'thick'], defaultColor: const PdfColor.fromInt(0xFF673AB7), builder: buildT44PurpleThickLines),
  ResumeTemplate(id: 't45', name: 'The Momentum', tags: ['green', 'banner', 'timeline'], defaultColor: const PdfColor.fromInt(0xFF4CAF50), builder: buildT45GreenBanner),
  ResumeTemplate(id: 't46', name: 'The Metric', tags: ['pink', 'centered', 'box'], defaultColor: const PdfColor.fromInt(0xFFF06292), builder: buildT46PinkCentered),
  ResumeTemplate(id: 't47', name: 'The Paradigm', tags: ['navy', 'split', 'left'], defaultColor: const PdfColor.fromInt(0xFF1A237E), builder: buildT47NavyHalfSplit),
  ResumeTemplate(id: 't48', name: 'The Matrix', tags: ['black', 'grid', 'banner'], defaultColor: const PdfColor.fromInt(0xFF000000), builder: buildT48BlackGrid),
  ResumeTemplate(id: 't49', name: 'The Synthesis', tags: ['blue', 'split', 'right'], defaultColor: const PdfColor.fromInt(0xFF0D47A1), builder: buildT49BlueHalfSplit),
  ResumeTemplate(id: 't50', name: 'The Architect', tags: ['grey', 'grid', 'elegant'], defaultColor: const PdfColor.fromInt(0xFF000000), builder: buildT50GreyGrid),
];