import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class QuotationDataPDFScreen extends StatelessWidget {
  final QuotationResponseModel quotation;

  const QuotationDataPDFScreen({
    super.key,
    required this.quotation,
  });

  static Future<Uint8List> generatePdf(QuotationResponseModel q) async {
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

    final qtnNo = q.quotationNumber.isNotEmpty ? q.quotationNumber : 'QTN-${q.id}';
    final supplierNameStr = q.supplierName.isNotEmpty ? q.supplierName : 'Supplier #${q.supplierId}';
    final productNameStr = q.productName.isNotEmpty ? q.productName : 'Product #${q.productIds}';

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
                      'Official Supplier Quotation Bid Document Envelope',
                      style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#2563EB'),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    qtnNo,
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold),
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
                      pw.Text('SUPPLIER IDENTITY & BID METADATA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('Quotation Envelope No: $qtnNo', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
                      pw.Text('Supplier Name: $supplierNameStr', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Supplier ID: #${q.supplierId}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Submission Date: ${q.createdAt}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('LINKED REQUISITION & WORKFLOW STATUS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('Linked PR Node: #PR-${q.purchaseRequisitionId}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Bid Status: ${q.status}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#16A34A'))),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Product Specifications & Pricing Table
            pw.Text('PRODUCT SPECIFICATION & BID PRICE VECTOR', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Item Specification / Product', 'Consignment Volume', 'Unit Price (\$) ', 'Aggregate Valuation (\$)'],
              data: [
                [
                  productNameStr,
                  '${q.quantity} Pcs',
                  '\$${q.unitPrice.toStringAsFixed(2)}',
                  '\$${q.totalPrice.toStringAsFixed(2)}',
                ],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2563EB')),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 16),

            // Total Summary Card
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 240,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Unit Rate:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          pw.Text('\$${q.unitPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Quantity Vector:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          pw.Text('${q.quantity} Units', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Divider(color: PdfColors.grey300),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL QUOTATION VALUATION:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
                          pw.Text('\$${q.totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#16A34A'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Electronic Signature Footer
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'This document is an electronically generated quotation bid envelope via the SCM Enterprise Supply Chain Platform.\nValidated electronically. No manual physical signature required.',
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
    final qtnNo = quotation.quotationNumber.isNotEmpty ? quotation.quotationNumber : 'QTN-${quotation.id}';

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          'Quotation Document #$qtnNo',
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
        build: (format) => generatePdf(quotation),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'Supplier-Quotation-$qtnNo.pdf',
      ),
    );
  }
}
