import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/inventory_model.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class InventoryDataPDFScreen extends StatelessWidget {
  final InventoryResponseModel inventory;

  const InventoryDataPDFScreen({
    super.key,
    required this.inventory,
  });

  static Future<Uint8List> generatePdf(InventoryResponseModel inventory) async {
    final pdf = pw.Document();

    pw.Font? font;
    try {
      font = await PdfGoogleFonts.notoSansRegular();
    } catch (_) {
      font = pw.Font.helvetica();
    }

    pw.Font? boldFont;
    try {
      boldFont = await PdfGoogleFonts.notoSansBold();
    } catch (_) {
      boldFont = pw.Font.helveticaBold();
    }

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
                      'SCM GLOBAL ENTERPRISE',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#0D6EFD'),
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Warehouse Stock Inventory & Ledger Audit Certificate',
                      style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                    ),
                    pw.Text(
                      'ISO 9001:2015 Storage & Inventory Management Standard',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#0D6EFD'),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'STK-${inventory.id}',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 12),

            // Metadata Grid
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Target Cargo Material:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(inventory.productName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Product Code: ${inventory.productCode}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Assigned Storage Node:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(inventory.warehouseName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Last Audit: ${inventory.lastUpdated}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Section 1: Stock Quantities & Quotas
            pw.Text('I. Stock Metric Parameters', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#212529'))),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8F9FA')),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('METRIC PARAMETER', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('VOLUME QUANTITY', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('AUDIT STATUS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.TableRow(children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Quantity On Hand', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${inventory.quantityOnHand} Units', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Physical Vault Count', style: const pw.TextStyle(fontSize: 9))),
                ]),
                pw.TableRow(children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Reserved Quota', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${inventory.quantityReserved} Units', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#DC3545')))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Committed Orders / Safety', style: const pw.TextStyle(fontSize: 9))),
                ]),
                pw.TableRow(children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Available Sellable Quantity', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${inventory.availableQuantity} Units', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#198754')))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Net Dispatchable Stock', style: const pw.TextStyle(fontSize: 9))),
                ]),
              ],
            ),
            pw.SizedBox(height: 16),

            // Section 2: Storage Placement & Expiration
            pw.Text('II. Storage Placement & Batch Expiration', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#212529'))),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Warehouse Placement Location:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                      pw.Text(inventory.locationStatus.isNotEmpty ? inventory.locationStatus : 'Unassigned Row/Rack', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Batch Expiration Date:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                      pw.Text(inventory.expiryDate.isNotEmpty ? inventory.expiryDate : 'Non-perishable / Hardware', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#FFC107'))),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tracking Stock Matrix Verdict:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                      pw.Text(inventory.stockStatus, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D6EFD'))),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Signature & Footer
            pw.Spacer(),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500))),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Warehouse Officer', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#198754'), width: 1.5),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'SCM VAULT\nVERIFIED',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(color: PdfColor.fromHex('#198754'), fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 120,
                      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500))),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Inventory Auditor', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ],
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
          'Inventory Ledger PDF (STK-${inventory.id})',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [DynamicNotificationButton()],
      ),
      body: PdfPreview(
        build: (format) => generatePdf(inventory),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
