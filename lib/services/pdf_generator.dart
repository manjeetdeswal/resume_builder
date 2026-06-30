import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

String _getInitials(String name) {
  if (name.isEmpty) return 'U';
  List<String> parts = name.trim().split(' ');
  return parts.length > 1
      ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
      : name[0].toUpperCase();
}

// ==========================================
// 1. THE GLOBAL THEME & FONT ENGINE
// ==========================================
Future<pw.ThemeData> getAppPdfTheme([ResumeData? data]) async {
  pw.Font baseFont;
  pw.Font boldFont;
  pw.Font italicFont;
  final String chosenFont = data?.fontFamily ?? 'Roboto';

  switch (chosenFont) {
    case 'Open Sans':
      baseFont = await PdfGoogleFonts.openSansRegular();
      boldFont = await PdfGoogleFonts.openSansBold();
      italicFont = await PdfGoogleFonts.openSansItalic();
      break;
    case 'Lato':
      baseFont = await PdfGoogleFonts.latoRegular();
      boldFont = await PdfGoogleFonts.latoBold();
      italicFont = await PdfGoogleFonts.latoItalic();
      break;
    case 'Montserrat':
      baseFont = await PdfGoogleFonts.montserratRegular();
      boldFont = await PdfGoogleFonts.montserratBold();
      italicFont = await PdfGoogleFonts.montserratItalic();
      break;
    case 'Merriweather':
      baseFont = await PdfGoogleFonts.merriweatherRegular();
      boldFont = await PdfGoogleFonts.merriweatherBold();
      italicFont = await PdfGoogleFonts.merriweatherItalic();
      break;
    case 'EB Garamond':
    case 'Oswald':
      baseFont = await PdfGoogleFonts.oswaldRegular();
      boldFont = await PdfGoogleFonts.oswaldBold();
      italicFont = await PdfGoogleFonts.oswaldRegular();
      break;
    case 'Playfair Display':
      baseFont = await PdfGoogleFonts.playfairDisplayRegular();
      boldFont = await PdfGoogleFonts.playfairDisplayBold();
      italicFont = await PdfGoogleFonts.playfairDisplayItalic();
      break;
    case 'Ubuntu':
      baseFont = await PdfGoogleFonts.ubuntuRegular();
      boldFont = await PdfGoogleFonts.ubuntuBold();
      italicFont = await PdfGoogleFonts.ubuntuItalic();
      break;
    case 'Poppins':
      baseFont = await PdfGoogleFonts.poppinsRegular();
      boldFont = await PdfGoogleFonts.poppinsBold();
      italicFont = await PdfGoogleFonts.poppinsItalic();
      break;
    case 'Lora':
      baseFont = await PdfGoogleFonts.loraRegular();
      boldFont = await PdfGoogleFonts.loraBold();
      italicFont = await PdfGoogleFonts.loraItalic();
      break;
    case 'Roboto':
    default:
      baseFont = await PdfGoogleFonts.robotoRegular();
      boldFont = await PdfGoogleFonts.robotoBold();
      italicFont = await PdfGoogleFonts.robotoItalic();
      break;
  }

  final pw.FontWeight globalWeight = data?.bodyTextStyle == 'bold'
      ? pw.FontWeight.bold
      : pw.FontWeight.normal;
  final pw.FontStyle globalStyle = data?.bodyTextStyle == 'italic'
      ? pw.FontStyle.italic
      : pw.FontStyle.normal;

  return pw.ThemeData.withFont(
    base: baseFont,
    bold: boldFont,
    italic: italicFont,
    fontFallback: [await PdfGoogleFonts.notoSansDevanagariRegular()],
  ).copyWith(
    defaultTextStyle: pw.TextStyle(
      fontSize: data?.fontSize ?? 11.0,
      lineSpacing: data?.lineSpacing ?? 1.5,
      fontWeight: globalWeight,
      fontStyle: globalStyle,
    ),
  );
}

// ==========================================
// 2. CRASH-PROOF MULTI-PAGE HELPERS
// ==========================================
// FIX: A helper that applies padding to individual items to prevent pagination crashes
List<pw.Widget> _pad(List<pw.Widget> widgets, double left, double right) {
  return widgets
      .map(
        (w) => pw.Padding(
          padding: pw.EdgeInsets.only(left: left, right: right),
          child: w,
        ),
      )
      .toList();
}

Future<pw.Document> _buildSplitTemplate({
  required ResumeData data,
  required pw.ThemeData theme,
  required PdfColor leftBg,
  required PdfColor rightBg,
  required int flexL,
  required int flexR,
  required pw.Widget header,
  required List<pw.Widget> leftContent,
  required List<pw.Widget> rightContent,
  bool drawMiddleBorder = false,
}) async {
  final pdf = pw.Document(theme: theme);
  final double width = PdfPageFormat.a4.width;
  final double leftWidth = (width * flexL) / (flexL + flexR);

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        buildBackground: (context) => pw.Row(
          children: [
            pw.Container(
              width: leftWidth,
              decoration: pw.BoxDecoration(
                color: leftBg,
                border: drawMiddleBorder
                    ? const pw.Border(
                        right: pw.BorderSide(color: PdfColors.black),
                      )
                    : null,
              ),
            ),
            pw.Expanded(child: pw.Container(color: rightBg)),
          ],
        ),
      ),
      build: (context) => [
        header,
        pw.Partitions(
          children: [
            pw.Partition(
              width: leftWidth,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: leftContent,
              ), // Raw column, safely splits
            ),
            pw.Partition(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: rightContent,
              ), // Raw column, safely splits
            ),
          ],
        ),
      ],
    ),
  );
  return pdf;
}

pw.Widget _buildPartitions(
  pw.SpanningWidget left,
  pw.SpanningWidget right,
  int flexL,
  int flexR,
) {
  final double width = PdfPageFormat.a4.width;
  final double leftWidth = (width * flexL) / (flexL + flexR);
  return pw.Partitions(
    children: [
      pw.Partition(width: leftWidth, child: left),
      pw.Partition(child: right),
    ],
  );
}

