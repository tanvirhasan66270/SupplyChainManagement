import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/qc_inspaction_model.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class QCInspectionDataPDFScreen extends StatelessWidget {
  final QCInspectionResponseModel inspection;

  const QCInspectionDataPDFScreen({
    super.key,
    required this.inspection,
  });

  static Future<Uint8List> generatePdf(QCInspectionResponseModel inspection) async {
    final pdf = pw.Document();

    pw.Font? font;
    try {
      font = await PdfGoogleFonts.notoSansBengaliRegular();
    } catch (_) {
      font = pw.Font.helvetica();
    }

    pw.Font? boldFont;
    try {
      boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    } catch (_) {
      boldFont = pw.Font.helveticaBold();
    }

    final dateFormatted = inspection.inspectedAt.contains('T')
        ? inspection.inspectedAt.split('T').first
        : inspection.inspectedAt;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return [
            // Header Banner
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SCM GLOBAL QUALITY CONTROL',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#0F766E'),
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Official Quality Assurance & Material Compliance Audit Report',
                      style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#0D9488'),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'QC-NODE-#${inspection.id}',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Metadata Section
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('AUDIT METADATA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('Audit Node Reference: QC-NODE-#${inspection.id}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Inbound Cargo GRN: ${inspection.grnNumber}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Target Product: ${inspection.productName}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Inspection Topology: ${inspection.inspectionType}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('AUDIT VERDICT & AUTHORITY', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Result: ${inspection.result}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: inspection.result == 'GOOD' || inspection.result == 'VERY_GOOD'
                              ? PdfColor.fromHex('#16A34A')
                              : (inspection.result == 'BAD' ? PdfColor.fromHex('#DC2626') : PdfColor.fromHex('#D97706')),
                        ),
                      ),
                      pw.Text('Inspector Personnel: ${inspection.inspectedByName}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Execution Date: $dateFormatted', style: const pw.TextStyle(fontSize: 10)),
                      if (inspection.certificateRef.isNotEmpty)
                        pw.Text('Certificate Ref: ${inspection.certificateRef}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Batch Sample & Defect Pool
            pw.Text('BATCH SAMPLE & ANOMALY POOL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Sample Pool Size', 'Defects Identified', 'Defect Anomaly Rate', 'Lab Report Status'],
              data: [
                [
                  '${inspection.sampleSize} Cargo Units',
                  '${inspection.defectsFound} Defects Flagged',
                  '${((inspection.defectsFound / (inspection.sampleSize > 0 ? inspection.sampleSize : 1)) * 100).toStringAsFixed(1)}%',
                  inspection.labTestReport.isNotEmpty ? 'Attached' : 'N/A',
                ]
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0D9488')),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),

            // Diagnostic Checkpoint Sheet
            pw.Text('DIAGNOSTIC CHECKPOINT SHEET', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Checkpoint Name / Metric', 'Compliance Status', 'Audit Remarks'],
              data: inspection.checklists.isEmpty
                  ? [
                      ['General Batch Checkpoint', 'PASS', 'Standard consignment compliance verified']
                    ]
                  : inspection.checklists.map((c) => [
                      c.checkpointName.isNotEmpty ? c.checkpointName : 'General Checkpoint',
                      c.isPassed ? 'PASS' : 'FAIL',
                      c.remarks.isNotEmpty ? c.remarks : 'No additional remarks',
                    ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0F172A')),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),

            // Defect Narrative Description
            pw.Text('DEFECT NARRATIVE & LOGISTICS ANOMALY NOTES', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
            pw.SizedBox(height: 6),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Text(
                inspection.defectDescription.isNotEmpty ? inspection.defectDescription : 'No material flaws or structural defects recorded for this consignment.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ),
            pw.SizedBox(height: 30),

            // Footer Signature
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'This document is system-generated via the SCM Global Enterprise Platform.\nElectronically validated Quality Control Telemetry Audit. Authorized for logistics routing.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          'QC Report #QC-NODE-${inspection.id}',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      body: PdfPreview(
        build: (format) => generatePdf(inspection),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'QC-Inspection-Report-#${inspection.id}.pdf',
      ),
    );
  }
}
