import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class PurchaseRequisitionDataPDFScreen extends StatelessWidget {
  final PurchaseRequisitionResponse requisition;

  const PurchaseRequisitionDataPDFScreen({
    super.key,
    required this.requisition,
  });

  static Future<Uint8List> generatePdf(PurchaseRequisitionResponse requisition) async {
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

    final dateFormatted = requisition.requiredByDate.contains('T')
        ? requisition.requiredByDate.split('T').first
        : requisition.requiredByDate;

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
            // Top Header Banner
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SCMPRO PROCUREMENT',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#0B2545'),
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Official Purchase Requisition Contract Document',
                      style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#2563EB'),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        '#PRQ-${requisition.id}',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'PRQ:${requisition.id}|URGENCY:${requisition.urgencyLevel}',
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Requisition Details Table
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('REQUISITION METADATA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('Reference ID: #PRQ-${requisition.id}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Target Required Date: $dateFormatted', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Urgency Strategy: ${requisition.urgencyLevel}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('WORKFLOW STATUS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('Status: ${requisition.approvalStatus}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#16A34A'))),
                      if (requisition.approvedByName != null)
                        pw.Text('Authorized By: ${requisition.approvedByName}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Target Preferred Suppliers
            pw.Text('TARGET PREFERRED SUPPLIERS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
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
                requisition.supplierNames.isEmpty ? 'No target suppliers specified' : requisition.supplierNames.join('  |  '),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B')),
              ),
            ),
            pw.SizedBox(height: 20),

            // Product Specifications Table
            pw.Text('PRODUCT SPECIFICATION VECTOR', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Product Specification / Item', 'Required Consignment Volume', 'Currency Settlement'],
              data: requisition.productNames.isEmpty
                  ? [
                      ['Default Requisition Item Spec', '${requisition.quantityRequired} Units', requisition.currency]
                    ]
                  : requisition.productNames.map((pName) => [
                      pName,
                      '${requisition.quantityRequired} Units',
                      requisition.currency,
                    ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2563EB')),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),

            // Remarks & Directives
            pw.Text('SPECIAL REQUISITION DIRECTIVES & REMARKS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
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
                requisition.remarks?.isNotEmpty == true ? requisition.remarks! : 'No specific logistics directives recorded.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ),
            pw.SizedBox(height: 30),

            // Footer Signature
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'This document is system-generated via the SCM Enterprise Supply Chain Management Platform.\nElectronically validated. No physical signature required.',
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
          'Requisition Document #PRQ-${requisition.id}',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      body: PdfPreview(
        build: (format) => generatePdf(requisition),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'Purchase-Requisition-PRQ-${requisition.id}.pdf',
      ),
    );
  }
}
