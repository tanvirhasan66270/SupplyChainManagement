import 'package:flutter/foundation.dart';

class ApiConstants {

  ApiConstants._();

  static String get host {
    if (kIsWeb) {
// Flutter Web
      return 'localhost';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
// Android Emulator
        return '10.0.2.2';

      case TargetPlatform.iOS:
// iOS Simulator
        return 'localhost';

      default:
// Windows / macOS / Linux
        return 'localhost';
    }
  }

  static String get baseUrl => 'http://$host:8085/api/';
  static String get imgUrl => 'http://$host:8085/images/';
  // ── Auth ───────────────────────────────────────────────
  static const String login = 'auth/login';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  static const String verifyEmail = 'auth/verify-email';

  // ── Customer ───────────────────────────────────────────
  static const String customer = 'customer';
  static String customerByUserId(int userId) => 'customer/user/$userId';
  static String customerById(int id) => 'customer/$id';


  static const String procurements = 'procurements';
   static String procurementById(int id) => 'procurements/$id';
  static String procurementByUserId(int userId) => 'procurements/user/$userId';


  // ── Drivers ────────────────────────────────────────────
  static const String drivers = 'drivers';

  static String driverById(int id) => 'drivers/$id';
  static String driverByUserId(int id) => 'drivers/user/$id';


  // ── Managers ───────────────────────────────────────────
  static const String managers = 'managers';

  static String managerById(int id) => 'managers/$id';
  static String managerByUserId(int id) => 'managers/user/$id';



  // ── Suppliers ──────────────────────────────────────────
  static const String suppliers = 'suppliers';

  static String supplierById(int id) => 'suppliers/$id';
  static String supplierByUserId(int id) => 'suppliers/user/$id';

  // ── Shipments (Added for Shipment Controller) ──────────
  static const String shipments = 'shipments';
  static String shipmentById(int id) => 'shipments/$id';

  // ── QC Inspector Endpoints (Mirrors /api/qc-inspectors) ─
  static const String qcInspectors = 'qc-inspectors';
  static String qcInspectorById(int id) => 'qc-inspectors/$id';
  static String qcInspectorByUserId(int userId) => 'qc-inspectors/user/$userId';

  // ── Sales Officer Endpoints ──────────────────────────────
  static const String salesOfficers = 'sales-officers';
  static String salesOfficerById(int id) => 'sales-officers/$id';
  static String salesOfficerByUserId(int userId) => 'sales-officers/user/$userId';


  // ── Address hierarchy ────────────────────────────────────
  static const String country = 'country';
  static String divisionsByCountry(int countryId) =>
      'division/country/$countryId';
  static String districtsByDivision(int divisionId) =>
      'district/division/$divisionId';
  static String policeStationsByDistrict(int districtId) =>
      'policestation/district/$districtId';
  static String policeStationSearch(String keyword) =>
      'policestation/search?keyword=$keyword';


  // Category Endpoints ( @RequestMapping("/api/category") )
  static const String categories = 'category';
  static String categoryById(int id) => 'category/$id';
  static const String publicCategories = 'category/public';

  // ── Warehouse Endpoints (Mirrors /api/warehouse) ────────
  static const String warehouse = 'warehouse';
  static String warehouseById(int id) => 'warehouse/$id';



// ── Customer Orders ────────────────────────────────────
  static const String customerOrders = 'customerOrders';
  static const String createCustomerOrder = 'customerOrders'; // POST
  static const String customerOrdersByEmail = 'customerOrders/customer';
  static const String trackCustomerOrder = 'customerOrders/track'; // queryParam: orderNumber
  static const String verifyPaymentLink = 'customerOrders/verify-link'; // queryParam: orderId, amountPaid, method

  static String customerOrderById(int id) => 'customerOrders/$id';
  static String updateCustomerOrderStatus(int id) => 'customerOrders/$id/status';

  // ── Order Line Items ───────────────────────────────────
  static const String orderItems = 'order-items';

  static String orderItemById(int id) => 'order-items/$id';
  static String orderItemsByOrderId(int orderId) => 'order-items/order/$orderId';


  // ── Delivery Trips ─────────────────────────────────────
  static const String deliveryTrips = 'delivery-trips';

  static String deliveryTripById(int id) => 'delivery-trips/$id';
  static String updateDeliveryTripStatus(int id) => 'delivery-trips/$id/status';


  static const String banks = 'banks';
  static String bankById(int id) => 'banks/$id';


  // ── Letter of Credit (LC) Endpoints (Mirrors /api/lc) ──
  static const String lcs = 'lc';
  static String lcById(int id) => 'lc/$id';
  static String amendLc(int id) => 'lc/amend/$id';


  // ── Invoice Endpoints (Mirrors /api/invoices) ───────────
  static const String invoices = 'invoices';
  static String invoiceById(int id) => 'invoices/$id';


