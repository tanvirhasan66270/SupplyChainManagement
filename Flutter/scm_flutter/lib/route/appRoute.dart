import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/screen/forgetPasswordScreen.dart';
import 'package:scm_flutter/auth/screen/loginScreen.dart';
import 'package:scm_flutter/auth/screen/verifyEmail.dart';
import 'package:scm_flutter/cutomer/screen/add_payment_screen.dart';
import 'package:scm_flutter/cutomer/screen/billing_ledger_screen.dart';
import 'package:scm_flutter/cutomer/screen/customerDashboardScreen.dart';
import 'package:scm_flutter/cutomer/screen/customer_order_data_screen.dart';
import 'package:scm_flutter/cutomer/screen/customer_order_screen.dart';
import 'package:scm_flutter/cutomer/screen/customer_oredr_track_page.dart';
import 'package:scm_flutter/cutomer/screen/customer_profile_screen.dart';
import 'package:scm_flutter/cutomer/screen/customer_register_screen.dart';
import 'package:scm_flutter/driver/screen/driver_dashboard_screen.dart';
import 'package:scm_flutter/driver/screen/driver_profile_screen.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/entity/qc_inspaction_model.dart';
import 'package:scm_flutter/commercial_officer/screen/invoice_portal_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/commercial_invoice_data_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/commercial_invoice_form_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/commercial_invoice_pdf_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/customer_payment_data_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/customer_payment_pdf_screen.dart';
import 'package:scm_flutter/entity/invoiceModel.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';
import 'package:scm_flutter/commercial_officer/screen/commercial_dashboard_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/lc_bank_data_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/lc_bank_form_screen.dart';
import 'package:scm_flutter/entity/lc_bank.dart';
import 'package:scm_flutter/commercial_officer/screen/letter_of_credit_form_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/letter_of_credit_data_screen.dart';
import 'package:scm_flutter/cutomer/screen/customer_order_pdf_screen.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/procourment/screen/procourmet_dashboard_screen.dart';
import 'package:scm_flutter/procourment/screen/procurement_profile_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase-order_screen.dart';
import 'package:scm_flutter/procourment/screen/po_line_item_data_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_order_data_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_requisition_data_pdf_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_requisition_data_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_requisition_screen.dart';
import 'package:scm_flutter/procourment/screen/shipment_data_screen.dart';
import 'package:scm_flutter/procourment/screen/shipment_pdf_screen.dart';
import 'package:scm_flutter/procourment/screen/supplier_data_screen.dart';
import 'package:scm_flutter/procourment/screen/track_po_screen.dart';
import 'package:scm_flutter/product/screen/product_details_screen.dart';
import 'package:scm_flutter/product/screen/product_screen.dart';
import 'package:scm_flutter/suppplier/screen/po_line_item_form_screen.dart';
import 'package:scm_flutter/suppplier/screen/quotation_data_pdf_screen.dart';
import 'package:scm_flutter/suppplier/screen/quotation_data_screen.dart';
import 'package:scm_flutter/suppplier/screen/register_quotation_screen.dart';
import 'package:scm_flutter/suppplier/screen/shipment_form_screen.dart';
import 'package:scm_flutter/suppplier/screen/shipment_update_form_screen.dart';
import 'package:scm_flutter/suppplier/screen/supplier_dashboard_screen.dart';
import 'package:scm_flutter/suppplier/screen/supplier_form_screen.dart';
import 'package:scm_flutter/system/massage/chat_workspace_screen.dart';
import 'package:scm_flutter/system/notification/notification_screen.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_dashboard_screen.dart';
import 'package:scm_flutter/sales_officer/screen/sales_dashboard_screen.dart';
import 'package:scm_flutter/sales_officer/screen/sales_officer_profile_screen.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_inspection_data_screen.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_inspection_data_pdf_screen.dart';
import 'package:scm_flutter/manager/screen/manager_dashboard_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/logistics_officer_dashboard_screen.dart';
import 'package:scm_flutter/entity/inventory_model.dart';
import 'package:scm_flutter/logistics_officer/screen/inventory_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/inventory_form_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/inventory_data_pdf_screen.dart';
import 'package:scm_flutter/entity/stock_movement.dart';
import 'package:scm_flutter/logistics_officer/screen/stock_movement_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/stock_movement_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/stock_movement_pdf_screen.dart';
import 'package:scm_flutter/entity/grn_model.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_form_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_pdf_screen.dart';
import 'package:scm_flutter/entity/delivery_trip_model.dart';
import 'package:scm_flutter/logistics_officer/screen/delivery_trip_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/delivery_trip_form_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/delivery_trip_pdf_screen.dart';
import 'package:scm_flutter/entity/vehicle_model.dart';
import 'package:scm_flutter/logistics_officer/screen/vehicle_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/vehicle_form_screen.dart';
import 'package:scm_flutter/entity/catagory_model.dart';
import 'package:scm_flutter/sales_officer/screen/category_form_screen.dart';
import 'package:scm_flutter/sales_officer/screen/product_form_screen.dart';
import 'package:scm_flutter/product/screen/category_data_screen.dart';
import 'package:scm_flutter/product/screen/product_data_screen.dart';