// ==========================================
// 3. THE UNIVERSAL ITEM BUILDERS
// ==========================================
// ==========================================
// 3. THE UNIVERSAL ITEM BUILDERS (Fully Responsive!)
// ==========================================
pw.Widget _buildAvatar(
    ResumeData data,
    double size, {
      PdfColor? bgColor,
      PdfColor? fgColor,
      double? fontSize,
    }) {
  if (data.personalInfo.imagePath.isNotEmpty) {
    try {
      // FIX: Only try to read local files if we are NOT on the web
      if (!kIsWeb) {
        final file = File(data.personalInfo.imagePath);
        if (file.existsSync()) {
          return pw.Container(
            width: size,
            height: size,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              image: pw.DecorationImage(
                image: pw.MemoryImage(file.readAsBytesSync()),
                fit: pw.BoxFit.cover,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Fail silently and fallback to initials
    }
  }

  // Fallback to initials
  return pw.Container(
    width: size,
    height: size,
    decoration: pw.BoxDecoration(
      shape: pw.BoxShape.circle,
      color: bgColor ?? PdfColors.grey300,
    ),
    child: pw.Center(
      child: pw.Text(
        _getInitials(data.personalInfo.fullName),
        style: pw.TextStyle(
          fontSize: fontSize ?? size * 0.4,
          fontWeight: pw.FontWeight.bold,
          color: fgColor ?? PdfColors.black,
        ),
      ),
    ),
  );
}

pw.Widget _buildExp(
  Experience e,
  PdfColor a,
  PdfColor t,
  ResumeData data,
) => pw.Padding(
  padding: pw.EdgeInsets.only(bottom: data.paragraphSpacing),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // FIX: pw.Expanded forces long titles to wrap to a new line instead of colliding with the date!
          pw.Expanded(
            child: pw.Text(
              e.role,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: t),
            ),
          ),
          pw.SizedBox(width: 8),
          if (e.startDate.isNotEmpty || e.endDate.isNotEmpty)
            pw.Text(
              '${e.startDate} - ${e.endDate}',
              style: pw.TextStyle(
                color: t == PdfColors.white
                    ? PdfColors.grey300
                    : PdfColors.grey700,
              ),
            ),
        ],
      ),
      pw.Text(
        e.companyName,
        style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: t),
      ),
      if (e.description.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(e.description, style: pw.TextStyle(color: t)),
      ],
    ],
  ),
);

pw.Widget _buildTimelineExp(
  Experience e,
  PdfColor a,
  PdfColor t,
  ResumeData data,
) => pw.Padding(
  padding: pw.EdgeInsets.only(bottom: data.paragraphSpacing),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        flex: 1,
        child: pw.Text(
          '${e.startDate}\n${e.endDate}',
          style: pw.TextStyle(
            color: t == PdfColors.white ? PdfColors.grey300 : PdfColors.grey700,
          ),
        ),
      ),
      pw.Expanded(
        flex: 3,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              e.role,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: t),
            ),
            pw.Text(
              e.companyName,
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: t),
            ),
            if (e.description.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(e.description, style: pw.TextStyle(color: t)),
            ],
          ],
        ),
      ),
    ],
  ),
);

pw.Widget _buildDotTimelineExp(
  Experience e,
  PdfColor a,
  PdfColor t,
  ResumeData data,
) => pw.Padding(
  padding: pw.EdgeInsets.only(bottom: data.paragraphSpacing),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 4, right: 10),
        width: 8,
        height: 8,
        decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: a),
      ),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // FIX: Stacked vertically for guaranteed safety in narrow columns
            pw.Text(
              e.role,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: t),
            ),
            pw.Text(
              '${e.companyName} | ${e.startDate} - ${e.endDate}',
              style: pw.TextStyle(
                color: t == PdfColors.white
                    ? PdfColors.grey300
                    : PdfColors.grey600,
              ),
            ),
            if (e.description.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(e.description, style: pw.TextStyle(color: t)),
            ],
          ],
        ),
      ),
    ],
  ),
);

pw.Widget _buildTimelineItem(
  Experience exp,
  PdfColor a,
  PdfColor t,
  ResumeData data,
) => pw.Padding(
  padding: pw.EdgeInsets.only(bottom: data.paragraphSpacing),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Column(
        children: [
          pw.Container(
            width: 10,
            height: 10,
            decoration: pw.BoxDecoration(color: a, shape: pw.BoxShape.circle),
          ),
          pw.Container(width: 2, height: 40, color: a),
        ],
      ),
      pw.SizedBox(width: 10),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              exp.role,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: t),
            ),
            pw.Text(
              '${exp.companyName} | ${exp.startDate} - ${exp.endDate}',
              style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
                color: t == PdfColors.white
                    ? PdfColors.grey300
                    : PdfColors.grey700,
              ),
            ),
            if (exp.description.isNotEmpty) ...[
              pw.SizedBox(height: 5),
              pw.Text(exp.description, style: pw.TextStyle(color: t)),
            ],
          ],
        ),
      ),
    ],
  ),
);

pw.Widget _buildEdu(Education e, PdfColor a, PdfColor t, ResumeData data) =>
    pw.Padding(
      padding: pw.EdgeInsets.only(bottom: data.paragraphSpacing),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // FIX: Expanded added here as well
              pw.Expanded(
                child: pw.Text(
                  e.degree,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: t),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                e.year,
                style: pw.TextStyle(
                  color: t == PdfColors.white
                      ? PdfColors.grey300
                      : PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Text(
            e.institution,
            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: t),
          ),
        ],
      ),
    );

pw.Widget _buildProject(Project p, PdfColor a, PdfColor t, ResumeData data) {
  String formatUrl(String url) => url.startsWith('http') ? url : 'https://$url';
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: data.paragraphSpacing),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // FIX: Stacked vertically. Long URLs won't squish the project title anymore!
        pw.Text(
          p.title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: t),
        ),
        if (p.link.isNotEmpty)
          pw.UrlLink(
            destination: formatUrl(p.link),
            child: pw.Text(
              p.link,
              style: pw.TextStyle(
                color: PdfColors.blue,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
        if (p.description.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(p.description, style: pw.TextStyle(color: t)),
        ],
      ],
    ),
  );
}

pw.Widget _buildCustomItem(
  CustomItem item,
  PdfColor a,
  PdfColor t,
  ResumeData data,
) => pw.Padding(
  padding: pw.EdgeInsets.only(bottom: data.paragraphSpacing),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // FIX: Expanded added to custom items too
          pw.Expanded(
            child: pw.Text(
              item.title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: t),
            ),
          ),
          pw.SizedBox(width: 8),
          if (item.date.isNotEmpty)
            pw.Text(item.date, style: pw.TextStyle(color: a)),
        ],
      ),
      if (item.subtitle.isNotEmpty)
        pw.Text(
          item.subtitle,
          style: pw.TextStyle(
            fontStyle: pw.FontStyle.italic,
            color: t == PdfColors.white ? PdfColors.grey300 : PdfColors.grey800,
          ),
        ),
      if (item.description.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(item.description, style: pw.TextStyle(color: t)),
      ],
    ],
  ),
);

pw.Widget _build2ColSkills(
  List<Skill> skills,
  PdfColor a,
  PdfColor t,
  ResumeData data,
) {
  final half = (skills.length / 2).ceil();
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: skills
              .take(half)
              .map((s) => pw.Text(s.name, style: pw.TextStyle(color: t)))
              .toList(),
        ),
      ),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: skills
              .skip(half)
              .map((s) => pw.Text(s.name, style: pw.TextStyle(color: t)))
              .toList(),
        ),
      ),
    ],
  );
}

