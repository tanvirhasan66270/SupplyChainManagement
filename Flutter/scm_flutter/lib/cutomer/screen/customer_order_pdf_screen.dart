import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/pdf_invoice_generator.dart';

class CustomerOrderPdfScreen extends StatelessWidget {
  const CustomerOrderPdfScreen({
    super.key,
    required this.order,
  });

  final CustomerOrderResponse order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          'Customer Order PDF - #${order.orderNumber}',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfInvoiceGenerator.buildPdf(order: order),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
