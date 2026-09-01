import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/grn_model.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class GoodReceivedNotePDFScreen extends ConsumerWidget {
  final GoodsReceivedNoteResponseModel grn;

  const GoodReceivedNotePDFScreen({
    super.key,
    required this.grn,
  });

  static Future<Uint8List> generatePdf(
    GoodsReceivedNoteResponseModel grn,
    PurchaseOrderResponse? po,
  ) async {
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

    // Excel Color Palette Definition
    final excelGreen = PdfColor.fromHex('#107C41'); // Official MS Excel Green
    final excelDarkGreen = PdfColor.fromHex('#0E6B37');
    final excelLightGreen = PdfColor.fromHex('#E6F4EA');
    final gridBorder = PdfColor.fromHex('#D1D5DB'); // Excel Cell Grid Line
    final cellBgAlt = PdfColor.fromHex('#F9FAFB');
    final textDark = PdfColor.fromHex('#1F2937');
    final textMuted = PdfColor.fromHex('#6B7280');

    PdfColor statusColor;
    switch (grn.status.toUpperCase()) {
      case 'APPROVED':
        statusColor = PdfColor.fromHex('#107C41'); // Excel Green
        break;
      case 'RECEIVED':
      case 'INSPECTED':
        statusColor = PdfColor.fromHex('#1D4ED8'); // Blue
        break;
      case 'PENDING':
      case 'PARTIALLY_RECEIVED':
        statusColor = PdfColor.fromHex('#D97706'); // Amber
        break;
      case 'REJECTED':
        statusColor = PdfColor.fromHex('#DC2626'); // Red
        break;
      default:
        statusColor = PdfColor.fromHex('#6B7280');
    }

    final grnNumberStr = grn.grnNumber.isNotEmpty ? grn.grnNumber : 'GRN-${grn.id}';
    final poNumberStr = po?.poNumber.isNotEmpty == true ? po!.poNumber : (grn.poNumber.isNotEmpty ? grn.poNumber : 'PO-#${grn.poId}');
    final poAmountStr = po != null ? '${po.currency} ${po.totalAmount.toStringAsFixed(2)}' : 'N/A';
    final supplierNameStr = po?.supplierName.isNotEmpty == true ? po!.supplierName : 'External Registered Supplier';
    final supplierEmailStr = po?.supplierEmail.isNotEmpty == true ? po!.supplierEmail : 'N/A';
    final expectedDeliveryStr = po?.expectedDeliveryDate.isNotEmpty == true ? po!.expectedDeliveryDate : 'N/A';
    final poIssuedByStr = po?.issuedByName.isNotEmpty == true ? po!.issuedByName : 'Procurement Officer';
    final poOrderedQty = po?.quantity ?? grn.quantity;

    final fulfillmentRatio = poOrderedQty > 0 ? ((grn.receivedQuantity / poOrderedQty) * 100).toStringAsFixed(1) : '100.0';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return [
            // 1. MS Excel Style Sheet Title Header Bar
            pw.Container(
              decoration: pw.BoxDecoration(
                color: excelGreen,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Row(
                          children: [
                            // Excel Icon Box Badge
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                              child: pw.Text(
                                'XLSX',
                                style: pw.TextStyle(
                                  color: excelGreen,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 10),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'SCM ENTERPRISE WORKBOOK LEDGER AUDIT',
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'INBOUND CARGO & GOODS RECEIVED NOTE (GRN) SPREADSHEET MANIFEST',
                                  style: pw.TextStyle(
                                    color: PdfColor.fromHex('#D1FAE5'),
                                    fontSize: 7.5,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: statusColor,
                            borderRadius: pw.BorderRadius.circular(3),
                            border: pw.Border.all(color: PdfColors.white, width: 0.8),
                          ),
                          child: pw.Text(
                            grn.status.toUpperCase(),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sheet Tab Bar Indicator
                  pw.Container(
                    width: double.infinity,
                    color: excelDarkGreen,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(3),
                              topRight: pw.Radius.circular(3),
                            ),
                          ),
                          child: pw.Text(
                            'Sheet1: GRN & Procurement Master',
                            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: excelGreen),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text('Formula: =SUM(ReceivedQuantity) / SUM(OrderedQuantity)', style: pw.TextStyle(fontSize: 7, color: PdfColor.fromHex('#A7F3D0'))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // 2. Excel Formula Metric Cards Box (Spreadsheet Summary KPI Grid)
            pw.Table(
              border: pw.TableBorder.all(color: gridBorder, width: 0.8),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: excelLightGreen),
                  children: [
                    _buildFormulaCell('TOTAL PO ORDERED QTY', '=SUM(PO.Quantity)', '$poOrderedQty Units', textDark),
                    _buildFormulaCell('ACTUALLY RECEIVED QTY', '=SUM(GRN.ReceivedQuantity)', '${grn.receivedQuantity} Units', excelGreen, isBold: true),
                    _buildFormulaCell('CONTRACT TOTAL VALUE', '=SUM(PO.TotalAmount)', poAmountStr, PdfColor.fromHex('#1E40AF'), isBold: true),
                    _buildFormulaCell('FULFILLMENT RATIO', '=(Received/Ordered)*100%', '$fulfillmentRatio%', grn.receivedQuantity >= poOrderedQty && poOrderedQty > 0 ? excelGreen : PdfColor.fromHex('#D97706'), isBold: true),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // 3. Excel Specific Metadata Grid Tables (Section A, B, C Spreadsheet Cells)
            pw.Text('EXCEL MASTER DATA SHEET CELLS', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
            pw.SizedBox(height: 4),

            pw.Table(
              border: pw.TableBorder.all(color: gridBorder, width: 0.6),
              children: [
                // Excel Sheet Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E5E7EB')),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('SECTION A: CONSIGNMENT MASTER', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: excelDarkGreen)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('SECTION B: PURCHASE ORDER CONTRACT', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: excelDarkGreen)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('SECTION C: FACILITY & QC AUDIT', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: excelDarkGreen)),
                    ),
                  ],
                ),
                // Cell Rows 1
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.white),
                  children: [
                    _buildExcelCellPair('GRN Manifest Ref:', grnNumberStr, isBold: true),
                    _buildExcelCellPair('PO Reference No:', poNumberStr, isBold: true),
                    _buildExcelCellPair('Destination Terminal:', '${grn.warehouseName} (#${grn.warehouseId})'),
                  ],
                ),
                // Cell Rows 2
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: cellBgAlt),
                  children: [
                    _buildExcelCellPair('Target Material Product:', '${grn.productName} (#${grn.productId})'),
                    _buildExcelCellPair('PO Contract Value:', poAmountStr, isBold: true),
                    _buildExcelCellPair('PO Issued Officer:', poIssuedByStr),
                  ],
                ),
                // Cell Rows 3
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.white),
                  children: [
                    _buildExcelCellPair('Arrival Log Timestamp:', grn.receivedAt),
                    _buildExcelCellPair('Vendor / Supplier Name:', supplierNameStr),
                    _buildExcelCellPair('Expected Delivery Date:', expectedDeliveryStr),
                  ],
                ),
                // Cell Rows 4
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: cellBgAlt),
                  children: [
                    _buildExcelCellPair('Receiver Officer Personnel:', '${grn.receivedByName} (#${grn.receivedBy})'),
                    _buildExcelCellPair('Supplier Email Address:', supplierEmailStr),
                    _buildExcelCellPair('QC Inspector Node:', grn.inspectedByName ?? 'Pending Verification'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // 4. Excel Data Grid Table (Cargo Allocation Ledger Spreadsheet)
            pw.Text('INBOUND CARGO ALLOCATION EXCEL SPREADSHEET GRID', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
            pw.SizedBox(height: 4),

            if (grn.lineItems != null && grn.lineItems!.isNotEmpty)
              pw.Table(
                border: pw.TableBorder.all(color: gridBorder, width: 0.6),
                children: [
                  // Excel Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: excelGreen),
                    children: [
                      _buildHeaderCell('CELL'),
                      _buildHeaderCell('PRODUCT SPECIFICATION & MATERIAL'),
                      _buildHeaderCell('PO ORDERED'),
                      _buildHeaderCell('GRN RECEIVED'),
                      _buildHeaderCell('VARIANCE'),
                      _buildHeaderCell('AUDIT VERDICT'),
                    ],
                  ),
                  // Excel Data Rows
                  ...grn.lineItems!.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final line = entry.value;
                    final isEven = idx % 2 == 0;
                    final variance = line.quantityReceived - line.quantityOrdered;
                    final varianceStr = variance >= 0 ? '+$variance' : '$variance';

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: isEven ? cellBgAlt : PdfColors.white),
                      children: [
                        _buildDataCell('A$idx', isMuted: true),
                        _buildDataCell(line.productName.isNotEmpty ? line.productName : 'Item #${line.productId}', isBold: true),
                        _buildDataCell('${line.quantityOrdered} Units'),
                        _buildDataCell('${line.quantityReceived} Units', isBold: true, color: excelGreen),
                        _buildDataCell(varianceStr, color: variance >= 0 ? excelGreen : PdfColor.fromHex('#DC2626')),
                        _buildDataCell(
                          line.quantityReceived >= line.quantityOrdered ? 'PASS / MATCH' : 'SHORTFALL',
                          isBold: true,
                          color: line.quantityReceived >= line.quantityOrdered ? excelGreen : PdfColor.fromHex('#D97706'),
                        ),
                      ],
                    );
                  }),
                  // Formula Total Footer Row (Excel Standard Double Bottom Border)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: excelLightGreen),
                    children: [
                      _buildDataCell('=SUM', isBold: true, color: excelDarkGreen),
                      _buildDataCell('TOTAL SUMMARY CONSIGNMENT', isBold: true, color: excelDarkGreen),
                      _buildDataCell('$poOrderedQty Units', isBold: true, color: excelDarkGreen),
                      _buildDataCell('${grn.receivedQuantity} Units', isBold: true, color: excelGreen),
                      _buildDataCell('${grn.receivedQuantity - poOrderedQty}', isBold: true, color: excelDarkGreen),
                      _buildDataCell(
                        grn.receivedQuantity >= poOrderedQty && poOrderedQty > 0 ? 'COMPLIANT' : 'AUDIT REVIEW',
                        isBold: true,
                        color: grn.receivedQuantity >= poOrderedQty && poOrderedQty > 0 ? excelGreen : PdfColor.fromHex('#D97706'),
                      ),
                    ],
                  ),
                ],
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: gridBorder, width: 0.6),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: excelGreen),
                    children: [
                      _buildHeaderCell('CELL'),
                      _buildHeaderCell('PRODUCT SPECIFICATION'),
                      _buildHeaderCell('PO REF'),
                      _buildHeaderCell('SUPPLIER'),
                      _buildHeaderCell('ORDERED QTY'),
                      _buildHeaderCell('RECEIVED QTY'),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildDataCell('A1', isMuted: true),
                      _buildDataCell(grn.productName.isNotEmpty ? grn.productName : 'Product Material #${grn.productId}', isBold: true),
                      _buildDataCell(poNumberStr),
                      _buildDataCell(supplierNameStr),
                      _buildDataCell('$poOrderedQty Units'),
                      _buildDataCell('${grn.receivedQuantity} Units', isBold: true, color: excelGreen),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: excelLightGreen),
                    children: [
                      _buildDataCell('=SUM', isBold: true, color: excelDarkGreen),
                      _buildDataCell('TOTAL LEDGER SUMMARY', isBold: true, color: excelDarkGreen),
                      _buildDataCell(poNumberStr, isBold: true),
                      _buildDataCell(supplierNameStr, isBold: true),
                      _buildDataCell('$poOrderedQty Units', isBold: true, color: excelDarkGreen),
                      _buildDataCell('${grn.receivedQuantity} Units', isBold: true, color: excelGreen),
                    ],
                  ),
                ],
              ),
            pw.SizedBox(height: 10),

            // 5. Excel Formula / Operational Remarks Box
            pw.Text('OPERATIONAL REMARKS & EXCEL AUDIT CELL LOG', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textDark)),
            pw.SizedBox(height: 3),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(7),
              decoration: pw.BoxDecoration(
                color: cellBgAlt,
                borderRadius: pw.BorderRadius.circular(3),
                border: pw.Border.all(color: gridBorder, width: 0.6),
              ),
              child: pw.Text(
                grn.remarks.isNotEmpty ? grn.remarks : 'No terminal discrepancies, damage logs, or physical exceptions reported for this consignment.',
                style: pw.TextStyle(fontSize: 7.5, color: textDark, fontStyle: pw.FontStyle.italic),
              ),
            ),
            pw.SizedBox(height: 16),

            // 6. Dual Signature Spreadsheet Sign-Off Footer
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: gridBorder, width: 0.8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // Receiver Signature
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 120,
                        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: textDark, width: 1))),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text('Warehouse Receiver Sign-Off', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                      pw.Text('(${grn.receivedByName.isNotEmpty ? grn.receivedByName : "Store Operator"})', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
                    ],
                  ),
                  // Excel Audit Stamp Badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: excelGreen, width: 1.2),
                      borderRadius: pw.BorderRadius.circular(3),
                      color: excelLightGreen,
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'MICROSOFT EXCEL VERIFIED LEDGER',
                          style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: excelGreen, letterSpacing: 0.5),
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          'AUTOMATED SPREADSHEET MANIFEST',
                          style: pw.TextStyle(fontSize: 5.5, color: excelDarkGreen),
                        ),
                      ],
                    ),
                  ),
                  // QC Inspector Signature
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 120,
                        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: textDark, width: 1))),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text('QC Assurance Inspector Sign-Off', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                      pw.Text('(${grn.inspectedByName ?? "Inspection Pending"})', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Workbook: SCM_Goods_Received_Master_Ledger.xlsx', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
                pw.Text('Generated by SCM Enterprise Excel Automation Engine', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildFormulaCell(String label, String formula, String value, PdfColor valColor, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#4B5563'))),
          pw.Text(formula, style: pw.TextStyle(fontSize: 5.5, color: PdfColor.fromHex('#9CA3AF'))),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: valColor)),
        ],
      ),
    );
  }

  static pw.Widget _buildExcelCellPair(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#6B7280'))),
          pw.SizedBox(height: 1),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.0,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColor.fromHex('#111827'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 7.0, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _buildDataCell(String text, {bool isBold = false, bool isMuted = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.0,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isMuted ? PdfColor.fromHex('#9CA3AF') : PdfColor.fromHex('#111827')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);
    final poList = purchaseOrdersAsync.value ?? [];
    final matchedPo = poList.firstWhereOrNull((p) => p.id == grn.poId);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          'GRN Document Excel PDF (${grn.grnNumber.isNotEmpty ? grn.grnNumber : "GRN-${grn.id}"})',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [DynamicNotificationButton()],
      ),
      body: PdfPreview(
        build: (format) => generatePdf(grn, matchedPo),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