pw.Widget _buildWrapSkills(
  List<Skill> skills,
  PdfColor a,
  PdfColor t,
  ResumeData data,
) => pw.Wrap(
  spacing: 8,
  runSpacing: 4,
  children: skills
      .map(
        (s) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            s.name,
            style: const pw.TextStyle(color: PdfColors.black),
          ),
        ),
      )
      .toList(),
);

// --- TITLE BUILDERS ---

// --- TITLE BUILDERS ---
pw.Widget _buildSideText(String t) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 5),
  child: pw.Text(t, style: const pw.TextStyle(color: PdfColors.white)),
);

pw.Widget _buildTitle(String t, PdfColor a, PdfColor text, double s) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          t,
          style: pw.TextStyle(
            fontSize: s * 1.3,
            color: a,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
      ],
    );

pw.Widget _buildCenterTitle(String t, PdfColor a, PdfColor text, double s) =>
    pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            t,
            style: pw.TextStyle(
              fontSize: s * 1.3,
              color: a,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
        ],
      ),
    );

pw.Widget _buildFullDividerTitle(
  String t,
  PdfColor a,
  PdfColor text,
  double s,
) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Divider(color: a),
    pw.SizedBox(height: 5),
    pw.Text(
      t,
      style: pw.TextStyle(
        fontSize: s * 1.3,
        color: a,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
    pw.SizedBox(height: 5),
  ],
);

pw.Widget _buildInlineTitle(String t, PdfColor a, PdfColor text, double s) =>
    pw.Row(
      children: [
        pw.Text(
          t,
          style: pw.TextStyle(
            color: a,
            fontSize: s * 1.3,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(child: pw.Divider(color: a)),
      ],
    );

pw.Widget _buildMainTitle(String t, PdfColor a, PdfColor text, double s) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          t,
          style: pw.TextStyle(
            fontSize: s * 1.4,
            color: a,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(color: a),
        pw.SizedBox(height: 10),
      ],
    );

pw.Widget _buildMainSectionTitle(
  String t,
  PdfColor a,
  PdfColor text,
  double s,
) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Text(
      t,
      style: pw.TextStyle(
        fontSize: s * 1.4,
        color: a,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
    pw.Divider(color: a),
    pw.SizedBox(height: 10),
  ],
);

// ==========================================
// 4. THE DYNAMIC SECTION ROUTER
// ==========================================
List<pw.Widget> _renderSection(
  String sectionName,
  ResumeData data,
  PdfColor accent,
  PdfColor text,
  pw.Widget Function(String, PdfColor, PdfColor, double) titleBuilder,
  pw.Widget Function(Experience, PdfColor, PdfColor, ResumeData) expBuilder,
  pw.Widget Function(Education, PdfColor, PdfColor, ResumeData) eduBuilder,
  pw.Widget Function(Project, PdfColor, PdfColor, ResumeData) projBuilder,
  pw.Widget Function(List<Skill>, PdfColor, PdfColor, ResumeData) skillsBuilder,
) {
  List<pw.Widget> widgets = [];
  final baseSize = data.fontSize;

  if (sectionName == 'Experience' && data.experiences.isNotEmpty) {
    widgets = [
      titleBuilder('Experience', accent, text, baseSize),
      ...data.experiences.map((e) => expBuilder(e, accent, text, data)),
    ];
  } else if (sectionName == 'Education' && data.educations.isNotEmpty) {
    widgets = [
      titleBuilder('Education', accent, text, baseSize),
      ...data.educations.map((e) => eduBuilder(e, accent, text, data)),
    ];
  } else if (sectionName == 'Projects' && data.projects.isNotEmpty) {
    widgets = [
      titleBuilder('Projects', accent, text, baseSize),
      ...data.projects.map((p) => projBuilder(p, accent, text, data)),
    ];
  } else if ((sectionName == 'Skills' || sectionName == 'Languages') &&
      data.skills.isNotEmpty) {
    if (sectionName == 'Skills')
      widgets = [
        titleBuilder('Skills', accent, text, baseSize),
        skillsBuilder(data.skills, accent, text, data),
      ];
  } else {
    try {
      final custom = data.customSections.firstWhere(
        (s) => s.sectionTitle == sectionName,
      );
      if (custom.items.isNotEmpty)
        widgets = [
          titleBuilder(custom.sectionTitle, accent, text, baseSize),
          ...custom.items.map((i) => _buildCustomItem(i, accent, text, data)),
        ];
    } catch (_) {}
  }
  if (widgets.isNotEmpty) widgets.add(pw.SizedBox(height: data.sectionSpacing));
  return widgets;
}

// ==========================================
// 5. ALL 50 REFACTORED TEMPLATES!
// ==========================================

Future<pw.Document> buildT1BannerSummary(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          width: double.infinity,
          color: color,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                '${data.personalInfo.location} | ${data.personalInfo.phone}\n${data.personalInfo.email}',
                style: const pw.TextStyle(color: PdfColors.white),
              ),
              if (data.personalInfo.summary.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  data.personalInfo.summary,
                  style: const pw.TextStyle(color: PdfColors.white),
                ),
              ],
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildTitle,
                  _buildExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT2TopBarCenter(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Container(height: 15, width: double.infinity, color: color),
        pw.SizedBox(height: 20),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 2.2,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.Text(
              '${data.personalInfo.phone}      ${data.personalInfo.email}',
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: color, thickness: 1.5),
            pw.SizedBox(height: 10),
            if (data.personalInfo.summary.isNotEmpty) ...[
              pw.Text(
                data.personalInfo.summary,
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 15),
            ],
            ...data.singleColumn.expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildCenterTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT3SidebarAvatar(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: color,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          _buildAvatar(
            data,
            70,
            bgColor: PdfColors.white,
            fgColor: color,
            fontSize: 24,
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 1.8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '${data.personalInfo.location}\n${data.personalInfo.phone}\n${data.personalInfo.email}',
            style: const pw.TextStyle(color: PdfColors.white, lineSpacing: 1.5),
          ),
          pw.SizedBox(height: 20),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              PdfColors.white,
              PdfColors.white,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 20),
          ],
          ...data.rightColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT4ThickHeader(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Container(
          width: double.infinity,
          color: color,
          padding: const pw.EdgeInsets.symmetric(vertical: 15),
          child: pw.Center(
            child: pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 1.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${data.personalInfo.location}\n${data.personalInfo.phone}',
            ),
            pw.Text(data.personalInfo.email),
          ],
        ),
        pw.SizedBox(height: 15),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 15),
        ],
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT5AvatarSplit(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.grey100,
    flexL: 2,
    flexR: 1,
    header: pw.Container(
      color: color,
      padding: const pw.EdgeInsets.all(36),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              _buildAvatar(data, 50, fontSize: 20),
              pw.SizedBox(width: 15),
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                data.personalInfo.location,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
              pw.Text(
                data.personalInfo.phone,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
              pw.Text(
                data.personalInfo.email,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    ),
    leftContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 20),
          ],
          ...data.rightColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        36,
        36,
      ),
      pw.SizedBox(height: 36),
    ],
    rightContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        [
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        36,
        36,
      ),
      pw.SizedBox(height: 36),
    ],
  );
}

