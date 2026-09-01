import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class ShipmentPDFScreen extends StatelessWidget {
  final ShipmentResponseModel shipment;

  const ShipmentPDFScreen({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    final shpNo = shipment.shipmentNumber.isNotEmpty ? shipment.shipmentNumber : 'SHP-${shipment.id}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Shipment #$shpNo Waybill PDF'),
        backgroundColor: AppTheme.dark,
        foregroundColor: AppTheme.surfaceWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdfData = await _generatePdf(PdfPageFormat.a4, shipment);
              await Printing.layoutPdf(onLayout: (_) => pdfData);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, shipment),
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, ShipmentResponseModel s) async {
    final pdf = pw.Document();

    final primaryNavy = PdfColor.fromHex('#1E3A8A');
    final darkNavy = PdfColor.fromHex('#0F172A');
    final accentBlue = PdfColor.fromHex('#2563EB');
    final bgLight = PdfColor.fromHex('#F8FAFC');
    final borderGrey = PdfColor.fromHex('#E2E8F0');
    final textMuted = PdfColor.fromHex('#64748B');
    final textDark = PdfColor.fromHex('#1E293B');

    final shpNo = s.shipmentNumber.isNotEmpty ? s.shipmentNumber : 'SHP-${s.id}';
    final estDate = s.estimatedDelivery.contains('T')
        ? s.estimatedDelivery.split('T').first
        : (s.estimatedDelivery.isNotEmpty ? s.estimatedDelivery : 'N/A');
    final createdDate = s.createdAt.contains('T')
        ? s.createdAt.split('T').first
        : (s.createdAt.isNotEmpty ? s.createdAt : 'N/A');

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── 1. Top Header Banner ──────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SCM FREIGHT & LOGISTICS HUB',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryNavy,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Global Cargo Consignment & Transit Operations',
                        style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Dock 12, Gateway SCM Cargo Terminal\nEmail: logistics@scm-enterprise.com | Phone: +1 (800) 555-CARGO',
                        style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: primaryNavy,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'CARGO WAYBILL / BOL',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        '# $shpNo',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Dispatch Date: $createdDate',
                        style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 14),
              pw.Divider(color: primaryNavy, thickness: 2),
              pw.SizedBox(height: 14),

              // ── 2. Party Cards (Origin / Consignor & Destination / Consignee) ────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // CONSIGNOR / ORIGIN
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: bgLight,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderGrey),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ORIGIN & CONSIGNOR BENEFICIARY',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            s.supplierName.isNotEmpty ? s.supplierName : 'Supplier #${s.supplierId}',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Contact: ${s.supplierContactPerson.isNotEmpty ? s.supplierContactPerson : "N/A"}\n'
                            'Email: ${s.supplierEmail.isNotEmpty ? s.supplierEmail : "N/A"}\n'
                            'Phone: ${s.supplierPhone.isNotEmpty ? s.supplierPhone : "N/A"}',
                            style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Origin Vector: ${s.origin.isNotEmpty ? s.origin : "Warehouse Dock #1"}',
                            style: pw.TextStyle(fontSize: 8, color: textDark, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 14),

                  // CONSIGNEE / DESTINATION
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: bgLight,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderGrey),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DESTINATION & CONSIGNEE DETAILS',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Linked PO Node: #PO-${s.poId}',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Destination: ${s.sendByAddress.isNotEmpty ? s.sendByAddress : "SCM Central Depot"}',
                            style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Assigned By: ${s.assignedByEmail.isNotEmpty ? s.assignedByEmail : "Logistics Manager"}\n'
                            'Est. Target Arrival: $estDate',
                            style: pw.TextStyle(fontSize: 8, color: textDark, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              // ── 3. Consignment Matrix Table ──────────────────────
              pw.Text(
                'CARGO FREIGHT SPECIFICATION MATRIX',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryNavy),
              ),
              pw.SizedBox(height: 6),

              pw.TableHelper.fromTextArray(
                headers: ['ITEM #', 'CONSIGNMENT / VEHICLE REGS', 'LINKED PO', 'QTY (UNITS)', 'FREIGHT COST (${s.poTotalAmount > 0 ? "USD" : "USD"})'],
                data: [
                  [
                    '01',
                    'Vehicle No: ${s.vehicleNumber.isNotEmpty ? s.vehicleNumber : "N/A"}\nCaptain Reg: ${s.captainRegistrationNumber.isNotEmpty ? s.captainRegistrationNumber : "N/A"}',
                    '#PO-${s.poId}',
                    '${s.shipmentQuantity} Pcs',
                    '\$${s.transportCost.toStringAsFixed(2)}',
                  ],
                ],
                border: pw.TableBorder.all(color: borderGrey, width: 1),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 8.5,
                ),
                headerDecoration: pw.BoxDecoration(color: primaryNavy),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FixedColumnWidth(75),
                  3: const pw.FixedColumnWidth(75),
                  4: const pw.FixedColumnWidth(95),
                },
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 14),

              // ── 4. Freight Directives & Financial Box ──────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Transit Directives
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: bgLight,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: borderGrey),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'CARGO TRANSIT DIRECTIVES & PROOF OF DELIVERY',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '1. Cargo Inspection: Consignment must be verified against PO #${s.poId} upon unloading.\n'
                            '2. Transit Proof: Captain must present signed Waybill and uploaded POD file.\n'
                            '3. POD URL Ref: ${s.podFileUrl.isNotEmpty ? s.podFileUrl : "Verified Digital Copy On-File"}',
                            style: pw.TextStyle(fontSize: 7.5, color: textDark),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 14),

                  // Total Box
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: darkNavy,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'FREIGHT TRANSPORT COST',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            '\$${s.transportCost.toStringAsFixed(2)} USD',
                            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: PdfColors.amber),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Insurance & Transit Included',
                            style: pw.TextStyle(fontSize: 7, color: PdfColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ── 5. Formal Signatures & Stamps ────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: darkNavy,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'DISPATCHED BY (LOGISTICS OFFICER)',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkNavy),
                      ),
                      pw.Text(
                        s.assignedByEmail.isNotEmpty ? s.assignedByEmail : 'Logistics Officer',
                        style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                      ),
                      pw.Text(
                        'Date: $createdDate',
                        style: pw.TextStyle(fontSize: 7, color: textMuted),
                      ),
                    ],
                  ),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: darkNavy,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'CARRIER & CAPTAIN RECEIPT STAMP',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkNavy),
                      ),
                      pw.Text(
                        'Captain Reg: ${s.captainRegistrationNumber.isNotEmpty ? s.captainRegistrationNumber : "Registered Driver"}',
                        style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                      ),
                      pw.Text(
                        'Waybill Security Code: SCM-CARGO-WAYBILL-OK',
                        style: pw.TextStyle(fontSize: 7, color: accentBlue, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 14),
              pw.Divider(color: borderGrey),
              pw.SizedBox(height: 6),

              // ── Footer Security Statement ────────────────────────
              pw.Center(
                child: pw.Text(
                  'This is a legally binding B2B Cargo Waybill document generated electronically by SCM Enterprise Logistics.',
                  style: pw.TextStyle(fontSize: 7.5, color: textMuted, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
