import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class PdfInvoiceGenerator {
  static Future<Uint8List> buildPdf({
    required CustomerOrderResponse order,
  }) async {
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

    final dateFormatted = order.createdAt.contains('T')
        ? order.createdAt.split('T').first
        : (order.createdAt.length >= 10 ? order.createdAt.substring(0, 10) : order.createdAt);

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
            // Top Header Banner
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'OFFICIAL INVOICE',
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(AppTheme.blue.toARGB32()),
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'SCM PRO Supply Chain Management',
                      style: const pw.TextStyle(
                        color: PdfColors.grey700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#DCFCE7'),
                        border: pw.Border.all(color: PdfColor.fromHex('#86EFAC')),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        order.paymentStatus,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#166534'),
                        ),
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
                        data: 'ORDER:${order.orderNumber}|VAL:${order.totalAmount}|STATUS:${order.status}|PAY:${order.paymentStatus}',
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey300, thickness: 1),
            pw.SizedBox(height: 12),

            // Invoice Metadata
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              children: [
                _buildMetaRow('Invoice Number:', 'INV-${order.orderNumber}', 'Order Reference:', order.orderNumber, isBlue: true),
                _buildMetaRow('Issued To:', order.customerName, 'Email:', order.customerEmail.isEmpty ? 'N/A' : order.customerEmail),
                _buildMetaRow('Issued Date:', dateFormatted, 'Currency:', order.currency.isEmpty ? 'BDT' : order.currency),
              ],
            ),
            pw.SizedBox(height: 20),

            // Itemized Breakdown Header
            pw.Container(
              width: double.infinity,
              color: PdfColor.fromHex('#0F172A'),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: pw.Text(
                'ITEMIZED PRODUCTS BREAKDOWN',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            // Items Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2.5),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey800),
                  children: [
                    _buildTh('SL'),
                    _buildTh('Description', align: pw.Alignment.centerLeft),
                    _buildTh('Qty'),
                    _buildTh('Unit Price'),
                    _buildTh('Total Amount', align: pw.Alignment.centerRight),
                  ],
                ),
                // Rows
                if (order.lineItems.isEmpty)
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text('No items included', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      ),
                      for (int i = 0; i < 4; i++) pw.Container(),
                    ],
                  )
                else
                  ...order.lineItems.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        _buildTd(index.toString(), align: pw.Alignment.center, isBold: true),
                        _buildTd(item.productName, align: pw.Alignment.centerLeft),
                        _buildTd(item.quantity.toString(), align: pw.Alignment.center),
                        _buildTd('BDT ${item.unitPrice.toStringAsFixed(2)}', align: pw.Alignment.centerRight),
                        _buildTd('BDT ${item.lineTotal.toStringAsFixed(2)}', align: pw.Alignment.centerRight, isBold: true, textColor: PdfColor.fromHex('#2563EB')),
                      ],
                    );
                  }),
              ],
            ),
            pw.SizedBox(height: 20),

            // Financial Summary Table
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 250,
                  child: pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(2.5),
                    },
                    children: [
                      _buildFinRow('Subtotal:', 'BDT ${order.itemSubtotal.toStringAsFixed(2)}'),
                      _buildFinRow('Shipping Fees:', 'BDT ${order.deliveryCharge.toStringAsFixed(2)}'),
                      _buildFinRow('Grand Total:', 'BDT ${order.totalAmount.toStringAsFixed(2)}', isBold: true, textColor: PdfColor.fromHex('#2563EB'), bg: PdfColor.fromHex('#F0F7FF')),
                      _buildFinRow('Total Paid:', 'BDT ${totalPaidNum.toStringAsFixed(2)}', isBold: true, textColor: PdfColors.green700, bg: PdfColor.fromHex('#F0FDF4')),
                      _buildFinRow('Balance Due:', 'BDT ${totalDueNum.toStringAsFixed(2)}', isBold: true, textColor: PdfColor.fromHex('#991B1B'), bg: PdfColor.fromHex('#FEF2F2')),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 50),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey600),
                    pw.SizedBox(height: 6),
                    pw.Text('Officer Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey600),
                    pw.SizedBox(height: 6),
                    pw.Text('Manager Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
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
                'Thank you for your business! Official SCM Engine Invoice',
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
  }) async {
    final pdfBytes = await buildPdf(order: order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_${order.orderNumber}.pdf',
    );
  }

  static pw.TableRow _buildMetaRow(
      String label1,
      String val1,
      String label2,
      String val2, {
        bool isBlue = false,
      }) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: pw.Row(
            children: [
              pw.Text(label1, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
              pw.SizedBox(width: 4),
              pw.SizedBox(
                width: 130, // ফিক্সড উইথ দেওয়া হলো যাতে ফ্লেক্স ক্র্যাশ না করে
                child: pw.Text(
                  val1,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: isBlue ? PdfColor.fromHex('#2563EB') : PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: pw.Row(
            children: [
              pw.Text(label2, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
              pw.SizedBox(width: 4),
              pw.SizedBox(
                width: 120, // ফিক্সড উইথ দেওয়া হলো
                child: pw.Text(
                  val2,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  static pw.Widget _buildTh(String text, {pw.Alignment align = pw.Alignment.center}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
          ),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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

  static pw.TableRow _buildFinRow(
    String label,
    String val, {
    bool isBold = false,
    PdfColor? textColor,
    PdfColor? bg,
  }) {
    return pw.TableRow(
      decoration: bg != null ? pw.BoxDecoration(color: bg) : null,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              val,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: textColor ?? PdfColors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