Future<pw.Document> buildT6BannerTimeline(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.2,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    '${data.personalInfo.location} | ${data.personalInfo.phone}\n${data.personalInfo.email}',
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
              _buildAvatar(data, 60, fontSize: 24),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.personalInfo.summary.isNotEmpty) ...[
                pw.Text(data.personalInfo.summary),
                pw.SizedBox(height: 15),
              ],
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildTitle,
                  _buildTimelineExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT7MinimalLines(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Text(
          data.personalInfo.fullName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: data.fontSize * 1.8,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(data.personalInfo.location),
            pw.Text(data.personalInfo.email),
          ],
        ),
        pw.Text(data.personalInfo.phone),
        pw.SizedBox(height: 15),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 15),
        ],
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT8BannerCenter(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          width: double.infinity,
          color: color,
          padding: const pw.EdgeInsets.all(30),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${data.personalInfo.location} | ${data.personalInfo.phone} | ${data.personalInfo.email}',
                style: const pw.TextStyle(color: PdfColors.white),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (data.personalInfo.summary.isNotEmpty) ...[
                pw.Text(
                  data.personalInfo.summary,
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
              ],
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildCenterTitle,
                  _buildExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT9RoundedBanner(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) => [
        pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.2,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    data.personalInfo.location,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                  pw.Text(
                    data.personalInfo.phone,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                  pw.Text(
                    data.personalInfo.email,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.personalInfo.summary.isNotEmpty) ...[
                pw.Text(data.personalInfo.summary),
                pw.SizedBox(height: 15),
              ],
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildInlineTitle,
                  _buildExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT10SidebarTimeline(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 3,
    header: pw.Row(
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            color: PdfColors.grey300,
            height: 100,
            child: pw.Center(
              child: _buildAvatar(
                data,
                60,
                bgColor: PdfColors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  data.personalInfo.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: data.fontSize * 2.2,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      data.personalInfo.location,
                      style: const pw.TextStyle(color: PdfColors.grey700),
                    ),
                    pw.Text(
                      '${data.personalInfo.phone} | ${data.personalInfo.email}',
                      style: const pw.TextStyle(color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    leftContent: [],
    rightContent: [
      pw.SizedBox(height: 20),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty)
            pw.Text(data.personalInfo.summary),
          ...data.singleColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildCenterTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        15,
        15,
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

Future<pw.Document> buildT11LightSidebar(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final lightBg = PdfColor(color.red, color.green, color.blue, 0.1);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: lightBg,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 2.5,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
            style: const pw.TextStyle(lineSpacing: 1.5),
          ),
          pw.SizedBox(height: 20),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildMainTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 20),
          ],
          ...data.rightColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildMainTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT12OverlappingAvatar(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Stack(
          children: [
            pw.Column(
              children: [
                pw.Container(
                  height: 80,
                  width: double.infinity,
                  color: color,
                  padding: const pw.EdgeInsets.only(left: 130, top: 30),
                  child: pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.2,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.Container(
                  height: 40,
                  width: double.infinity,
                  color: PdfColors.white,
                ),
              ],
            ),
            pw.Positioned(
              left: 40,
              top: 20,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.white, width: 3),
                ),
                child: _buildAvatar(data, 64, fontSize: 24),
              ),
            ),
          ],
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${data.personalInfo.location}\n${data.personalInfo.phone}',
                  ),
                  pw.Text(data.personalInfo.email),
                ],
              ),
              pw.SizedBox(height: 15),
              if (data.personalInfo.summary.isNotEmpty) ...[
                pw.Text(data.personalInfo.summary),
                pw.SizedBox(height: 15),
              ],
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildFullDividerTitle,
                  _buildExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT13RightDarkSidebar(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final lightColor = PdfColor(color.red, color.green, color.blue, 0.5);
  pw.Widget wTitle(String t, PdfColor a, PdfColor text, double s) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: double.infinity,
        color: lightColor,
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(
          t,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ),
      pw.SizedBox(height: 10),
    ],
  );

  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: color,
    flexL: 2,
    flexR: 1,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 2.2,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 20),
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 20),
          ],
          ...data.rightColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              wTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          pw.Center(child: _buildAvatar(data, 80, fontSize: 24)),
          pw.SizedBox(height: 30),
          _buildSideText(data.personalInfo.location),
          _buildSideText(data.personalInfo.phone),
          _buildSideText(data.personalInfo.email),
          pw.SizedBox(height: 30),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              PdfColors.white,
              PdfColors.white,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT14RoundedHeaderTimeline(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  pw.Widget rTitle(String t, PdfColor a, PdfColor text, double s) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: pw.BoxDecoration(
          color: a,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        ),
        child: pw.Text(
          t,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 15),
    ],
  );

  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.grey200,
    flexL: 2,
    flexR: 1,
    header: pw.Container(
      margin: const pw.EdgeInsets.all(20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(60),
          bottomLeft: pw.Radius.circular(60),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: PdfColors.white, width: 2),
            ),
            child: _buildAvatar(data, 76, fontSize: 24),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 2.2,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                data.personalInfo.location,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
              pw.Text(
                data.personalInfo.phone,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
              pw.Text(
                data.personalInfo.email,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    ),
    leftContent: _pad(
      data.rightColumn
          .expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              rTitle,
              _buildTimelineItem,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          )
          .toList(),
      30,
      15,
    ),
    rightContent: [
      pw.SizedBox(height: 20),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 20),
          ],
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

