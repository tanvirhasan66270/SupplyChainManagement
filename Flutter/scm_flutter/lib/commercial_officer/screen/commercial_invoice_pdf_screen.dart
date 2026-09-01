import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/invoiceModel.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class CommercialInvoicePdfScreen extends StatelessWidget {
  const CommercialInvoicePdfScreen({
    super.key,
    required this.invoice,
  });

  final InvoiceResponseModel invoice;

  static Future<Uint8List> buildPdf(InvoiceResponseModel inv) async {
    final pdf = pw.Document();

    final darkBlueHeader = PdfColor.fromHex('#0B2545');
    final accentGreen = PdfColor.fromHex('#16A34A');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#64748B');
    final borderGrey = PdfColor.fromHex('#E2E8F0');
    final bgLightGrey = PdfColor.fromHex('#F8FAFC');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Corporate Header Banner ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SCM ENTERPRISE BILLING NODE',
                        style: pw.TextStyle(
                          color: darkBlueHeader,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Official Sales & Commercial Ledger Document',
                        style: pw.TextStyle(color: textMuted, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: inv.invoiceStatus == 'ISSUED'
                              ? PdfColor.fromHex('#DCFCE7')
                              : (inv.invoiceStatus == 'CANCELLED'
                                  ? PdfColor.fromHex('#FEE2E2')
                                  : PdfColor.fromHex('#F1F5F9')),
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(
                            color: inv.invoiceStatus == 'ISSUED'
                                ? PdfColor.fromHex('#86EFAC')
                                : (inv.invoiceStatus == 'CANCELLED'
                                    ? PdfColor.fromHex('#FCA5A5')
                                    : borderGrey),
                          ),
                        ),
                        child: pw.Text(
                          inv.invoiceStatus,
                          style: pw.TextStyle(
                            color: inv.invoiceStatus == 'ISSUED'
                                ? accentGreen
                                : (inv.invoiceStatus == 'CANCELLED'
                                    ? PdfColors.red800
                                    : textDark),
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(3),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          border: pw.Border.all(color: borderGrey),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: 'INV:${inv.invoiceNumber}|ORD:${inv.customerOrderId}|VAL:${inv.totalAmount}|STATUS:${inv.paymentStatus}',
                          width: 42,
                          height: 42,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: borderGrey, thickness: 1),
              pw.SizedBox(height: 12),

              // ── Invoice Title & Meta Box ──
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: bgLightGrey,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderGrey),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ISSUED TO RECIPIENT',
                          style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          inv.issuedToName,
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: textDark),
                        ),
                        pw.Text(inv.customerEmail, style: pw.TextStyle(fontSize: 9, color: textMuted)),
                        if (inv.deliveryAddress.isNotEmpty)
                          pw.Text('Address: ${inv.deliveryAddress}', style: pw.TextStyle(fontSize: 8.5, color: textDark)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE CODE', style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold)),
                        pw.Text(inv.invoiceNumber, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: darkBlueHeader)),
                        pw.SizedBox(height: 4),
                        pw.Text('Order Ref: #${inv.customerOrderId ?? "N/A"}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                        pw.Text('Currency: ${inv.currency}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // ── Financial Manifest Breakdown Table ──
              pw.Text('FINANCIAL BREAKDOWN MANIFEST', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkBlueHeader)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.8),
                children: [
                  _buildTableRow('Delivery Scheduled Date', inv.deliveryDate ?? 'Not Scheduled', bg: bgLightGrey),
                  _buildTableRow('Issued Timestamp', inv.issuedAt ?? 'Draft / Not Issued'),
                  _buildTableRow('Sales Officer ID', '#${inv.salesOfficerId ?? "N/A"}', bg: bgLightGrey),
                  _buildTableRow('Subtotal Volume Matrix', '${inv.currency} ${inv.subtotal.toStringAsFixed(2)}'),
                  _buildTableRow('Tax Rate & Amount (+)', '${(inv.taxRate * 100).toStringAsFixed(1)}% (${inv.currency} ${inv.taxAmount.toStringAsFixed(2)})', bg: bgLightGrey),
                  _buildTableRow('Logistics Shipping Fees (+)', '${inv.currency} ${inv.shippingFees.toStringAsFixed(2)}'),
                  _buildTableRow('Discount Margin (${inv.discountPercentage.toStringAsFixed(1)}%) (-)', '${inv.currency} ${inv.discountAmount.toStringAsFixed(2)}', bg: bgLightGrey),
                  _buildTableRow('Grand Total Financials', '${inv.currency} ${inv.totalAmount.toStringAsFixed(2)}', isBold: true, textColor: darkBlueHeader),
                  _buildTableRow('Paid Ledger Balance', '${inv.currency} ${inv.paidAmount.toStringAsFixed(2)}', bg: bgLightGrey, textColor: accentGreen),
                  _buildTableRow('Outstanding Due Net', '${inv.currency} ${inv.dueAmount.toStringAsFixed(2)}', isBold: true, textColor: inv.dueAmount > 0 ? PdfColors.red700 : accentGreen),
                  _buildTableRow('Payment Matrix & Method', '${inv.paymentStatus} (${inv.paymentMethod ?? "N/A"}) - Txn Ref: ${inv.transactionReference ?? "N/A"}', bg: bgLightGrey),
                  if (inv.cancelledReason != null && inv.cancelledReason!.isNotEmpty)
                    _buildTableRow('Cancellation Reason', inv.cancelledReason!, textColor: PdfColors.red800),
                ],
              ),
              pw.SizedBox(height: 16),

              if (inv.notes != null && inv.notes!.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FEF3C7'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromHex('#FCD34D')),
                  ),
                  child: pw.Text('Terms & Notes: ${inv.notes}', style: pw.TextStyle(fontSize: 8.5, color: PdfColor.fromHex('#92400E'))),
                ),
                pw.SizedBox(height: 20),
              ],

              pw.Spacer(),

              // ── Signature Seal Blocks ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 110, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Customer Signature', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('(Received & Acknowledged)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 110, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Commercial Officer', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('(Prepared & Verified)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 110, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Manager Signature', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('(Authorized & Approved)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Electronically Generated Commercial Invoice Ledger Document - SCM Corporate Cluster System',
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

  static pw.TableRow _buildTableRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? bg,
    PdfColor? textColor,
  }) {
    return pw.TableRow(
      decoration: bg != null ? pw.BoxDecoration(color: bg) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: textColor ?? PdfColors.black,
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
          'Invoice PDF - ${invoice.invoiceNumber}',
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
        build: (format) => buildPdf(invoice),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
