import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class PurchaseOrderPDFScreen extends ConsumerWidget {
  final PurchaseOrderResponse order;

  const PurchaseOrderPDFScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requisitionsAsync = ref.watch(purchaseRequisitionListProvider);
    final quotationsAsync = ref.watch(quotationListProvider);

    final linkedRequisition = requisitionsAsync.asData?.value
        .where((r) => r.id == order.purchaseRequisitionId)
        .firstOrNull;

    final linkedQuotation = quotationsAsync.asData?.value
        .where((q) =>
            q.id == order.quotationId ||
            q.purchaseRequisitionId == order.purchaseRequisitionId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Order #${order.poNumber} PDF Preview'),
        backgroundColor: AppTheme.dark,
        foregroundColor: AppTheme.surfaceWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdfData = await _generatePdf(
                PdfPageFormat.a4,
                order,
                linkedRequisition,
                linkedQuotation,
              );
              await Printing.layoutPdf(onLayout: (_) => pdfData);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(
          format,
          order,
          linkedRequisition,
          linkedQuotation,
        ),
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    PurchaseOrderResponse po,
    PurchaseRequisitionResponse? req,
    QuotationResponseModel? quotation,
  ) async {
    final pdf = pw.Document();

    // ── Brand Colors (Matching User Template Image) ────────────────────
    final darkBlueHeader = PdfColor.fromHex('#002060');
    final primaryBlue = PdfColor.fromHex('#1E3A8A');
    final accentBlue = PdfColor.fromHex('#2563EB');
    final tealGreen = PdfColor.fromHex('#0D9488');
    final statusGreen = PdfColor.fromHex('#00A859');
    final purpleTheme = PdfColor.fromHex('#6D28D9');
    final purpleBg = PdfColor.fromHex('#F5F3FF');
    final purpleBorder = PdfColor.fromHex('#DDD6FE');
    final goldYellow = PdfColor.fromHex('#FFD700');
    final bgLightGrey = PdfColor.fromHex('#F8FAFC');
    final borderGrey = PdfColor.fromHex('#CBD5E1');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#64748B');

    // ── Resolved Data Formatting ───────────────────────────────────────
    final poNum = po.poNumber.isNotEmpty ? po.poNumber : 'PO-1783503003037';
    final poStatus = po.status.isNotEmpty ? po.status.toUpperCase() : 'APPROVED';

    final vendorName = po.supplierName.isNotEmpty
        ? po.supplierName
        : (quotation?.supplierName.isNotEmpty == true ? quotation!.supplierName : 'Apex Logistics Group');
    
    final vendorEmail = po.supplierEmail.isNotEmpty
        ? po.supplierEmail
        : (quotation?.supplierEmail.isNotEmpty == true ? quotation!.supplierEmail : 'srabonhasn66270@gmail.com');

    final qtnRef = quotation?.quotationNumber.isNotEmpty == true
        ? quotation!.quotationNumber
        : (po.quotationId > 0 ? '${po.quotationId}' : 'QTN-1782899905889');

    final leadTimeDays = quotation?.leadTimeDays ?? 14;
    final validUntil = quotation?.validUntil.isNotEmpty == true ? quotation!.validUntil : '2026-09-30';

    final issuedBy = po.issuedByName.isNotEmpty ? po.issuedByName : 'Procurement Officer';
    final reqIdStr = po.purchaseRequisitionId > 0 ? '${po.purchaseRequisitionId}' : '1';
    final urgencyStr = req?.urgencyLevel.isNotEmpty == true ? req!.urgencyLevel.toUpperCase() : 'CRITICAL';
    final approvedByStr = req?.approvedByName?.isNotEmpty == true ? req!.approvedByName! : 'MD. TANVIR';
    
    final reqDateStr = req?.createdAt.contains('T') == true
        ? req!.createdAt.split('T').first
        : (req?.createdAt.isNotEmpty == true ? req!.createdAt : '2026-07-25');

    final remarksVal = req?.remarks;
    final reqJustification = (remarksVal != null && remarksVal.isNotEmpty)
        ? remarksVal
        : 'Urgent procurement needed for garments raw materials production line.';

    final notesVal = quotation?.notes;
    final bidNotes = (notesVal != null && notesVal.isNotEmpty)
        ? notesVal
        : 'Price includes logistics and customs clearing handling costs.';

    final warrantyVal = quotation?.warranty;
    final warrantyStr = (warrantyVal != null && warrantyVal.isNotEmpty)
        ? warrantyVal
        : '1 Year Comprehensive';

    final itemTitle = quotation?.productName.isNotEmpty == true
        ? quotation!.productName
        : (req?.productNames.isNotEmpty == true ? req!.productNames.join(', ') : 'Industrial Knitting Machine Gear');

    final itemSpecs = quotation?.productDescription.isNotEmpty == true
        ? quotation!.productDescription
        : 'Technical Specs: High-grade hardened steel replacement gear components.';

    final qty = po.quantity > 0 ? po.quantity : (quotation?.quantity ?? 15);
    final unitPrice = qty > 0 ? po.totalAmount / qty : (quotation?.unitPrice ?? 320.0);
    final totalAmountStr = '\$${po.totalAmount.toStringAsFixed(2)} USD';

    final targetDeliveryDate = po.expectedDeliveryDate.contains('T')
        ? po.expectedDeliveryDate.split('T').first
        : (po.expectedDeliveryDate.isNotEmpty ? po.expectedDeliveryDate : '2026-08-20');

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── 1. Top Header Banner ────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Company Logo & Address Info
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Logo Icon Container
                      pw.Container(
                        width: 36,
                        height: 36,
                        decoration: pw.BoxDecoration(
                          color: darkBlueHeader,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'S',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'SCM ENTERPRISE LLC',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: darkBlueHeader,
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Global Procurement & Logistics Operations Hub',
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: primaryBlue,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text('[HQ]  ', style: const pw.TextStyle(fontSize: 7)),
                              pw.Text('Corporate SCM Tower, Supply Terminal District', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Row(
                            children: [
                              pw.Text('[EMAIL]  ', style: const pw.TextStyle(fontSize: 7)),
                              pw.Text('Email: procurement@scm-enterprise.com  |  [TEL] Line: +1 (800) 555-SCM1', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Right PO Box Badge Container
                  pw.Container(
                    width: 170,
                    decoration: pw.BoxDecoration(
                      color: bgLightGrey,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: borderGrey, width: 1),
                    ),
                    child: pw.Column(
                      children: [
                        // Top Dark Blue Header
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: darkBlueHeader,
                            borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(9)),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'PURCHASE ORDER',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        // Inner Content
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('PO NUMBER', style: pw.TextStyle(fontSize: 6.5, color: textMuted, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                poNum,
                                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('STATUS', style: pw.TextStyle(fontSize: 6.5, color: textMuted, fontWeight: pw.FontWeight.bold)),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: pw.BoxDecoration(
                                      color: statusGreen,
                                      borderRadius: pw.BorderRadius.circular(12),
                                    ),
                                    child: pw.Text(
                                      poStatus,
                                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 6),
                              pw.Center(
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(3),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.white,
                                    border: pw.Border.all(color: borderGrey),
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                  child: pw.BarcodeWidget(
                                    barcode: pw.Barcode.qrCode(),
                                    data: 'PO:$poNum|VENDOR:$vendorName|VAL:${po.totalAmount}|STATUS:$poStatus',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Horizontal Divider line with Diamond Accent
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Container(height: 1.5, color: darkBlueHeader)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                    child: pw.Text('+', style: pw.TextStyle(fontSize: 8, color: darkBlueHeader)),
                  ),
                  pw.Expanded(child: pw.Container(height: 1.5, color: darkBlueHeader)),
                ],
              ),

              pw.SizedBox(height: 10),

              // ── 2. Party Cards (Vendor & Delivery Origin Side-by-Side) ──────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Card: VENDOR / SUPPLIER BENEFICIARY
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: bgLightGrey,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: borderGrey),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 22,
                                height: 22,
                                decoration: pw.BoxDecoration(color: accentBlue, shape: pw.BoxShape.circle),
                                child: pw.Center(child: pw.Text('V', style: const pw.TextStyle(fontSize: 9, color: PdfColors.white))),
                              ),
                              pw.SizedBox(width: 6),
                              pw.Text(
                                'VENDOR / SUPPLIER BENEFICIARY',
                                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkBlueHeader),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(vendorName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                          pw.SizedBox(height: 2),
                          pw.Text('Email: $vendorEmail', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Container(height: 0.8, color: borderGrey),
                          pw.SizedBox(height: 6),
                          _buildBulletRow('>', 'Quotation Bid Ref: #$qtnRef', textDark),
                          pw.SizedBox(height: 3),
                          _buildBulletRow('>', 'Committed Lead Time: $leadTimeDays Days', textDark),
                          pw.SizedBox(height: 3),
                          _buildBulletRow('>', 'Valid Until: $validUntil', textDark),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 10),

                  // Right Card: DELIVERY & REQUISITION ORIGIN
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: bgLightGrey,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: borderGrey),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 22,
                                height: 22,
                                decoration: pw.BoxDecoration(color: tealGreen, shape: pw.BoxShape.circle),
                                child: pw.Center(child: pw.Text('D', style: const pw.TextStyle(fontSize: 9, color: PdfColors.white))),
                              ),
                              pw.SizedBox(width: 6),
                              pw.Text(
                                'DELIVERY & REQUISITION ORIGIN',
                                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: tealGreen),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text('Issued By: $issuedBy', style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                          pw.SizedBox(height: 2),
                          pw.Text('Destination: SCM Central Warehouse Gate #4', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Container(height: 0.8, color: borderGrey),
                          pw.SizedBox(height: 6),
                          _buildBulletRow('>', 'Linked Requisition: #PRQ-$reqIdStr ($urgencyStr Priority)', textDark),
                          pw.SizedBox(height: 3),
                          _buildBulletRow('>', 'Approved By: $approvedByStr', textDark),
                          pw.SizedBox(height: 3),
                          _buildBulletRow('>', 'Req Date: $reqDateStr', textDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // ── 3. LINKED AUDIT & TECHNICAL SPECIFICATION METADATA CARD ──
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: purpleBg,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: purpleBorder, width: 1),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column: Audit & Requisition Metadata
                    pw.Expanded(
                      flex: 3,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 24,
                            height: 24,
                            decoration: pw.BoxDecoration(color: purpleTheme, shape: pw.BoxShape.circle),
                            child: pw.Center(child: pw.Text('i', style: const pw.TextStyle(fontSize: 10, color: PdfColors.white))),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'LINKED AUDIT & TECHNICAL SPECIFICATION METADATA',
                                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: purpleTheme),
                                ),
                                pw.SizedBox(height: 4),
                                pw.RichText(
                                  text: pw.TextSpan(
                                    children: [
                                      pw.TextSpan(text: 'Requisition Justification: ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                                      pw.TextSpan(text: reqJustification, style: pw.TextStyle(fontSize: 7.5, color: textDark)),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(height: 3),
                                pw.RichText(
                                  text: pw.TextSpan(
                                    children: [
                                      pw.TextSpan(text: 'Awarded Bid Notes: ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic, color: textMuted)),
                                      pw.TextSpan(text: bidNotes, style: pw.TextStyle(fontSize: 7.5, fontStyle: pw.FontStyle.italic, color: textMuted)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Container(width: 1, height: 40, color: purpleBorder, margin: const pw.EdgeInsets.symmetric(horizontal: 10)),

                    // Right Column: Warranty Terms Box
                    pw.Expanded(
                      flex: 2,
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 22,
                            height: 22,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(color: purpleTheme, width: 1.5),
                            ),
                            child: pw.Center(child: pw.Text('W', style: pw.TextStyle(fontSize: 9, color: purpleTheme))),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Supplier Warranty Terms:', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                              pw.SizedBox(height: 1),
                              pw.Text(warrantyStr, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // ── 4. ORDER ITEM SPECIFICATION MATRIX (TABLE) ────────────
              pw.Row(
                children: [
                  pw.Text('[ITEMS]  ', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    'ORDER ITEM SPECIFICATION MATRIX',
                    style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: darkBlueHeader),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),

              pw.TableHelper.fromTextArray(
                headers: ['ITEM #', 'DESCRIPTION & CATALOG SPECS', 'QTY', 'UNIT PRICE\n(USD)', 'AMOUNT\n(USD)'],
                data: [
                  [
                    '01',
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(itemTitle, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                        pw.SizedBox(height: 2),
                        pw.Text(itemSpecs, style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                        pw.SizedBox(height: 4),
                        pw.Container(height: 0.5, color: borderGrey),
                        pw.SizedBox(height: 4),
                        pw.Text('[Linked PR #PRQ-$reqIdStr  |  Bid #Q-$qtnRef]', style: pw.TextStyle(fontSize: 7, color: textDark)),
                      ],
                    ),
                    '$qty',
                    '\$${unitPrice.toStringAsFixed(2)}',
                    '\$${po.totalAmount.toStringAsFixed(2)}',
                  ],
                ],
                border: pw.TableBorder.all(color: borderGrey, width: 1),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 8.5,
                ),
                headerDecoration: pw.BoxDecoration(color: darkBlueHeader),
                columnWidths: {
                  0: const pw.FixedColumnWidth(36),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FixedColumnWidth(45),
                  3: const pw.FixedColumnWidth(70),
                  4: const pw.FixedColumnWidth(80),
                },
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 12),

              // ── 5. Bottom Financial & Directives Row ──────────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Card: TERMS & SPECIAL DIRECTIVES
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: bgLightGrey,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: borderGrey),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text('[TERMS]  ', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text(
                                'TERMS & SPECIAL DIRECTIVES',
                                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkBlueHeader),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 8),
                          _buildNumberedDirective('01', 'Payment Terms:', 'Net 30 days upon warehouse inspection & GRN issuance.', darkBlueHeader, textDark),
                          pw.SizedBox(height: 5),
                          _buildNumberedDirective('02', 'Target Delivery Date:', 'Must deliver on/before $targetDeliveryDate ($leadTimeDays Days Lead Time).', darkBlueHeader, textDark),
                          pw.SizedBox(height: 5),
                          _buildNumberedDirective('03', 'Warranty Coverage:', warrantyStr, darkBlueHeader, textDark),
                          pw.SizedBox(height: 5),
                          _buildNumberedDirective('04', 'Package Labels:', 'Reference PO #$poNum and PR #PRQ-$reqIdStr on all packages.', darkBlueHeader, textDark),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 10),

                  // Right Card: TOTAL CONTRACT AMOUNT (Dark Blue Container)
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: darkBlueHeader,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 22,
                                height: 22,
                                decoration: pw.BoxDecoration(color: PdfColors.white, shape: pw.BoxShape.circle),
                                child: pw.Center(child: pw.Text('\$', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: darkBlueHeader))),
                              ),
                              pw.SizedBox(width: 6),
                              pw.Expanded(
                                child: pw.Text(
                                  'TOTAL CONTRACT AMOUNT',
                                  style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 8),
                          pw.Container(height: 0.5, color: PdfColors.white),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            totalAmountStr,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: goldYellow,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Tax, Freight & Clearance Included',
                            style: pw.TextStyle(fontSize: 7, color: PdfColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ── 6. Footer Thank You Message & Security Features ───────
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      '--  Thank You for Your Business!  --',
                      style: pw.TextStyle(
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                        color: darkBlueHeader,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'We appreciate your trust and partnership.',
                      style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Bottom Full-Width Dark Blue Security Bar
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: pw.BoxDecoration(
                  color: darkBlueHeader,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildFooterBadge('Trusted Partner'),
                    pw.Text('|', style: pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                    _buildFooterBadge('Quality Assured'),
                    pw.Text('|', style: pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                    _buildFooterBadge('On-Time Delivery'),
                    pw.Text('|', style: pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                    _buildFooterBadge('Secure & Compliant'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildBulletRow(String iconStr, String textStr, PdfColor color) {
    return pw.Row(
      children: [
        pw.Text('$iconStr  ', style: const pw.TextStyle(fontSize: 7.5)),
        pw.Expanded(
          child: pw.Text(
            textStr,
            style: pw.TextStyle(fontSize: 7.5, color: color, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildNumberedDirective(String numStr, String boldLabel, String textStr, PdfColor badgeColor, PdfColor textColor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 14,
          height: 14,
          decoration: pw.BoxDecoration(
            color: badgeColor,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              numStr,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 6.5, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '$boldLabel ', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textColor)),
                pw.TextSpan(text: textStr, style: pw.TextStyle(fontSize: 7, color: textColor)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFooterBadge(String labelStr) {
    return pw.Text(
      labelStr,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }
}
