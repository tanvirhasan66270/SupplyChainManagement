import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class CustomerPaymentPdfScreen extends StatelessWidget {
  const CustomerPaymentPdfScreen({
    super.key,
    required this.payment,
  });

  final PaymentStatementResponse payment;

  static Future<Uint8List> buildPdf(PaymentStatementResponse p) async {
    final pdf = pw.Document();

    final darkHeader = PdfColor.fromHex('#0F172A');
    final accentBlue = PdfColor.fromHex('#2563EB');
    final successGreen = PdfColor.fromHex('#16A34A');
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
              // ── Corporate Header ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SCM ENTERPRISE FINANCIAL GATEWAY',
                        style: pw.TextStyle(
                          color: darkHeader,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Official Customer Payment Verification Receipt',
                        style: pw.TextStyle(color: textMuted, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: p.issueStatus == 'CONFIRMED_BY_OFFICER'
                              ? PdfColor.fromHex('#DCFCE7')
                              : (p.issueStatus == 'FAILED_OR_REJECTED'
                                  ? PdfColor.fromHex('#FEE2E2')
                                  : PdfColor.fromHex('#FEF3C7')),
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(
                            color: p.issueStatus == 'CONFIRMED_BY_OFFICER'
                                ? PdfColor.fromHex('#86EFAC')
                                : (p.issueStatus == 'FAILED_OR_REJECTED'
                                    ? PdfColor.fromHex('#FCA5A5')
                                    : PdfColor.fromHex('#FCD34D')),
                          ),
                        ),
                        child: pw.Text(
                          p.issueStatus == 'CONFIRMED_BY_OFFICER'
                              ? 'CONFIRMED / ACCEPTED'
                              : (p.issueStatus == 'FAILED_OR_REJECTED' ? 'REJECTED' : 'PENDING VERIFICATION'),
                          style: pw.TextStyle(
                            color: p.issueStatus == 'CONFIRMED_BY_OFFICER'
                                ? successGreen
                                : (p.issueStatus == 'FAILED_OR_REJECTED' ? PdfColors.red800 : PdfColor.fromHex('#92400E')),
                            fontSize: 9,
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
                          data: 'PAY:${p.id}|TXN:${p.transactionId}|ORD:${p.orderNumber}|AMT:${p.paidAmount}|STATUS:${p.issueStatus}',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: borderGrey, thickness: 1),
              pw.SizedBox(height: 12),

              // ── Receipt Meta Box ──
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
                        pw.Text('PAYMENT RECORD ID', style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('#PAY-${p.id}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: darkHeader)),
                        pw.SizedBox(height: 4),
                        pw.Text('Transaction Reference: ${p.transactionId}', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: accentBlue)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('ORDER REFERENCE', style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Order #${p.orderNumber} (ID: ${p.customerOrderId})', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                        pw.SizedBox(height: 4),
                        pw.Text('Submission Date: ${p.createdAt}', style: pw.TextStyle(fontSize: 8.5, color: textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // ── Financial Breakdown Table ──
              pw.Text('PAYMENT AUDIT & MANIFEST DETAILS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkHeader)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.8),
                children: [
                  _buildTableRow('Verified Paid Amount', 'BDT ${p.paidAmount.toStringAsFixed(2)}', isBold: true, textColor: successGreen, bg: bgLightGrey),
                  _buildTableRow('Previous Paid Balance', 'BDT ${p.oldPaidAmount.toStringAsFixed(2)}'),
                  _buildTableRow('Payment Instrument / Channel', p.paymentMethod.toUpperCase(), bg: bgLightGrey, isBold: true),
                  _buildTableRow('Customer Account / Phone Ref', p.customerAccountNumber ?? 'N/A'),
                  _buildTableRow('Transaction Reference ID', p.transactionId, bg: bgLightGrey, isBold: true, textColor: accentBlue),
                  _buildTableRow('Payment Proof Check Image', p.paymentCheckImage.isNotEmpty ? p.paymentCheckImage : 'No Attachment Attached'),
                  _buildTableRow('Associated Customer Order ID', '#${p.customerOrderId}', bg: bgLightGrey),
                  _buildTableRow('Verification Audit Status', p.issueStatus, isBold: true),
                  _buildTableRow('Last Audit Timestamp', p.updatedAt, bg: bgLightGrey),
                ],
              ),
              pw.SizedBox(height: 20),

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
                      pw.Text('(Payment Depositor)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 110, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Commercial Officer', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('(Verified & Accepted)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 110, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Finance Manager', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('(Authorized Audit Approval)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'System Generated Customer Payment Verification Document - SCM Financial Audit Node',
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
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          'Payment Receipt - #${payment.id}',
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
        build: (format) => buildPdf(payment),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