/// App routing & role redirection manager.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';

    switch (name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case '/register':
      case '/customer-register':
        return MaterialPageRoute(
          builder: (_) => const CustomerRegisterScreen(),
          settings: settings,
        );

      case '/verify-email':
        final token = (settings.arguments as Map?)?['token'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(token: token),
          settings: settings,
        );

      case '/products':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ProductScreen()),
          settings: settings,
        );

      case '/product-details':
        final product = settings.arguments as ProductResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: ProductDetailsScreen(product: product)),
          settings: settings,
        );

      // ── Customer Routes ─────────────────────────
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerDashboardScreen()),
          settings: settings,
        );

      case '/customer-orders':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerOrderDataScreen()),
          settings: settings,
        );

      case '/customer-order':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerOrderScreen()),
          settings: settings,
        );

      case '/manager-dashboard':
      case '/manager':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ManagerDashboardScreen()),
          settings: settings,
        );

      case '/sales-dashboard':
      case '/sales-officer-dashboard':
      case '/sales':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: SalesDashboardScreen()),
          settings: settings,
        );

      case '/sales-officer-profile':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: SalesOfficerProfileScreen()),
          settings: settings,
        );
      case '/customer-order-track':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: CustomerOrderTrackScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/add-payment':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: AddPaymentScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/billing-ledger':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: BillingLedgerScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/invoice-portal':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: InvoicePortalScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/messages':
      case '/support':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ChatWorkspaceScreen()),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerProfileScreen()),
          settings: settings,
        );

      case '/procurement-profile':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ProcurementProfileScreen()),
          settings: settings,
        );

      case '/driver-dashboard':
      case '/driver':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: DriverDashboardScreen()),
          settings: settings,
        );

      case '/driver-profile':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: DriverProfileScreen()),
          settings: settings,
        );

      case '/notifications':
      case '/notification':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: NotificationScreen()),
          settings: settings,
        );

      // ── Commercial Routes ──────────────────────────
      case '/commercial-dashboard':
      case '/commercial':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CommercialDashboardScreen()),
          settings: settings,
        );

      case '/lcbank':
      case '/lc-bank-data':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: LCBankDataScreen()),
          settings: settings,
        );

      case '/letter-of-credit':
      case '/letter-of-credit-data':
      case '/lc-registry':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: LetterOfCreditDataScreen()),
          settings: settings,
        );

      case '/letter-of-credit-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: LetterOfCreditFormScreen()),
          settings: settings,
        );

      // ── Procurement Routes ─────────────────────────
      case '/procurement-dashboard':
      case '/procurement':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ProcurementDashboardScreen()),
          settings: settings,
        );

      case '/purchase-orders':
        final statusArg = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: PurchaseOrderDataScreen(initialStatus: statusArg)),
          settings: settings,
        );

      case '/track-po':
        final poNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: PurchaseOrderTrackingScreen(initialPoNumber: poNo)),
          settings: settings,
        );

      case '/purchase-order-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: PurchaseOrderScreen()),
          settings: settings,
        );

      case '/purchase-requisitions':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: PurchaseRequisitionDataScreen()),
          settings: settings,
        );

      case '/purchase-requisition-pdf':
        final requisition = settings.arguments as PurchaseRequisitionResponse;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: PurchaseRequisitionDataPDFScreen(requisition: requisition)),
          settings: settings,
        );

      case '/purchase-requisition-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: PurchaseRequisitionScreen()),
          settings: settings,
        );

      case '/quotations':
        final statusArg = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: QuotationDataScreen(initialStatus: statusArg)),
          settings: settings,
        );

      case '/quotation-create':
        final quotationToEdit = settings.arguments as QuotationResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: RegisterQuotationScreen(quotationToEdit: quotationToEdit)),
          settings: settings,
        );

      case '/quotation-pdf':
        final quotation = settings.arguments as QuotationResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: QuotationDataPDFScreen(quotation: quotation)),
          settings: settings,
        );

      case '/shipments':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ShipmentDataScreen()),
          settings: settings,
        );

      case '/shipment-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ShipmentFormScreen()),
          settings: settings,
        );

      case '/shipment-update':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ShipmentUpdateFormScreen()),
          settings: settings,
        );

      case '/shipment-pdf':
        final shipment = settings.arguments as ShipmentResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: ShipmentPDFScreen(shipment: shipment)),
          settings: settings,
        );

      case '/po-line-items':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: POLineItemDataScreen()),
          settings: settings,
        );

      case '/po-line-item-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: POLineItemFormScreen()),
          settings: settings,
        );

      case '/supplier-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: SupplierFormScreen()),
          settings: settings,
        );

      case '/suppliers':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: SupplierDataScreen()),
          settings: settings,
        );

      case '/qc-dashboard':
      case '/qc-inspector-dashboard':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: QCDashboardScreen()),
          settings: settings,
        );

      case '/qc-inspections':
      case '/qc-inspection-data':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: QCInspectionDataScreen()),
          settings: settings,
        );

      case '/qc-inspection-pdf':
        final inspection = settings.arguments as QCInspectionResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: QCInspectionDataPDFScreen(inspection: inspection)),
          settings: settings,
        );

      case '/logistics-dashboard':
      case '/logistics-officer-dashboard':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: LogisticsOfficerDashboardScreen()),
          settings: settings,
        );

      case '/inventory':
      case '/inventory-data':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: InventoryDataScreen()),
          settings: settings,
        );

      case '/inventory-create':
        final inventoryToEdit = settings.arguments as InventoryResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: InventoryFormScreen(inventoryToEdit: inventoryToEdit)),
          settings: settings,
        );

      case '/inventory-pdf':
        final inventory = settings.arguments as InventoryResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: InventoryDataPDFScreen(inventory: inventory)),
          settings: settings,
        );

      case '/stock-movement':
      case '/stock-movement-data':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: StockMovementDataScreen()),
          settings: settings,
        );

      case '/stock-movement-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: StockMovementScreen()),
          settings: settings,
        );

      case '/stock-movement-pdf':
        final movement = settings.arguments as StockMovementResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: StockMovementPDFScreen(movement: movement)),
          settings: settings,
        );

      case '/grn':
      case '/grn-data':
      case '/good-received-notes':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: GoodReceivedNoteDataScreen()),
          settings: settings,
        );

      case '/grn-create':
        final grnToEdit = settings.arguments as GoodsReceivedNoteResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: GoodReceivedNoteFormScreen(grnToEdit: grnToEdit)),
          settings: settings,
        );

      case '/grn-pdf':
        final grn = settings.arguments as GoodsReceivedNoteResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: GoodReceivedNotePDFScreen(grn: grn)),
          settings: settings,
        );

      case '/delivery-trip':
      case '/delivery-trip-data':
      case '/delivery-trips':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: DeliveryTripDataScreen()),
          settings: settings,
        );

      case '/delivery-trip-create':
        final tripToEdit = settings.arguments as DeliveryTripResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: DeliveryTripFormScreen(tripToEdit: tripToEdit)),
          settings: settings,
        );

      case '/delivery-trip-pdf':
        final trip = settings.arguments as DeliveryTripResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: DeliveryTripFormPDFScreen(trip: trip)),
          settings: settings,
        );

      case '/vehicles':
      case '/vehicle-data':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: VehicleDataScreen()),
          settings: settings,
        );

      case '/customer-order-pdf':
        final order = settings.arguments as CustomerOrderResponse;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: CustomerOrderPdfScreen(order: order)),
          settings: settings,
        );

      case '/commercial-invoice-data':
      case '/invoice-data':
      case '/billing':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CommercialInvoiceDataScreen()),
          settings: settings,
        );

      case '/invoice-create':
        final invToEdit = settings.arguments as InvoiceResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: CommercialInvoiceFormScreen(invoiceToEdit: invToEdit)),
          settings: settings,
        );

      case '/commercial-invoice-pdf':
        final inv = settings.arguments as InvoiceResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: CommercialInvoicePdfScreen(invoice: inv)),
          settings: settings,
        );

      case '/customer-payment-data':
      case '/payment-statement':
      case '/customer-payments':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerPaymentDataScreen()),
          settings: settings,
        );

      case '/customer-payment-pdf':
        final payment = settings.arguments as PaymentStatementResponse;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: CustomerPaymentPdfScreen(payment: payment)),
          settings: settings,
        );

      case '/lc-bank-create':
        final bankToEdit = settings.arguments as LCBankResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: LCBankFormScreen(bankToEdit: bankToEdit)),
          settings: settings,
        );

      case '/vehicle-create':
        final vehicleToEdit = settings.arguments as VehicleResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: VehicleFormScreen(vehicleToEdit: vehicleToEdit)),
          settings: settings,
        );

      case '/category-form':
      case '/category-create':
        final categoryToEdit = settings.arguments as CategoryResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: CategoryFormScreen(categoryToEdit: categoryToEdit)),
          settings: settings,
        );

      case '/product-form':
      case '/product-create':
        final productToEdit = settings.arguments as ProductResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: ProductFormScreen(productToEdit: productToEdit)),
          settings: settings,
        );

      case '/category-data':
      case '/categories':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CategoryDataScreen()),
          settings: settings,
        );

      case '/product-data':
      case '/product-list':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ProductDataScreen()),
          settings: settings,
        );

      case '/':
      default:
        return MaterialPageRoute(
          builder: (_) => const RoleRedirectScreen(),
          settings: settings,
        );
    }
  }
}