Future<pw.Document> buildT15GreySidebar(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.grey200,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          _buildAvatar(data, 60, bgColor: PdfColors.grey400, fontSize: 20),
          pw.SizedBox(height: 15),
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 1.8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Text(data.personalInfo.location),
          pw.Text(data.personalInfo.email),
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(width: 2, height: 40, color: PdfColors.grey800),
                pw.SizedBox(width: 5),
                pw.Expanded(child: pw.Text(data.personalInfo.summary)),
              ],
            ),
          ],
          pw.SizedBox(height: 30),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT16BannerSummaryIn(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) => [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              if (data.personalInfo.summary.isNotEmpty)
                pw.Text(
                  data.personalInfo.summary,
                  style: const pw.TextStyle(color: PdfColors.yellow),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT17CenteredSplitContact(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 2.2,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(data.personalInfo.location),
            pw.Text(data.personalInfo.email),
          ],
        ),
        pw.Text(data.personalInfo.phone),
        pw.SizedBox(height: 15),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 15),
        ],
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT18BlockTopLeft(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.Container(
        color: color,
        padding: const pw.EdgeInsets.all(30),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                _buildAvatar(data, 50, fontSize: 18),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 1.8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            _buildSideText(data.personalInfo.location),
            _buildSideText(data.personalInfo.email),
            _buildSideText(data.personalInfo.phone),
            pw.SizedBox(height: 20),
            if (data.personalInfo.summary.isNotEmpty)
              pw.Text(
                data.personalInfo.summary,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
          ],
        ),
      ),
      pw.Container(
        color: PdfColors.grey100,
        padding: const pw.EdgeInsets.all(30),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            ...data.leftColumn.expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _buildWrapSkills,
              ),
            ),
          ],
        ),
      ),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT19SplitBanner(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) => [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      data.personalInfo.fullName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: data.fontSize * 2.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '${data.personalInfo.location}\n${data.personalInfo.email} | ${data.personalInfo.phone}',
                      style: const pw.TextStyle(color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              if (data.personalInfo.summary.isNotEmpty)
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    data.personalInfo.summary,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT20BlockTopRight(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 2,
    flexR: 1,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildFullDividerTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
    rightContent: [
      pw.Container(
        color: color,
        padding: const pw.EdgeInsets.all(30),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 2.2,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 20),
            _buildSideText(data.personalInfo.location),
            _buildSideText(data.personalInfo.email),
            _buildSideText(data.personalInfo.phone),
          ],
        ),
      ),
      pw.SizedBox(height: 30),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(
              data.personalInfo.summary,
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
          ],
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildFullDividerTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT21YellowTimeline(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        _buildAvatar(data, 50, fontSize: 18),
        pw.SizedBox(height: 10),
        pw.Text(
          data.personalInfo.fullName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: data.fontSize * 2.4,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
          style: const pw.TextStyle(lineSpacing: 1.5),
        ),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildDotTimelineExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT22RedTwoCol(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.Padding(
      padding: const pw.EdgeInsets.all(36),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  _buildAvatar(data, 50, fontSize: 18),
                  pw.SizedBox(width: 15),
                  pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.4,
                      fontWeight: pw.FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              pw.Text(
                '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(
                  color: PdfColors.grey800,
                  lineSpacing: 1.5,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: color, thickness: 2),
          pw.SizedBox(height: 10),
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 10),
            pw.Divider(color: color, thickness: 1),
            pw.SizedBox(height: 15),
          ],
        ],
      ),
    ),
    leftContent: _pad(
      data.leftColumn
          .expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          )
          .toList(),
      36,
      20,
    ),
    rightContent: _pad(
      data.rightColumn
          .expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          )
          .toList(),
      0,
      36,
    ),
  );
}

Future<pw.Document> buildT23CenteredTimeline(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.5,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(lineSpacing: 1.5),
              ),
              pw.SizedBox(height: 15),
              _buildAvatar(data, 40, fontSize: 14),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildDotTimelineExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT24RustMinimal(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                _buildAvatar(data, 60, fontSize: 20),
                pw.SizedBox(width: 15),
                pw.Text(
                  data.personalInfo.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: data.fontSize * 2.4,
                    color: color,
                  ),
                ),
              ],
            ),
            pw.Text(
              '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(
                color: PdfColors.grey600,
                lineSpacing: 1.5,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 20),
        ],
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildTimelineExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT25TealSummaryBanner(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                _buildAvatar(data, 50, fontSize: 18),
                pw.SizedBox(width: 15),
                pw.Text(
                  data.personalInfo.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: data.fontSize * 2.4,
                    color: color,
                  ),
                ),
              ],
            ),
            pw.Text(
              '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(
                color: PdfColors.teal200,
                lineSpacing: 1.5,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        if (data.personalInfo.summary.isNotEmpty)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            color: color,
            child: pw.Text(
              data.personalInfo.summary,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
          ),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildTimelineExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT26GoldBorder(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(fontSize: data.fontSize * 2.5, color: color),
            ),
            pw.Row(
              children: [
                _buildAvatar(data, 40, fontSize: 14),
                pw.SizedBox(width: 10),
                pw.Text(
                  '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.orange200,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Divider(color: color, thickness: 2),
        pw.SizedBox(height: 5),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 5),
          pw.Divider(color: color, thickness: 2),
          pw.SizedBox(height: 15),
        ],
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT27BlackClassic(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.2,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${data.personalInfo.location} | ${data.personalInfo.phone}\n${data.personalInfo.email}',
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 15),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 15),
        ],
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildCenterTitle,
            _buildTimelineExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT28BlueTwoCol(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.Padding(
      padding: const pw.EdgeInsets.all(36),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  _buildAvatar(data, 50, fontSize: 18),
                  pw.SizedBox(width: 15),
                  pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.4,
                      fontWeight: pw.FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              pw.Text(
                '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(
                  color: PdfColors.blue300,
                  lineSpacing: 1.5,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: color, thickness: 3),
          pw.SizedBox(height: 10),
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 10),
            pw.Divider(color: color, thickness: 3),
            pw.SizedBox(height: 15),
          ],
        ],
      ),
    ),
    leftContent: _pad(
      data.leftColumn
          .expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          )
          .toList(),
      36,
      20,
    ),
    rightContent: _pad(
      data.rightColumn
          .expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          )
          .toList(),
      0,
      36,
    ),
  );
}

