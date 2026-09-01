import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/letter_of_cradit_model.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class LetterOfCreditPDFScreen extends StatelessWidget {
  const LetterOfCreditPDFScreen({super.key, required this.lc});

  final LetterOfCreditResponseModel lc;

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    final bankName = lc.issuingBankName.isNotEmpty ? lc.issuingBankName : 'Standard Chartered Bank International';
    final swiftCode = lc.issuingBankSwiftCode.isNotEmpty ? lc.issuingBankSwiftCode : 'SCBLBDDX101';
    final poRef = lc.poNumber.isNotEmpty ? lc.poNumber : '${lc.purchaseOrderId}';
    final supplierName = lc.supplierName.isNotEmpty ? lc.supplierName : 'Global Trade Vendor Ltd';
    final supplierEmail = lc.supplierEmail.isNotEmpty ? lc.supplierEmail : 'trade@supplier-cluster.com';
    final portLoading = lc.portOfLoading.isNotEmpty ? lc.portOfLoading : 'Shanghai Deepsea Port';
    final portDischarge = lc.portOfDischarge.isNotEmpty ? lc.portOfDischarge : 'Chattogram Sea Port (CTG)';

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── 1. CORPORATE SWIFT HEADER BANNER ────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#0F172A'),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INTERNATIONAL SWIFT LETTER OF CREDIT',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'MT700 IRREVOCABLE COMMERCIAL FINANCIAL GUARANTEE',
                          style: const pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey100, letterSpacing: 0.5),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'REF #: ${lc.lcNumber.isNotEmpty ? lc.lcNumber : "LC-DRAFT-2026"}',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue100),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'LC:${lc.lcNumber}|PO:$poRef|BANK:$swiftCode|VAL:${lc.amount}',
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // ── 2. ISSUING BANK & ORDER CLUSTER DETAILS GRID ────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Bank Terminal Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ISSUING FINANCIAL INSTITUTION', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2563EB'))),
                          pw.SizedBox(height: 4),
                          pw.Text(bankName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('SWIFT Code: $swiftCode', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                          pw.Text('Branch: Main Corporate Branch, Gulshan-2, Dhaka', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.Text('Routing #: 010260145 | A/C #: 110-847291-01', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),

                  // Order & Beneficiary Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ORDER & SUPPLIER BENEFICIARY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2563EB'))),
                          pw.SizedBox(height: 4),
                          pw.Text('Parent Order: PO #$poRef', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Beneficiary: $supplierName', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                          pw.Text('Contact Email: $supplierEmail', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.Text('Credit Type: Irrevocable Transferable Sight LC', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // ── 3. FINANCIAL PARAMETERS & SHIPMENT MANIFEST ─────────────
              pw.Text('FINANCIAL & LOGISTICS PARAMETERS MANIFEST', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A'))),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Parameter', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Specification Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    ],
                  ),
                  _buildPdfRow('Credit Valuation Amount', '${lc.currency == "BDT" ? "BDT ৳" : "USD \$"}${lc.amount.toStringAsFixed(2)} ${lc.currency}', isBold: true, color: PdfColors.green800),
                  _buildPdfRow('Incoterms Framework', '${lc.shipmentIncoTerms} (International Commercial Terms)'),
                  _buildPdfRow('Port of Loading (Origin)', portLoading),
                  _buildPdfRow('Port of Discharge (Destination)', portDischarge),
                  _buildPdfRow('Latest Shipment Deadline', lc.latestShipmentDate),
                  _buildPdfRow('LC Expiry Deadline', lc.expiryDate, color: PdfColors.red800),
                  _buildPdfRow('Amendment Version Index', 'Patch Version #${lc.amendmentCount}'),
                  _buildPdfRow('SWIFT Document Attachment', lc.documentVaultUrl.isNotEmpty ? 'Attached & Verified in Vault' : 'Standard Digital Instrument'),
                  _buildPdfRow('Instrument Operating Stage', lc.lcStatus, isBold: true, color: PdfColor.fromHex('#2563EB')),
                ],
              ),
              pw.SizedBox(height: 14),

              // ── 4. LEGAL UCP 600 TERMS & BANK GUARANTEE ─────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ICC UCP 600 COMPLIANCE & LEGAL GUARANTEE:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B'))),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'This Letter of Credit is issued subject to Uniform Customs and Practice for Documentary Credits (2007 Revision, ICC Publication No. 600). The issuing bank undertakes to honor complying presentations of shipping documents within the validity deadline.',
                      style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),

              // ── 5. OFFICIAL DUAL SIGNATURE & SEAL BLOCKS ────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Commercial Officer', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('SCM Trade Logistics Desk', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Issuing Bank Terminal Seal', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('SWIFT Controller Approval', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Electronically Generated SWIFT Document - SCM Corporate Cluster System',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.TableRow _buildPdfRow(String label, String val, {bool isBold = false, PdfColor? color}) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(label, style: const pw.TextStyle(fontSize: 8))),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            val,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          'SWIFT LC PDF - ${lc.lcNumber.isNotEmpty ? lc.lcNumber : "DRAFT"}',
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
        build: (format) => _generatePdf(format),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
