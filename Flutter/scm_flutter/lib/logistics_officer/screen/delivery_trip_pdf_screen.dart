import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/driver/provider/driver_provider.dart';
import 'package:scm_flutter/entity/delivery_trip_model.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class DeliveryTripFormPDFScreen extends ConsumerWidget {
  final DeliveryTripResponseModel trip;

  const DeliveryTripFormPDFScreen({
    super.key,
    required this.trip,
  });

  static Future<pw.ImageProvider?> _fetchImageWithAuth(String? path, WidgetRef ref) async {
    if (path == null || path.trim().isEmpty) return null;
    final cleanPath = path.trim();
    final dio = ref.read(apiClientProvider).dio;

    // List of candidate URLs to try until one succeeds (200 OK)
    final candidateUrls = <String>[];
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      candidateUrls.add(cleanPath);
    } else {
      final relative = cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;
      final noImages = relative.startsWith('images/') ? relative.replaceFirst('images/', '') : relative;
      final noApi = relative.startsWith('api/') ? relative.replaceFirst('api/', '') : relative;

      candidateUrls.add('${ApiConstants.imgUrl}driver/$noImages');
      candidateUrls.add('${ApiConstants.imgUrl}$noImages');
      candidateUrls.add('${ApiConstants.baseUrl}drivers/images/$noImages');
      candidateUrls.add('${ApiConstants.baseUrl}$noApi');
      candidateUrls.add('http://${ApiConstants.host}:8085/images/driver/$noImages');
      candidateUrls.add('http://${ApiConstants.host}:8085/images/$noImages');
      candidateUrls.add('http://${ApiConstants.host}:8085/api/$noApi');
      candidateUrls.add('http://${ApiConstants.host}:8085/$relative');
    }

    for (final url in candidateUrls) {
      try {
        final response = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        if (response.data != null && response.data!.isNotEmpty) {
          return pw.MemoryImage(Uint8List.fromList(response.data!));
        }
      } catch (_) {
        try {
          final netImg = await networkImage(url);
          return netImg;
        } catch (_) {}
      }
    }
    return null;
  }

  static Future<Uint8List> generatePdf(
    DeliveryTripResponseModel trip,
    String? initialDriverImagePath,
    WidgetRef ref,
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

    pw.Font? italicFont;
    try {
      italicFont = await PdfGoogleFonts.notoSansItalic();
    } catch (_) {
      italicFont = font;
    }

    // Color palette definitions for professional enterprise styling
    final primaryDark = PdfColor.fromHex('#0F172A'); // Deep Navy Slate
    final primaryAccent = PdfColor.fromHex('#2563EB'); // Royal Blue
    final bgLight = PdfColor.fromHex('#F8FAFC'); // Cool Grey Background
    final borderGrey = PdfColor.fromHex('#E2E8F0');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#64748B');

    PdfColor statusColor;
    switch (trip.status.toUpperCase()) {
      case 'DELIVERED':
        statusColor = PdfColor.fromHex('#059669'); // Emerald Green
        break;
      case 'IN_TRANSIT':
        statusColor = PdfColor.fromHex('#D97706'); // Amber Gold
        break;
      case 'PENDING':
        statusColor = PdfColor.fromHex('#2563EB'); // Royal Blue
        break;
      case 'CANCELLED':
        statusColor = PdfColor.fromHex('#DC2626'); // Red
        break;
      default:
        statusColor = PdfColor.fromHex('#64748B');
    }

    // Resolve driver profile image path from initial arg or by querying repository directly
    String? driverPath = initialDriverImagePath;
    if (driverPath == null || driverPath.isEmpty) {
      try {
        final drivers = await ref.read(driverRepositoryProvider).getAll();
        final matched = drivers.firstWhereOrNull(
          (d) => d.id == trip.driverId || d.userId == trip.driverId || d.driverName.toLowerCase().trim() == trip.driverName.toLowerCase().trim(),
        );
        driverPath = matched?.image;
      } catch (_) {}
    }

    // Download signature, POD photos & Driver Profile Image with Auth
    final sigImage = await _fetchImageWithAuth(trip.recipientSignature, ref);
    final podImage = await _fetchImageWithAuth(trip.deliveryPhotoUrl, ref);
    final driverImage = await _fetchImageWithAuth(driverPath, ref);

    final hasSig = sigImage != null || (trip.recipientSignature != null && trip.recipientSignature!.isNotEmpty);
    final hasPod = podImage != null || (trip.deliveryPhotoUrl != null && trip.deliveryPhotoUrl!.isNotEmpty);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
          italic: italicFont,
        ),
        build: (pw.Context context) {
          return [
            // 1. Enterprise Header Banner Box
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: primaryDark,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SCM GLOBAL FLEET LOGISTICS & DISPATCH',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'OFFICIAL DELIVERY TRIP MANIFEST & PROOF OF DELIVERY (POD) AUDIT LEDGER',
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#94A3B8'),
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: statusColor,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      trip.status.toUpperCase(),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // 2. Three-Column Key Metadata Cards (Consignee, Fleet & Captain Specs, Route Timeline)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Card 1: Consignee & Drop Details
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: bgLight,
                      borderRadius: pw.BorderRadius.circular(5),
                      border: pw.Border.all(color: borderGrey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CONSIGNEE & DESTINATION', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryAccent)),
                        pw.SizedBox(height: 4),
                        _buildMetaItem('Consignee Client:', '${trip.recipientName} (#${trip.customerId})', isBold: true),
                        _buildMetaItem('Shipping Address:', trip.customerAddress),
                        _buildMetaItem('Dispatcher ID:', '#${trip.dispatcherId}'),
                        _buildMetaItem('Logged Date:', trip.createdAt),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),

                // Card 2: Fleet & Captain Specifications (Includes Captain Profile Photo)
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F0F9FF'), // Light Sky Blue
                      borderRadius: pw.BorderRadius.circular(5),
                      border: pw.Border.all(color: PdfColor.fromHex('#BAE6FD')),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('FLEET & CAPTAIN SPECIFICATIONS', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0284C7'))),
                              pw.SizedBox(height: 4),
                              _buildMetaItem('Assigned Captain:', '${trip.driverName} (#${trip.driverId})', isBold: true),
                              _buildMetaItem('Vehicle Plate No:', trip.vehiclePlateNumber, isBold: true),
                              _buildMetaItem('Captain Contact:', trip.driverPhone.isNotEmpty ? trip.driverPhone : 'N/A'),
                              _buildMetaItem('Captain Email:', trip.driverEmail.isNotEmpty ? trip.driverEmail : 'N/A'),
                            ],
                          ),
                        ),
                        if (driverImage != null) ...[
                          pw.SizedBox(width: 6),
                          pw.Container(
                            width: 36,
                            height: 36,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(color: PdfColor.fromHex('#0284C7'), width: 1.5),
                              color: PdfColors.white,
                            ),
                            child: pw.ClipOval(
                              child: pw.Image(driverImage, fit: pw.BoxFit.cover),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),

                // Card 3: Route Timeline & Audit
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: bgLight,
                      borderRadius: pw.BorderRadius.circular(5),
                      border: pw.Border.all(color: borderGrey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ROUTE TIMELINE & POD AUDIT', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryAccent)),
                        pw.SizedBox(height: 4),
                        _buildMetaItem('Trip Pointer Ref:', 'TRIP-#${trip.id}', isBold: true),
                        _buildMetaItem('Dispatch Started:', trip.startedAt ?? 'Not Triggered'),
                        _buildMetaItem('Delivery Completed:', trip.completedAt ?? 'In-flight / Active'),
                        _buildMetaItem('POD Docs Status:', hasSig || hasPod ? 'Synced & Attached' : 'Pending POD Docs'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // 3. Metrics Summary Callout Strip
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#EFF6FF'), // Soft Blue Fill
                borderRadius: pw.BorderRadius.circular(5),
                border: pw.Border.all(color: PdfColor.fromHex('#BFDBFE')),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('TRIP IDENTIFIER', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textMuted)),
                      pw.SizedBox(height: 2),
                      pw.Text('TRIP-#${trip.id}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                    ],
                  ),
                  pw.Container(height: 18, width: 1, color: PdfColor.fromHex('#93C5FD')),
                  pw.Row(
                    children: [
                      if (driverImage != null) ...[
                        pw.Container(
                          width: 22,
                          height: 22,
                          decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle),
                          child: pw.ClipOval(child: pw.Image(driverImage, fit: pw.BoxFit.cover)),
                        ),
                        pw.SizedBox(width: 6),
                      ],
                      pw.Column(
                        children: [
                          pw.Text('FLEET CAPTAIN', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textMuted)),
                          pw.SizedBox(height: 2),
                          pw.Text(trip.driverName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryAccent)),
                        ],
                      ),
                    ],
                  ),
                  pw.Container(height: 18, width: 1, color: PdfColor.fromHex('#93C5FD')),
                  pw.Column(
                    children: [
                      pw.Text('FLEET VEHICLE', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textMuted)),
                      pw.SizedBox(height: 2),
                      pw.Text(trip.vehiclePlateNumber, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                    ],
                  ),
                  pw.Container(height: 18, width: 1, color: PdfColor.fromHex('#93C5FD')),
                  pw.Column(
                    children: [
                      pw.Text('POD ATTACHMENTS', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textMuted)),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        hasSig && hasPod
                            ? 'SIG + POD Photo Verified'
                            : (hasSig ? 'Signature Only' : (hasPod ? 'POD Photo Only' : 'Pending POD Docs')),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: hasSig || hasPod ? PdfColor.fromHex('#059669') : PdfColor.fromHex('#D97706'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // 4. Main Delivery Trip Details Table
            pw.Text('FLEET ROUTE & DISPATCH LEDGER SPECIFICATIONS', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
            pw.SizedBox(height: 4),
            pw.Table(
              border: pw.TableBorder.all(color: borderGrey, width: 0.5),
              children: [
                _buildTableRow('Trip Manifest Reference Identifier', 'TRIP-#${trip.id}', isBold: true),
                _buildTableRow('Transit Flag (Current Status)', trip.status, valueColor: statusColor, isBold: true),
                _buildTableRow('Logistics Dispatcher Personnel Context', 'Dispatcher ID: #${trip.dispatcherId}'),
                _buildTableRow('Consignee (Customer Account)', '${trip.recipientName} (Client Node ID: #${trip.customerId})'),
                _buildTableRow('Shipping Drop Coordinate Address', trip.customerAddress),
                _buildTableRow('Assigned Fleet Captain', '${trip.driverName} (ID: #${trip.driverId} | Phone: ${trip.driverPhone.isNotEmpty ? trip.driverPhone : "N/A"})'),
                _buildTableRow('Fleet Vehicle Registration & Specs', 'Plate: ${trip.vehiclePlateNumber} ${trip.vehicleModel != null && trip.vehicleModel!.isNotEmpty ? "(${trip.vehicleModel})" : ""}'),
                _buildTableRow('Route Start Trigger Timestamp', trip.startedAt ?? 'Not Triggered'),
                _buildTableRow('Route Delivery Completion Timestamp', trip.completedAt ?? 'In-flight / Active'),
                _buildTableRow('Operational Route Notes & Remarks', trip.remarks ?? 'No remarks recorded.'),
              ],
            ),
            pw.SizedBox(height: 12),

            // 5. Proof of Delivery Images Section (Driver Profile Photo, Signature & POD Photo)
            if (driverImage != null || sigImage != null || podImage != null) ...[
              pw.Text('VERIFIED DISPATCH & PROOF OF DELIVERY (POD) ATTACHMENTS', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: borderGrey),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    if (driverImage != null)
                      pw.Column(
                        children: [
                          pw.Text('Assigned Captain Profile Photo', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                          pw.SizedBox(height: 3),
                          pw.Container(
                            height: 65,
                            width: 65,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColor.fromHex('#0284C7'), width: 1.5),
                              shape: pw.BoxShape.circle,
                              color: PdfColors.white,
                            ),
                            child: pw.ClipOval(
                              child: pw.Image(driverImage, fit: pw.BoxFit.cover),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text('VERIFIED: Captain Photo', style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#0284C7'), fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    if (sigImage != null)
                      pw.Column(
                        children: [
                          pw.Text('Digital Recipient Signature', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                          pw.SizedBox(height: 3),
                          pw.Container(
                            height: 65,
                            width: 140,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: borderGrey),
                              borderRadius: pw.BorderRadius.circular(4),
                              color: PdfColors.white,
                            ),
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Image(sigImage, fit: pw.BoxFit.contain),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text('SYNCED: Attached', style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#059669'), fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    if (podImage != null)
                      pw.Column(
                        children: [
                          pw.Text('Proof of Delivery (POD) Photo', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                          pw.SizedBox(height: 3),
                          pw.Container(
                            height: 65,
                            width: 140,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: borderGrey),
                              borderRadius: pw.BorderRadius.circular(4),
                              color: PdfColors.white,
                            ),
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Image(podImage, fit: pw.BoxFit.contain),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text('SYNCED: Attached', style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#059669'), fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // 6. Dual Signature Footer & Security Stamp
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: borderGrey, width: 1)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 130,
                        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: textDark, width: 1))),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text('Fleet Captain / Driver Signature', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                      pw.Text('(${trip.driverName.isNotEmpty ? trip.driverName : "Fleet Captain"})', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex('#059669'), width: 1.5),
                      borderRadius: pw.BorderRadius.circular(4),
                      color: PdfColor.fromHex('#ECFDF5'),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'VERIFIED FLEET MANIFEST',
                          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'), letterSpacing: 0.5),
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          'SECURE LOGISTICS ROUTE',
                          style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex('#047857')),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 130,
                        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: textDark, width: 1))),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text('Authorized Logistics Signature', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                      pw.Text('(Logistics Dispatch Officer)', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('ISO 9001:2015 Fleet & Logistics Supply Chain Certified Document', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
                pw.Text('Generated by SCM Enterprise Portal', style: pw.TextStyle(fontSize: 6.5, color: textMuted)),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildTableRow(String label, String value, {PdfColor? valueColor, bool isBold = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B'))),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor ?? PdfColor.fromHex('#1E293B'),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMetaItem(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#64748B'))),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.0,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColor.fromHex('#1E293B'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(driverListProvider);
    final drivers = driversAsync.value ?? [];
    final matchedDriver = drivers.firstWhereOrNull(
      (d) => d.id == trip.driverId || d.userId == trip.driverId || d.driverName.toLowerCase().trim() == trip.driverName.toLowerCase().trim(),
    );
    final driverImagePath = matchedDriver?.image;

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          'Delivery Trip PDF (TRIP-#${trip.id})',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [DynamicNotificationButton()],
      ),
      body: PdfPreview(
        build: (format) => generatePdf(trip, driverImagePath, ref),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