Future<pw.Document> buildT29PurpleBanner(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  _buildAvatar(data, 50, fontSize: 20),
                  pw.SizedBox(width: 15),
                  pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.4,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
              pw.Text(
                '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  lineSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.personalInfo.summary.isNotEmpty) ...[
                pw.Text(data.personalInfo.summary),
                pw.SizedBox(height: 15),
              ],
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildFullDividerTitle,
                  _buildTimelineExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT30MaroonBannerSummary(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.fromLTRB(36, 36, 36, 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  _buildAvatar(data, 50, fontSize: 20),
                  pw.SizedBox(width: 15),
                  pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.4,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
              pw.Text(
                '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  lineSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (data.personalInfo.summary.isNotEmpty)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 15,
            ),
            color: PdfColors.grey400,
            child: pw.Text(
              data.personalInfo.summary,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
          ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildFullDividerTitle,
                  _buildTimelineExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT31AvatarLine(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            _buildAvatar(data, 60, fontSize: 20),
            pw.SizedBox(width: 15),
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 2.9,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(data.personalInfo.location),
                pw.Text(data.personalInfo.email),
                pw.Text(data.personalInfo.phone),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Container(height: 4, width: double.infinity, color: color),
        pw.SizedBox(height: 15),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 15),
        ],
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildFullDividerTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT32ThickBanner(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Row(
            children: [
              _buildAvatar(data, 60, fontSize: 20),
              pw.SizedBox(width: 15),
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 3.2,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    data.personalInfo.location,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                  pw.Text(
                    data.personalInfo.email,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  _buildInlineTitle,
                  _buildExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT33SectionLines(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pw.Widget lineTitle(String t, PdfColor a, PdfColor text, double s) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(height: 3, width: double.infinity, color: a),
          pw.SizedBox(height: 5),
          pw.Text(
            t,
            style: pw.TextStyle(fontSize: s * 1.5, color: a),
          ),
          pw.SizedBox(height: 10),
        ],
      );
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          width: double.infinity,
          color: color,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.9,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    data.personalInfo.location,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                  pw.Text(
                    data.personalInfo.email,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.personalInfo.summary.isNotEmpty) ...[
                pw.Text(data.personalInfo.summary),
                pw.SizedBox(height: 15),
              ],
              ...data.singleColumn.expand(
                (sec) => _renderSection(
                  sec,
                  data,
                  color,
                  PdfColors.black,
                  lineTitle,
                  _buildExp,
                  _buildEdu,
                  _buildProject,
                  _build2ColSkills,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT34LeftTitles(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);

  // FIX 1: Change 'pw.Widget content' to 'pw.SpanningWidget content'
  pw.Widget rowSection(String title, pw.SpanningWidget content) =>
      _buildPartitions(
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: data.fontSize * 1.3, color: color),
        ),
        content,
        1,
        3,
      );

  pw.Widget buildItem(String name) {
    if (name == 'Experience')
      return rowSection(
        'Experience',
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: data.experiences
              .map((e) => _buildExp(e, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Education')
      return rowSection(
        'Education',
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: data.educations
              .map((e) => _buildEdu(e, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Projects')
      return rowSection(
        'Projects',
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: data.projects
              .map((p) => _buildProject(p, color, PdfColors.black, data))
              .toList(),
        ),
      );

    // FIX 2: Wrap _build2ColSkills inside a pw.Column so it becomes a valid SpanningWidget!
    if (name == 'Skills' || name == 'Languages')
      return rowSection(
        name,
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _build2ColSkills(data.skills, color, PdfColors.black, data),
          ],
        ),
      );

    try {
      final custom = data.customSections.firstWhere(
        (s) => s.sectionTitle == name,
      );
      return rowSection(
        custom.sectionTitle,
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: custom.items
              .map((i) => _buildCustomItem(i, color, PdfColors.black, data))
              .toList(),
        ),
      );
    } catch (_) {
      return pw.SizedBox();
    }
  }

  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Row(
          children: [
            _buildAvatar(data, 60, fontSize: 20),
            pw.SizedBox(width: 15),
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 2.9,
                color: color,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(data.personalInfo.location),
                pw.Text(data.personalInfo.email),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Container(height: 4, width: double.infinity, color: color),
        pw.SizedBox(height: 15),
        if (data.personalInfo.summary.isNotEmpty) ...[
          pw.Text(data.personalInfo.summary),
          pw.SizedBox(height: 15),
        ],
        ...data.singleColumn.map(
          (sec) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(height: 1, width: double.infinity, color: color),
              pw.SizedBox(height: 10),
              buildItem(sec),
              pw.SizedBox(height: 10),
            ],
          ),
        ),
      ],
    ),
  );

  return pdf;
}

Future<pw.Document> buildT35GreySidebar(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.grey200,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          _buildAvatar(data, 60, bgColor: PdfColors.grey400, fontSize: 20),
          pw.SizedBox(height: 15),
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 1.8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Text(data.personalInfo.location),
          pw.Text(data.personalInfo.email),
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(width: 2, height: 40, color: PdfColors.grey800),
                pw.SizedBox(width: 5),
                pw.Expanded(child: pw.Text(data.personalInfo.summary)),
              ],
            ),
          ],
          pw.SizedBox(height: 30),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT36CenterTitles(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 2.2,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            '${data.personalInfo.location} | ${data.personalInfo.phone} | ${data.personalInfo.email}',
          ),
        ),
        pw.SizedBox(height: 20),
        if (data.personalInfo.summary.isNotEmpty)
          pw.Text(data.personalInfo.summary, textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            _buildCenterTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _build2ColSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT37ColorSummaryBox(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 20),
      ..._pad(
        [
          _buildAvatar(data, 50, fontSize: 16),
          pw.SizedBox(height: 10),
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 2,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(data.personalInfo.location),
          pw.Text(data.personalInfo.email),
          pw.SizedBox(height: 15),
          if (data.personalInfo.summary.isNotEmpty)
            pw.Container(
              color: color,
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                data.personalInfo.summary,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
            ),
          pw.SizedBox(height: 20),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildDotTimelineExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT38AccentLine(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.grey100,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        [
          _buildAvatar(data, 60, fontSize: 20),
          pw.SizedBox(height: 15),
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 2.2,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(data.personalInfo.location),
          pw.Text(data.personalInfo.email),
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(width: 4, height: 60, color: color),
                pw.SizedBox(width: 8),
                pw.Expanded(child: pw.Text(data.personalInfo.summary)),
              ],
            ),
          ],
          pw.SizedBox(height: 20),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
    rightContent: [
      pw.SizedBox(height: 30),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildDotTimelineExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        30,
        30,
      ),
      pw.SizedBox(height: 30),
    ],
  );
}