/// Decides initial route based on active user session & role.
class RoleRedirectScreen extends ConsumerWidget {
  const RoleRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();

        switch (user.role.toUpperCase()) {
          case 'CUSTOMER':
            return const CustomerDashboardScreen();
          case 'ADMIN':
          case 'MANAGER':
          case 'ROLE_MANAGER':
          case 'ROLE_ADMIN':
            return const ManagerDashboardScreen();
          case 'PROCUREMENT':
          case 'PROCUREMENT_OFFICER':
          case 'PURCHASING':
            return const ProcurementDashboardScreen();
          case 'COMMERCIAL':
          case 'COMMERCIAL_OFFICER':
          case 'ROLE_COMMERCIAL_OFFICER':
            return const CommercialDashboardScreen();
          case 'SUPPLIER':
            return const SupplierDashboardScreen();
          case 'DRIVER':
          case 'ROLE_DRIVER':
            return const DriverDashboardScreen();
          case 'QC':
          case 'QC_INSPECTOR':
          case 'ROLE_QC_INSPECTOR':
          case 'QC_INSPACTOR':
          case 'ROLE_QC_INSPACTOR':
            return const QCDashboardScreen();
          case 'LOGISTICS':
          case 'LOGISTICS_OFFICER':
          case 'ROLE_LOGISTICS_OFFICER':
            return const LogisticsOfficerDashboardScreen();
          case 'SALES':
          case 'SALES_OFFICER':
          case 'ROLE_SALES_OFFICER':
            return const SalesDashboardScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

/// Route guard for auth session check.
class _RequireAuth extends ConsumerWidget {
  const _RequireAuth({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return child;
      },
    );
  }
}