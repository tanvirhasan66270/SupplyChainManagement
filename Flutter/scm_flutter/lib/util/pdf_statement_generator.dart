import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class PdfStatementGenerator {
  static Future<Uint8List> buildPdf({
    required CustomerOrderResponse order,
    required List<PaymentStatementResponse> payments,
  }) async {
    final pdf = pw.Document();

    // Load fonts supporting Bengali Taka symbol ৳ and clean layout
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

    final now = DateTime.now();
    final formattedGenDate = '${now.month}/${now.day}/${now.year}, ${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final totalPaidNum = (order.paidAmount is num)
        ? (order.paidAmount as num).toDouble()
        : double.tryParse(order.paidAmount.toString()) ?? 0.0;

    final totalDueNum = (order.dueAmount is num)
        ? (order.dueAmount as num).toDouble()
        : double.tryParse(order.dueAmount.toString()) ?? 0.0;

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
            // Top Blue Header Banner
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: PdfColor.fromInt(AppTheme.blue.toARGB32()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'OFFICIAL PAYMENT STATEMENT',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Supply Chain Management Financial Settlement Report',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Metadata Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              children: [
                _buildMetaRow('Customer Order No:', order.orderNumber, 'Invoice Reference:', 'INV-${order.orderNumber}', value1Color: PdfColors.blue800),
                _buildMetaRow('Issued To Name:', order.customerName, 'Settlement Currency:', order.currency.isEmpty ? 'BDT' : order.currency, value1Bold: true, value2Bold: true),
                _buildMetaRow('Generated Date:', formattedGenDate, 'Payment Status:', order.paymentStatus, value2Color: PdfColors.green700, value2Bold: true),
              ],
            ),
            pw.SizedBox(height: 16),

            // Section 1: Transaction Log Header
            _buildSectionHeader('PAYMENT STATEMENT TRANSACTION LOG'),

            // Transaction Log Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: {
                0: const pw.FixedColumnWidth(28),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2.5),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(2.5),
              },
              children: [
                // Table Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey900),
                  children: [
                    _buildTh('SL'),
                    _buildTh('Date & Time'),
                    _buildTh('Method'),
                    _buildTh('Account / Ref No'),
                    _buildTh('Paid Amount'),
                    _buildTh('Status'),
                  ],
                ),
                // Data Rows
                if (payments.isEmpty)
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Center(
                          child: pw.Text(
                            'No payment transactions found',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                          ),
                        ),
                      ),
                      for (int i = 0; i < 5; i++) pw.Container(),
                    ],
                  )
                else
                  ...payments.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final p = entry.value;
                    final refNo = (p.customerAccountNumber != null && p.customerAccountNumber!.isNotEmpty)
                        ? p.customerAccountNumber!
                        : (p.transactionId.isNotEmpty ? p.transactionId : '-');
                    final formattedDate = p.createdAt.contains('T')
                        ? p.createdAt.replaceFirst('T', ', ').substring(0, p.createdAt.length > 19 ? 19 : p.createdAt.length)
                        : p.createdAt;

                    return pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        _buildTd(index.toString(), align: pw.Alignment.center, isBold: true),
                        _buildTd(formattedDate),                        _buildTdMethod(p.paymentMethod),
                        _buildTd(refNo),
                        _buildTd('BDT ${p.paidAmount.toStringAsFixed(2)}', align: pw.Alignment.centerRight, isBold: true, textColor: PdfColors.green700),
                        _buildTdStatus(p.issueStatus),
                      ],
                    );
                  }),
              ],
            ),
            pw.SizedBox(height: 20),

            // Section 2: Financial Breakdown Header
            _buildSectionHeader('FINANCIAL BREAKDOWN SUMMARY'),

            // Summary Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
              },
              children: [
                _buildSummaryRow('Subtotal Amount:', 'BDT ${order.itemSubtotal.toStringAsFixed(2)}'),
                _buildSummaryRow('Tax & Shipping Fees:', 'BDT ${order.deliveryCharge.toStringAsFixed(2)}'),
                _buildSummaryRow('Total Order Amount:', 'BDT ${order.totalAmount.toStringAsFixed(2)}', isBold: true, valueColor: PdfColors.blue800, rowBg: PdfColor.fromHex('#F0F7FF')),
                _buildSummaryRow('Total Paid Amount:', 'BDT ${totalPaidNum.toStringAsFixed(2)}', isBold: true, valueColor: PdfColors.green700, rowBg: PdfColor.fromHex('#F0FDF4')),
              ],
            ),
            pw.SizedBox(height: 12),

            // Total Due Amount Banner Box
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FEF2F2'),
                border: pw.Border.all(color: PdfColor.fromHex('#FECACA'), width: 1),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Due Amount:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#991B1B'),
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    'BDT ${totalDueNum.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#991B1B'),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 45),

            // Signatures Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 160, height: 1, color: PdfColors.grey600),
                    pw.SizedBox(height: 6),
                    pw.Text('Commercial Officer Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text('Commercial Accounts & Verification', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 160, height: 1, color: PdfColors.grey600),
                    pw.SizedBox(height: 6),
                    pw.Text('Manager Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text('General Manager / Operations', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(color: PdfColors.grey300, thickness: 0.8),
            pw.SizedBox(height: 8),

            // Footer
            pw.Center(
              child: pw.Text(
                'Official System Generated Statement -- Supply Chain Management Engine',
                style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> downloadOrPrint({
    required CustomerOrderResponse order,
    required List<PaymentStatementResponse> payments,
  }) async {
    final pdfBytes = await buildPdf(order: order, payments: payments);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Statement_${order.orderNumber}.pdf',
    );
  }

  // Helpers for table building
  static pw.TableRow _buildMetaRow(
      String label1,
      String val1,
      String label2,
      String val2, {
        PdfColor? value1Color,
        PdfColor? value2Color,
        bool value1Bold = false,
        bool value2Bold = false,
      }) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Row(
            children: [
              pw.Text(label1, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
              pw.SizedBox(width: 6),
              pw.SizedBox(
                width: 140, // ফিক্সড উইথ দেওয়া হলো যাতে ফ্লেক্স ক্র্যাশ না করে
                child: pw.Text(
                  val1,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: value1Bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: value1Color ?? PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Row(
            children: [
              pw.Text(label2, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
              pw.SizedBox(width: 6),
              pw.SizedBox(
                width: 130, // ফিক্সড উইথ দেওয়া হলো
                child: pw.Text(
                  val2,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: value2Bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: value2Color ?? PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      color: PdfColor.fromHex('#1E3A8A'),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildTh(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildTd(
    String text, {
    pw.Alignment align = pw.Alignment.centerLeft,
    bool isBold = false,
    PdfColor? textColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: textColor ?? PdfColors.black,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildTdMethod(String method) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Center(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Text(
            method,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildTdStatus(String status) {
    String label = status;
    PdfColor bg = PdfColors.grey100;
    PdfColor border = PdfColors.grey400;
    PdfColor text = PdfColors.grey800;

    if (status == PaymentStatementStatus.confirmedByOfficer || status == 'CONFIRMED_BY_OFFICER') {
      label = 'Confirmed by Officer';
      bg = PdfColor.fromHex('#DCFCE7');
      border = PdfColor.fromHex('#86EFAC');
      text = PdfColor.fromHex('#166534');
    } else if (status == PaymentStatementStatus.pendingVerification || status == 'PENDING_VERIFICATION') {
      label = 'Pending Verification';
      bg = PdfColor.fromHex('#FEF9C3');
      border = PdfColor.fromHex('#FDE047');
      text = PdfColor.fromHex('#854D0E');
    } else if (status == PaymentStatementStatus.failedOrRejected || status == 'FAILED_OR_REJECTED') {
      label = 'Rejected / Failed';
      bg = PdfColor.fromHex('#FEE2E2');
      border = PdfColor.fromHex('#FCA5A5');
      text = PdfColor.fromHex('#991B1B');
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: pw.Center(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(
            color: bg,
            border: pw.Border.all(color: border, width: 0.8),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: text,
            ),
          ),
        ),
      ),
    );
  }

  static pw.TableRow _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? valueColor,
    PdfColor? rowBg,
  }) {
    return pw.TableRow(
      decoration: rowBg != null ? pw.BoxDecoration(color: rowBg) : null,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? PdfColors.grey900 : PdfColors.grey700,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: valueColor ?? PdfColors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