Future<pw.Document> buildT39WhiteDots(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 20),
      ..._pad(
        [
          _buildAvatar(data, 60, fontSize: 20),
          pw.SizedBox(height: 15),
          pw.Text(
            data.personalInfo.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: data.fontSize * 2.2,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(data.personalInfo.location),
          pw.Text(data.personalInfo.email),
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(width: 4, height: 60, color: color),
                pw.SizedBox(width: 8),
                pw.Expanded(child: pw.Text(data.personalInfo.summary)),
              ],
            ),
          ],
          pw.SizedBox(height: 20),
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
    rightContent: [
      pw.SizedBox(height: 20),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildDotTimelineExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

Future<pw.Document> buildT40RightBox(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 2,
    flexR: 1,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        data.leftColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        36,
        20,
      ),
      pw.SizedBox(height: 36),
    ],
    rightContent: [
      pw.Container(
        color: color,
        width: double.infinity,
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 1.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              data.personalInfo.location,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
            pw.Text(
              data.personalInfo.email,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(width: 4, height: 40, color: color),
                pw.SizedBox(width: 8),
                pw.Expanded(child: pw.Text(data.personalInfo.summary)),
              ],
            ),
          pw.SizedBox(height: 20),
          ...data.rightColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

Future<pw.Document> buildT41RightHeaderGreen(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 2,
    flexR: 1,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        data.leftColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildMainSectionTitle,
                _buildTimelineItem,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        36,
        20,
      ),
      pw.SizedBox(height: 36),
    ],
    rightContent: [
      pw.Container(
        color: color,
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 2,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              data.personalInfo.location,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
            pw.Text(
              data.personalInfo.email,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
            pw.Text(
              data.personalInfo.phone,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
            if (data.personalInfo.summary.isNotEmpty) ...[
              pw.SizedBox(height: 15),
              pw.Text(
                data.personalInfo.summary,
                style: const pw.TextStyle(color: PdfColors.white),
              ),
            ],
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildMainSectionTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _buildWrapSkills,
              ),
            )
            .toList(),
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

Future<pw.Document> buildT42RightHeaderRed(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 2,
    flexR: 1,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        [
          if (data.personalInfo.summary.isNotEmpty) ...[
            pw.Text(data.personalInfo.summary),
            pw.SizedBox(height: 20),
          ],
          ...data.leftColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildMainSectionTitle,
              _buildTimelineItem,
              _buildEdu,
              _buildProject,
              _build2ColSkills,
            ),
          ),
        ],
        36,
        20,
      ),
      pw.SizedBox(height: 36),
    ],
    rightContent: [
      pw.Container(
        color: color,
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildAvatar(data, 60, fontSize: 20),
            pw.SizedBox(height: 15),
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 1.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              data.personalInfo.location,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
            pw.Text(
              data.personalInfo.email,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
            pw.Text(
              data.personalInfo.phone,
              style: const pw.TextStyle(color: PdfColors.white),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildMainSectionTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _buildWrapSkills,
              ),
            )
            .toList(),
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

Future<pw.Document> buildT43RightHeaderCyan(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 2,
    flexR: 1,
    header: pw.SizedBox(),
    leftContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        data.leftColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildMainSectionTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _build2ColSkills,
              ),
            )
            .toList(),
        36,
        20,
      ),
      pw.SizedBox(height: 36),
    ],
    rightContent: [
      pw.Container(
        color: color,
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildAvatar(data, 50, fontSize: 18),
            pw.SizedBox(height: 10),
            pw.Text(
              data.personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: data.fontSize * 1.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
              style: const pw.TextStyle(color: PdfColors.white),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      ..._pad(
        [
          data.personalInfo.summary.isNotEmpty
              ? pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: color, width: 3),
                    ),
                  ),
                  padding: const pw.EdgeInsets.only(left: 10),
                  child: pw.Text(data.personalInfo.summary),
                )
              : pw.SizedBox(),
          pw.SizedBox(height: 20),
          ...data.rightColumn.expand(
            (sec) => _renderSection(
              sec,
              data,
              color,
              PdfColors.black,
              _buildMainSectionTitle,
              _buildExp,
              _buildEdu,
              _buildProject,
              _buildWrapSkills,
            ),
          ),
        ],
        20,
        20,
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

Future<pw.Document> buildT44PurpleThickLines(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pw.Widget thickT(String t, PdfColor a, PdfColor text, double s) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Divider(color: a, thickness: 3),
      pw.SizedBox(height: 5),
      pw.Text(
        t,
        style: pw.TextStyle(
          fontSize: s * 1.5,
          color: a,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 5),
    ],
  );
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        _buildPartitions(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.9,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '${data.personalInfo.location}\n${data.personalInfo.email}\n${data.personalInfo.phone}',
              ),
            ],
          ),
          data.personalInfo.summary.isNotEmpty
              ? pw.Column(children: [pw.Text(data.personalInfo.summary)])
              : pw.SizedBox(),
          1,
          1,
        ),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            thickT,
            _buildExp,
            _buildEdu,
            _buildProject,
            _buildWrapSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT45GreenBanner(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 1,
    flexR: 2,
    header: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  _buildAvatar(data, 60, fontSize: 20),
                  pw.SizedBox(width: 15),
                  pw.Text(
                    data.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: data.fontSize * 2.9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    data.personalInfo.location,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                  pw.Text(
                    data.personalInfo.email,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        data.personalInfo.summary.isNotEmpty
            ? pw.Container(
                width: double.infinity,
                color: color,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 10,
                ),
                child: pw.Text(
                  data.personalInfo.summary,
                  style: const pw.TextStyle(color: PdfColors.white),
                ),
              )
            : pw.SizedBox(),
      ],
    ),
    leftContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        data.leftColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildMainSectionTitle,
                _buildExp,
                _buildEdu,
                _buildProject,
                _buildWrapSkills,
              ),
            )
            .toList(),
        36,
        20,
      ),
      pw.SizedBox(height: 36),
    ],
    rightContent: [
      pw.SizedBox(height: 36),
      ..._pad(
        data.rightColumn
            .expand(
              (sec) => _renderSection(
                sec,
                data,
                color,
                PdfColors.black,
                _buildMainSectionTitle,
                _buildTimelineItem,
                _buildEdu,
                _buildProject,
                _buildWrapSkills,
              ),
            )
            .toList(),
        20,
        36,
      ),
      pw.SizedBox(height: 36),
    ],
  );
}

Future<pw.Document> buildT46PinkCentered(
  ResumeData data,
  PdfColor color,
) async {
  final theme = await getAppPdfTheme(data);
  final pdf = pw.Document(theme: theme);
  pw.Widget pTitle(String t, PdfColor a, PdfColor text, double s) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Divider(color: a, thickness: 2),
      pw.SizedBox(height: 5),
      pw.Text(
        t,
        style: pw.TextStyle(
          fontSize: s * 1.5,
          color: a,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 5),
    ],
  );
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        _buildPartitions(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              _buildAvatar(data, 50, fontSize: 18),
              pw.SizedBox(height: 10),
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.9,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.Text(
                '${data.personalInfo.location} | ${data.personalInfo.email}',
              ),
            ],
          ),
          data.personalInfo.summary.isNotEmpty
              ? pw.Column(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: color),
                      ),
                      child: pw.Text(data.personalInfo.summary),
                    ),
                  ],
                )
              : pw.SizedBox(),
          1,
          1,
        ),
        pw.SizedBox(height: 20),
        ...data.singleColumn.expand(
          (sec) => _renderSection(
            sec,
            data,
            color,
            PdfColors.black,
            pTitle,
            _buildExp,
            _buildEdu,
            _buildProject,
            _buildWrapSkills,
          ),
        ),
      ],
    ),
  );
  return pdf;
}

Future<pw.Document> buildT47NavyHalfSplit(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
      data: data, theme: theme, leftBg: color, rightBg: PdfColors.white, flexL: 1, flexR: 2,
      // FIX: Added pw.Container with color: PdfColors.white to block the column background
      header: pw.Container(
        color: PdfColors.white,
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Padding(padding: const pw.EdgeInsets.all(36), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [ pw.Text(data.personalInfo.fullName.toUpperCase(), style: pw.TextStyle(fontSize: data.fontSize * 3.6, fontWeight: pw.FontWeight.bold, color: color)), pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [pw.Text(data.personalInfo.location), pw.Text(data.personalInfo.email)]) ])),
          data.personalInfo.summary.isNotEmpty ? pw.Container(width: double.infinity, color: PdfColors.grey200, padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 15), child: pw.Text(data.personalInfo.summary)) : pw.SizedBox(),
        ]),
      ),
      leftContent: [
        pw.SizedBox(height: 36),
        ..._pad(data.leftColumn.expand((sec) => _renderSection(sec, data, PdfColors.white, PdfColors.white, _buildMainTitle, _buildExp, _buildEdu, _buildProject, _buildWrapSkills)).toList(), 36, 36),
        pw.SizedBox(height: 36),
      ],
      rightContent: [
        pw.SizedBox(height: 36),
        ..._pad(data.rightColumn.expand((sec) => _renderSection(sec, data, color, PdfColors.black, _buildMainTitle, _buildExp, _buildEdu, _buildProject, _build2ColSkills)).toList(), 36, 36),
        pw.SizedBox(height: 36),
      ]
  );
}