  // ── Purchase Requisitions ──────────────────────────────
  static const String purchaseRequisitions = 'purchase-requisitions';

  static String purchaseRequisitionById(int id) => 'purchase-requisitions/$id';
  static String approvePurchaseRequisition(int id) => 'purchase-requisitions/$id/approve';
  static String rejectOrCancelPurchaseRequisition(int id) => 'purchase-requisitions/$id/reject-or-cancel';


  // ── Quotations ─────────────────────────────────────────
  static const String quotations = 'quotations';

  static String quotationById(int id) => 'quotations/$id';
  static String updateQuotationStatus(int id) => 'quotations/$id/status';


  // ── Purchase Orders ────────────────────────────────────
  static const String purchaseOrders = 'purchase-orders';
  static const String emailIssueOrder = 'purchase-orders/email-issue'; // queryParam: token
  static const String emailReceiveOrder = 'purchase-orders/email-receive'; // queryParam: token

  static String purchaseOrderById(int id) => 'purchase-orders/$id';
  static String purchaseOrdersBySupplier(int supplierId) => 'purchase-orders/supplier/$supplierId';
  static String updatePurchaseOrderStatus(int id) => 'purchase-orders/$id/status';
  static String approvePurchaseOrder(int id) => 'purchase-orders/$id/approve';

// ── Purchase Order Line Items ──────────────────────────
  static const String poLineItems = 'po-line-items';
  static String poLineItemById(int id) => 'po-line-items/$id';
  static String trackPoLineItem(String trackingNumber) => 'po-line-items/track/$trackingNumber';





  // ── Goods Received Notes (GRN) ─────────────────────────
  static const String goodsReceivedNotes = 'goods-received-notes';
  static String goodsReceivedNoteById(int id) => 'goods-received-notes/$id';








  // ── Payment Statements ─────────────────────────────────
  static const String paymentStatements = 'payment-statements';

  static String paymentStatementById(int id) => 'payment-statements/$id';
  static String updatePaymentStatus(int id) => 'payment-statements/$id/status'; // queryParam: status
  static String paymentsByOrderId(int orderId) => 'payment-statements/order/$orderId';
  static String paymentsByOrderNumber(String orderNumber) => 'payment-statements/order-number/$orderNumber';
  static String paymentsByStatus(String status) => 'payment-statements/status/$status';




  // ── QC Inspections & Checklists ────────────────────────
  static const String qcInspections = 'qc-inspections';
  static const String qcChecklists = 'qc-checklists';

  static String qcInspectionById(int id) => 'qc-inspections/$id';

  static String qcChecklistById(int id) => 'qc-checklists/$id';
  static String qcChecklistsByInspectionId(int inspectionId) => 'qc-checklists/inspection/$inspectionId';


// ── Products ───────────────────────────────────────────
  static const String products = 'products';

  static String productById(int id) => 'products/$id';


  // ── Product Requirements ───────────────────────────────
  static const String productRequirements = 'product-requirements';

  static String productRequirementById(int id) => 'product-requirements/$id';
  static String updateProductRequirementStatus(int id) => 'product-requirements/$id/status';


  // ── Vehicles ───────────────────────────────────────────
  static const String vehicles = 'vehicles';
  static String vehicleById(int id) => 'vehicles/$id';


  // ── Inventory Endpoints ────────────────────────────────
  static const String inventories = 'inventories';
  static String inventoryById(int id) => 'inventories/$id';

  // ── Reports Endpoints ──────────────────────────────────
  static const String reports = 'reports';
  static String reportById(int id) => 'reports/$id';
  static String reportsByWarehouse(String warehouseId) => 'reports/warehouse/$warehouseId';
  static String approveReport(int id) => 'reports/approve/$id';
  static const String emailApproveReport = 'reports/email-approve';
  static String reportUploads(String filename) => 'reports/uploads/reports/$filename';

  // ── GRN Line Items Endpoints ─────────────────────────────
  static const String grnLineItems = 'grn-line-items';
  static String grnLineItemById(int id) => 'grn-line-items/$id';


  // ── Stock Movements Endpoints ───────────────────────────
  static const String stockMovements = 'stock-movements';
  static String stockMovementById(int id) => 'stock-movements/$id';

///Massage
  static const String messages = 'messages';
  static const String messageInbox = 'messages/inbox';
  static const String messageChatlist = 'messages/chatlist';
  static const String messageHistory = 'messages/history';
  static String messageRead(int id) => 'messages/$id/read';

  ///Notification
  static const String notifications = 'notifications';
  static const String notificationUnreadCount = 'notifications/unread-count';
  static const String notificationReadAll = 'notifications/read-all';
  static String notificationRead(int id) => 'notifications/$id/read';




}