Future<pw.Document> buildT48BlackGrid(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  pw.Widget cell(String title, pw.Widget content) => pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: data.fontSize * 1.3,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 15),
        content,
      ],
    ),
  );
  pw.Widget getGridItem(String name) {
    if (name == 'Experience')
      return cell(
        'EXPERIENCE',
        pw.Column(
          children: data.experiences
              .map((e) => _buildTimelineItem(e, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Education')
      return cell(
        'EDUCATION',
        pw.Column(
          children: data.educations
              .map((e) => _buildEdu(e, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Projects')
      return cell(
        'PROJECTS',
        pw.Column(
          children: data.projects
              .map((p) => _buildProject(p, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Skills' || name == 'Languages')
      return cell(
        name.toUpperCase(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: data.skills.map((s) => pw.Text(s.name)).toList(),
        ),
      );
    try {
      final c = data.customSections.firstWhere((s) => s.sectionTitle == name);
      return cell(
        c.sectionTitle.toUpperCase(),
        pw.Column(
          children: c.items
              .map((i) => _buildCustomItem(i, color, PdfColors.black, data))
              .toList(),
        ),
      );
    } catch (_) {
      return pw.SizedBox();
    }
  }

  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 2,
    flexR: 1,
    drawMiddleBorder: true,
    header: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: color,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Row(
            children: [
              _buildAvatar(data, 60, bgColor: PdfColors.white, fontSize: 20),
              pw.SizedBox(width: 20),
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    data.personalInfo.location,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                  pw.Text(
                    data.personalInfo.email,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        data.personalInfo.summary.isNotEmpty
            ? pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                child: pw.Text(data.personalInfo.summary),
              )
            : pw.SizedBox(),
        pw.Container(height: 1, color: PdfColors.black),
      ],
    ),
    leftContent: data.rightColumn.map((sec) => getGridItem(sec)).toList(),
    rightContent: data.leftColumn.map((sec) => getGridItem(sec)).toList(),
  );
}

Future<pw.Document> buildT49BlueHalfSplit(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  return _buildSplitTemplate(
      data: data, theme: theme, leftBg: PdfColors.white, rightBg: color, flexL: 2, flexR: 1,
      // FIX: Added pw.Container with color: PdfColors.white to block the column background
      header: pw.Container(
        color: PdfColors.white,
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Padding(padding: const pw.EdgeInsets.all(36), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [ pw.Text(data.personalInfo.fullName.toUpperCase(), style: pw.TextStyle(fontSize: data.fontSize * 3.6, fontWeight: pw.FontWeight.bold, color: color)), pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [pw.Text(data.personalInfo.location), pw.Text(data.personalInfo.email)]) ])),
          data.personalInfo.summary.isNotEmpty ? pw.Container(width: double.infinity, color: PdfColors.grey200, padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 15), child: pw.Text(data.personalInfo.summary)) : pw.SizedBox(),
        ]),
      ),
      leftContent: [
        pw.SizedBox(height: 36),
        ..._pad(data.leftColumn.expand((sec) => _renderSection(sec, data, color, PdfColors.black, _buildMainTitle, _buildExp, _buildEdu, _buildProject, _build2ColSkills)).toList(), 36, 36),
        pw.SizedBox(height: 36),
      ],
      rightContent: [
        pw.SizedBox(height: 36),
        ..._pad(data.rightColumn.expand((sec) => _renderSection(sec, data, PdfColors.white, PdfColors.white, _buildMainTitle, _buildExp, _buildEdu, _buildProject, _buildWrapSkills)).toList(), 36, 36),
        pw.SizedBox(height: 36),
      ]
  );
}

Future<pw.Document> buildT50GreyGrid(ResumeData data, PdfColor color) async {
  final theme = await getAppPdfTheme(data);
  pw.Widget cell(String title, pw.Widget content) => pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: data.fontSize * 1.3,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 15),
        content,
      ],
    ),
  );
  pw.Widget getGridItem(String name) {
    if (name == 'Experience')
      return cell(
        'EXPERIENCE',
        pw.Column(
          children: data.experiences
              .map((e) => _buildExp(e, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Education')
      return cell(
        'EDUCATION',
        pw.Column(
          children: data.educations
              .map((e) => _buildEdu(e, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Projects')
      return cell(
        'PROJECTS',
        pw.Column(
          children: data.projects
              .map((p) => _buildProject(p, color, PdfColors.black, data))
              .toList(),
        ),
      );
    if (name == 'Skills' || name == 'Languages')
      return cell(
        name.toUpperCase(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: data.skills.map((s) => pw.Text(s.name)).toList(),
        ),
      );
    try {
      final c = data.customSections.firstWhere((s) => s.sectionTitle == name);
      return cell(
        c.sectionTitle.toUpperCase(),
        pw.Column(
          children: c.items
              .map((i) => _buildCustomItem(i, color, PdfColors.black, data))
              .toList(),
        ),
      );
    } catch (_) {
      return pw.SizedBox();
    }
  }

  return _buildSplitTemplate(
    data: data,
    theme: theme,
    leftBg: PdfColors.white,
    rightBg: PdfColors.white,
    flexL: 2,
    flexR: 1,
    drawMiddleBorder: true,
    header: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.grey200,
          padding: const pw.EdgeInsets.all(36),
          child: pw.Row(
            children: [
              _buildAvatar(data, 60, bgColor: PdfColors.grey400, fontSize: 20),
              pw.SizedBox(width: 20),
              pw.Text(
                data.personalInfo.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: data.fontSize * 2.9,
                  fontWeight: pw.FontWeight.normal,
                  color: PdfColors.grey800,
                ),
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(data.personalInfo.location),
                  pw.Text(data.personalInfo.email),
                ],
              ),
            ],
          ),
        ),
        data.personalInfo.summary.isNotEmpty
            ? pw.Container(
                width: double.infinity,
                color: PdfColors.grey100,
                padding: const pw.EdgeInsets.all(20),
                child: pw.Text(data.personalInfo.summary),
              )
            : pw.SizedBox(),
        pw.Container(height: 1, color: PdfColors.black),
      ],
    ),
    leftContent: data.rightColumn.map((sec) => getGridItem(sec)).toList(),
    rightContent: data.leftColumn.map((sec) => getGridItem(sec)).toList(),
  );
}
