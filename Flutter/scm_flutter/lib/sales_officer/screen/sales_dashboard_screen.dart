import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/commercial_officer/provider/invoice_provider.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart' hide customerOrderRepositoryProvider;
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/cutomer/screen/customer_register_screen.dart';
import 'package:scm_flutter/entity/customerModel.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/invoiceModel.dart';
import 'package:scm_flutter/entity/catagory_model.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/product/provider/catagory_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/sales_officer/provider/sales_officer_provider.dart';
import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class SalesDashboardScreen extends ConsumerStatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  ConsumerState<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends ConsumerState<SalesDashboardScreen> {
  // Search & Filter state for Customer Order Log Table
  final TextEditingController _orderSearchController = TextEditingController();
  String _orderSearchText = '';
  final String _orderSearchDate = '';

  // Overview Filters
  int _selectedOverviewMonth = DateTime.now().month - 1;
  int _selectedOverviewYear = DateTime.now().year;

  final double monthlyTarget = 10000000.0; // 10 Million Goal

  final List<String> availableStatuses = [
    'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 
    'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'RETURNED', 'REFUNDED'
  ];

  final List<Map<String, dynamic>> monthsList = [
    {'value': -1, 'label': 'All Months'},
    {'value': 0, 'label': 'January'},
    {'value': 1, 'label': 'February'},
    {'value': 2, 'label': 'March'},
    {'value': 3, 'label': 'April'},
    {'value': 4, 'label': 'May'},
    {'value': 5, 'label': 'June'},
    {'value': 6, 'label': 'July'},
    {'value': 7, 'label': 'August'},
    {'value': 8, 'label': 'September'},
    {'value': 9, 'label': 'October'},
    {'value': 10, 'label': 'November'},
    {'value': 11, 'label': 'December'},
  ];

  @override
  void dispose() {
    _orderSearchController.dispose();
    super.dispose();
  }

  String _formatNumber(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return NumberFormat('#,##0.00').format(value);
    }
  }

  Color _getStageBadgeColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'DELIVERED':
      case 'CONFIRMED':
      case 'PAID':
        return AppTheme.success;
      case 'PENDING':
      case 'UNDER_REVIEW':
      case 'PARTIALLY_PAID':
        return AppTheme.warning;
      case 'PROCESSING':
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
        return AppTheme.primary;
      case 'REJECTED':
      case 'CANCELLED':
      case 'UNPAID':
        return AppTheme.danger;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getStageBadgeBg(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'DELIVERED':
      case 'CONFIRMED':
      case 'PAID':
        return AppTheme.successLight;
      case 'PENDING':
      case 'UNDER_REVIEW':
      case 'PARTIALLY_PAID':
        return AppTheme.warningLight;
      case 'PROCESSING':
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
        return AppTheme.blueLight;
      case 'REJECTED':
      case 'CANCELLED':
      case 'UNPAID':
        return AppTheme.dangerLight;
      default:
        return AppTheme.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final ordersAsync = ref.watch(customerOrderListProvider);
    final quotationsAsync = ref.watch(quotationListProvider);
    final invoicesAsync = ref.watch(invoiceListProvider);
    final notificationsAsync = ref.watch(notificationListProvider);
    final customersAsync = ref.watch(customerListProvider);
    final shipmentsAsync = ref.watch(shipmentListProvider);
    final productsAsync = ref.watch(productListProvider);
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);

    final orders = ordersAsync.value ?? [];
    final quotations = quotationsAsync.value ?? [];
    final invoices = invoicesAsync.value ?? [];
    final notifications = notificationsAsync.value ?? [];
    final customers = customersAsync.value ?? [];
    final shipments = shipmentsAsync.value ?? [];
    final products = productsAsync.value ?? [];
    final purchaseOrders = purchaseOrdersAsync.value ?? [];
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories = categoriesAsync.value ?? [];

    // --- Dynamic KPI Calculations ---
    final double totalRevenue = invoices
        .where((inv) => inv.invoiceStatus == 'ISSUED' || inv.invoiceStatus == 'PAID')
        .fold(0.0, (sum, inv) => sum + inv.totalAmount);

    final String todayStr = DateTime.now().toString().split(' ')[0];
    final todaysList = orders.where((o) => o.createdAt.startsWith(todayStr)).toList();
    final int todaysOrders = todaysList.length;
    final double todaysSales = todaysList.fold(0.0, (sum, o) => sum + (o.totalAmount > 0 ? o.totalAmount : o.codAmount));

    final int activeQuotations = quotations
        .where((q) => q.status.toUpperCase() == 'PENDING' || q.status.toUpperCase() == 'UNDER_REVIEW')
        .length;

    final int pendingDeliveries = orders
        .where((o) => o.status.toUpperCase() == 'PROCESSING' || o.status.toUpperCase() == 'SHIPPED')
        .length;

    final double outstandingPayments = invoices
        .where((inv) => inv.invoiceStatus == 'ISSUED' || inv.invoiceStatus == 'OVERDUE')
        .fold(0.0, (sum, inv) => sum + inv.totalAmount);

    final double targetProgress = ((totalRevenue / monthlyTarget) * 100).clamp(0.0, 100.0);

    // Filtered Dashboard Orders (Only PENDING orders)
    final filteredDashboardOrders = orders.where((o) {
      bool matchesStatus = o.status.toUpperCase() == 'PENDING';
      bool matchesSearch = _orderSearchText.isEmpty ||
          (o.orderNumber.toLowerCase().contains(_orderSearchText.toLowerCase())) ||
          (o.customerName.toLowerCase().contains(_orderSearchText.toLowerCase())) ||
          (o.paymentStatus.toLowerCase().contains(_orderSearchText.toLowerCase())) ||
          (o.status.toLowerCase().contains(_orderSearchText.toLowerCase()));
      bool matchesDate = _orderSearchDate.isEmpty || o.createdAt.startsWith(_orderSearchDate);
      return matchesStatus && matchesSearch && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: DynamicScmTopNavBar(
        onRefresh: () {
          ref.invalidate(customerOrderListProvider);
          ref.invalidate(quotationListProvider);
          ref.invalidate(invoiceListProvider);
          ref.invalidate(notificationListProvider);
          ref.invalidate(customerListProvider);
          ref.invalidate(shipmentListProvider);
          ref.invalidate(productListProvider);
          ref.invalidate(purchaseOrderListProvider);
          ref.invalidate(currentSalesOfficerProvider);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(customerOrderListProvider);
            ref.invalidate(quotationListProvider);
            ref.invalidate(invoiceListProvider);
            ref.invalidate(notificationListProvider);
            ref.invalidate(customerListProvider);
            ref.invalidate(shipmentListProvider);
            ref.invalidate(productListProvider);
            ref.invalidate(purchaseOrderListProvider);
            ref.invalidate(currentSalesOfficerProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Header Bar ──────────────────────────────────────────
                _buildHeaderBar(context, user?.name ?? 'Sales Officer'),
                const SizedBox(height: 16),

                // ── 2. Top 6 KPI Cards Grid ────────────────────────────────────
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    _buildKpiCard('TOTAL REVENUE', '৳${_formatNumber(totalRevenue)}', 'Issued invoice revenue', '+12% vs last month', Icons.account_balance_wallet_outlined, AppTheme.success, AppTheme.successLight),
                    _buildKpiCard("TODAY'S SALES", '৳${_formatNumber(todaysSales)}', 'Sales collected today', '+8% vs yesterday', Icons.attach_money, AppTheme.primary, AppTheme.blueLight),
                    _buildKpiCard("TODAY'S ORDERS", '$todaysOrders', 'Orders placed today', '+14% vs yesterday', Icons.shopping_bag_outlined, AppTheme.indigo, AppTheme.purpleLight),
                    _buildKpiCard('ACTIVE QUOTATIONS', '$activeQuotations', 'Quotations in pipeline', '$activeQuotations active now', Icons.description_outlined, AppTheme.warning, AppTheme.warningLight),
                    _buildKpiCard('PENDING DELIVERIES', '$pendingDeliveries', 'Deliveries in progress', '$pendingDeliveries in progress', Icons.local_shipping_outlined, AppTheme.info, AppTheme.infoLight),
                    _buildKpiCard('OUTSTANDING PAYMENTS', '৳${_formatNumber(outstandingPayments)}', 'Total outstanding', '${invoices.where((i) => i.invoiceStatus == 'ISSUED').length} invoices', Icons.credit_card, AppTheme.danger, AppTheme.dangerLight),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 3. Quick Actions Section ───────────────────────────────────
                _buildQuickActionsGrid(context, orders, quotations, invoices, customers, purchaseOrders, categories),
                const SizedBox(height: 20),

                // ── 4. Customer Order Log Table (Full Width) ───────────────────
                _buildCustomerOrderLogCard(context, filteredDashboardOrders),
                const SizedBox(height: 20),

                // ── 5. Sales Overview & Monthly Target Row ─────────────────────
                _buildOverviewAndTargetRow(context, orders, totalRevenue, targetProgress),
                const SizedBox(height: 20),

                // ── 6. Top Product Sales & Pending Tasks Row ───────────────────
                _buildProductsAndTasksRow(context, products, activeQuotations, orders, pendingDeliveries, invoices),
                const SizedBox(height: 20),

                // ── 7. Recent Quotations & Top Customers Row ───────────────────
                _buildQuotationsAndCustomersRow(context, quotations, orders, customers),
                const SizedBox(height: 20),

                // ── 8. Footer Cards: Pipeline, Shipments, Notifications ───────
                _buildFooterCardsRow(context, quotations, orders, shipments, notifications),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header Bar ─────────────────────────────────────────────────────────────
  Widget _buildHeaderBar(BuildContext context, String officerName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.dark, AppTheme.indigoDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Welcome back, $officerName ',
                        style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text('👋', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Sales Officer', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.success),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: AppTheme.success, size: 6),
                          SizedBox(width: 4),
                          Text('LIVE', style: TextStyle(color: AppTheme.success, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: const [
              DynamicNotificationButton(),
            ],
          ),
        ],
      ),
    );
  }

  // ── KPI Card Builder ───────────────────────────────────────────────────────
  Widget _buildKpiCard(String title, String value, String subtitle, String trend, IconData icon, Color iconColor, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          Text(subtitle, style: const TextStyle(fontSize: 8, color: AppTheme.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 10, color: iconColor),
              const SizedBox(width: 2),
              Text(trend, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: iconColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Grid ─────────────────────────────────────────────────────
  Widget _buildQuickActionsGrid(
    BuildContext context,
    List<CustomerOrderResponse> orders,
    List<QuotationResponseModel> quotations,
    List<InvoiceResponseModel> invoices,
    List<CustomerResponseModel> customers,
    List<PurchaseOrderResponse> purchaseOrders,
    List<CategoryResponseModel> categories,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt, color: AppTheme.warning, size: 18),
              SizedBox(width: 6),
              Text('QUICK ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: [
              _quickActionTile(context, 'Issue Quotation', 'Approved quotes...', Icons.add, AppTheme.success, AppTheme.successLight, () => Navigator.pushNamed(context, '/quotations', arguments: 'APPROVED')),
              _quickActionTile(context, 'View Purchase', 'Received POs...', Icons.shopping_cart_outlined, AppTheme.primary, AppTheme.blueLight, () => Navigator.pushNamed(context, '/purchase-orders', arguments: 'RECEIVED')),
              _quickActionTile(context, 'Add Customer', 'Register new...', Icons.person_add_outlined, AppTheme.info, AppTheme.infoLight, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRegisterScreen()))),
              _quickActionTile(context, 'Sales Invoicing', 'Record payment...', Icons.receipt_long_outlined, AppTheme.warning, AppTheme.warningLight, () => Navigator.pushNamed(context, '/add-payment')),
              _quickActionTile(context, 'Customer Orders', 'View & audit...', Icons.inventory_2_outlined, AppTheme.danger, AppTheme.dangerLight, () => Navigator.pushNamed(context, '/customer-orders')),
              _quickActionTile(context, 'Commercial Invoice', 'Audit billing...', Icons.description, AppTheme.primary, AppTheme.blueLight, () => Navigator.pushNamed(context, '/commercial-invoice-data')),
              _quickActionTile(context, 'Add Category', 'Create category...', Icons.category_outlined, AppTheme.tealPrimary, AppTheme.tealBackground, () => Navigator.pushNamed(context, '/category-form')),
              _quickActionTile(context, 'Add Product', 'Create product...', Icons.add_box_outlined, AppTheme.indigo, AppTheme.purpleLight, () => Navigator.pushNamed(context, '/product-form')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, Color bg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppTheme.white, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: const TextStyle(fontSize: 8, color: AppTheme.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.grey),
          ],
        ),
      ),
    );
  }

  // ── Customer Order Log Table Card (Full Width) ─────────────────────────────
  Widget _buildCustomerOrderLogCard(BuildContext context, List<CustomerOrderResponse> orders) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: const Border(top: BorderSide(color: AppTheme.success, width: 4)),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                        SizedBox(width: 6),
                        Text('CUSTOMER ORDER LOG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search and Filters Bar
                TextField(
                  controller: _orderSearchController,
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'Search pending orders...',
                    prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.grey),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                  ),
                  onChanged: (val) => setState(() => _orderSearchText = val.trim()),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderGrey),

          // Orders Data Table
          orders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No matching customer orders found.', style: TextStyle(fontSize: 11, color: AppTheme.grey))),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 14,
                    horizontalMargin: 14,
                    headingRowHeight: 36,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 52,
                    headingRowColor: WidgetStateProperty.all(AppTheme.light),
                    columns: const [
                      DataColumn(label: Text('ORDER NO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey))),
                      DataColumn(label: Text('CUSTOMER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey))),
                      DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey))),
                      DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey))),
                      DataColumn(label: Text('PAYMENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey))),
                      DataColumn(label: Text('DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey))),
                      DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey))),
                    ],
                    rows: orders.take(10).map((o) {
                      final amount = o.totalAmount > 0 ? o.totalAmount : o.codAmount;
                      return DataRow(cells: [
                        DataCell(Text(o.orderNumber.isNotEmpty ? o.orderNumber : 'SO-${o.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(o.customerName.isNotEmpty ? o.customerName : 'Customer', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                            if (o.customerEmail.isNotEmpty) Text(o.customerEmail, style: const TextStyle(fontSize: 8, color: AppTheme.grey)),
                          ],
                        )),
                        DataCell(Text('৳${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _getStageBadgeBg(o.status), borderRadius: BorderRadius.circular(12)),
                          child: Text(o.status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _getStageBadgeColor(o.status))),
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: _getStageBadgeBg(o.paymentStatus), borderRadius: BorderRadius.circular(4)),
                          child: Text(o.paymentStatus, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _getStageBadgeColor(o.paymentStatus))),
                        )),
                        DataCell(Text(o.createdAt.length >= 10 ? o.createdAt.substring(0, 10) : o.createdAt, style: const TextStyle(fontSize: 9, color: AppTheme.grey))),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.shield_outlined, color: AppTheme.success, size: 18),
                            tooltip: 'Update Status',
                            onPressed: () => _openOrderStatusUpdateDialog(context, o),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Overview & Monthly Target Row ──────────────────────────────────────────
  Widget _buildOverviewAndTargetRow(BuildContext context, List<CustomerOrderResponse> orders, double totalRevenue, double targetProgress) {
    final shortMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final selectedIdx = _selectedOverviewMonth >= 0 ? _selectedOverviewMonth : DateTime.now().month - 1;
    
    List<double> monthlyValues = [];
    List<String> monthlyLabels = [];
    for (int i = 5; i >= 0; i--) {
      int monthIdx = (selectedIdx - i) % 12;
      if (monthIdx < 0) monthIdx += 12;
      final mStr = (monthIdx + 1).toString().padLeft(2, '0');
      final monthOrders = orders.where((o) => o.createdAt.contains('-$mStr-')).toList();
      double total = monthOrders.fold(0.0, (sum, o) => sum + (o.totalAmount > 0 ? o.totalAmount : o.codAmount));
      monthlyValues.add(total);
      monthlyLabels.add(shortMonths[monthIdx]);
    }
    double maxVal = monthlyValues.fold(0.0, (max, v) => v > max ? v : max);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Overview Card
            Expanded(
              flex: isMobile ? 0 : 6,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SALES OVERVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                        Row(
                          children: [
                            DropdownButton<int>(
                              value: _selectedOverviewMonth,
                              isDense: true,
                              underline: const SizedBox(),
                              style: const TextStyle(fontSize: 10, color: AppTheme.dark, fontWeight: FontWeight.bold),
                              items: monthsList.map((m) => DropdownMenuItem<int>(
                                value: m['value'] as int,
                                child: Text(m['label'] as String),
                              )).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedOverviewMonth = val);
                              },
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: _selectedOverviewYear,
                              isDense: true,
                              underline: const SizedBox(),
                              style: const TextStyle(fontSize: 10, color: AppTheme.dark, fontWeight: FontWeight.bold),
                              items: [2026, 2025, 2024].map((y) => DropdownMenuItem<int>(
                                value: y,
                                child: Text('$y'),
                              )).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedOverviewYear = val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.circle, size: 8, color: AppTheme.primary),
                        SizedBox(width: 4),
                        Text('Revenue', style: TextStyle(fontSize: 9, color: AppTheme.grey)),
                        SizedBox(width: 12),
                        Icon(Icons.circle, size: 8, color: AppTheme.success),
                        SizedBox(width: 4),
                        Text('Orders', style: TextStyle(fontSize: 9, color: AppTheme.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Visual Graph Container
                    Container(
                      height: 130,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppTheme.borderGrey), left: BorderSide(color: AppTheme.borderGrey)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(6, (i) {
                          double val = monthlyValues[i];
                          double heightFactor = maxVal > 0 ? (val / maxVal).clamp(0.15, 1.0) : (i % 2 == 0 ? 0.3 : 0.5);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 14,
                                height: 80 * heightFactor,
                                decoration: BoxDecoration(
                                  color: i % 2 == 0 ? AppTheme.primary : AppTheme.success,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(monthlyLabels[i], style: const TextStyle(fontSize: 8, color: AppTheme.grey)),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),

            // Monthly Target Card
            Expanded(
              flex: isMobile ? 0 : 5,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.center_focus_strong, color: AppTheme.success, size: 18),
                        SizedBox(width: 6),
                        Text('MONTHLY TARGET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: targetProgress / 100,
                              strokeWidth: 8,
                              backgroundColor: AppTheme.light,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${targetProgress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                              const Text('Achieved', style: TextStyle(fontSize: 8, color: AppTheme.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target Goal', style: TextStyle(fontSize: 8, color: AppTheme.grey)),
                            Text('৳${_formatNumber(monthlyTarget)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Achieved', style: TextStyle(fontSize: 8, color: AppTheme.grey)),
                            Text('৳${_formatNumber(totalRevenue)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Remaining', style: TextStyle(fontSize: 8, color: AppTheme.grey)),
                            Text('৳${_formatNumber(monthlyTarget - totalRevenue > 0 ? monthlyTarget - totalRevenue : 0)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.danger)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _openTargetBreakdownModal(context, totalRevenue, targetProgress),
                        child: const Text('View Details >', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Top Products & Pending Tasks Row ───────────────────────────────────────
  Widget _buildProductsAndTasksRow(
    BuildContext context,
    List<ProductResponseModel> products,
    int activeQuotations,
    List<CustomerOrderResponse> orders,
    int pendingDeliveries,
    List<InvoiceResponseModel> invoices,
  ) {
    final pendingOrdersCount = orders.where((o) => o.status == 'PENDING').length;
    final unpaidInvoicesCount = invoices.where((i) => i.invoiceStatus == 'ISSUED').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Product Sales
            Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('TOP PRODUCT SALES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                        Text('This Month', style: TextStyle(fontSize: 9, color: AppTheme.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    products.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('No product sales recorded yet.', style: TextStyle(fontSize: 10, color: AppTheme.grey))),
                          )
                        : Column(
                            children: products.take(4).map((p) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 8, color: AppTheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(p.name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.dark), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    Text('৳${p.sellingPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),

            // Pending Tasks
            Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PENDING TASKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                    const SizedBox(height: 12),
                    _taskRowTile('Pending Quotations', activeQuotations, Icons.description_outlined, AppTheme.danger, AppTheme.dangerLight),
                    const SizedBox(height: 6),
                    _taskRowTile('Pending Sales Orders', pendingOrdersCount, Icons.shopping_cart_outlined, AppTheme.warning, AppTheme.warningLight),
                    const SizedBox(height: 6),
                    _taskRowTile('Deliveries In Progress', pendingDeliveries, Icons.local_shipping_outlined, AppTheme.primary, AppTheme.blueLight),
                    const SizedBox(height: 6),
                    _taskRowTile('Invoices Pending', unpaidInvoicesCount, Icons.receipt_long_outlined, AppTheme.success, AppTheme.successLight),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _taskRowTile(String title, int count, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.light, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  // ── Recent Quotations & Top Customers Row ──────────────────────────────────
  Widget _buildQuotationsAndCustomersRow(
    BuildContext context,
    List<QuotationResponseModel> quotations,
    List<CustomerOrderResponse> orders,
    List<CustomerResponseModel> customers,
  ) {
    final approvedQuotations = quotations.where((q) => q.status.toUpperCase() == 'APPROVED').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Quotations
            Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('RECENT QUOTATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                        InkWell(
                          onTap: () => _openQuotationsModal(context, quotations),
                          child: const Text('View all >', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    approvedQuotations.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text('No approved quotations found.', style: TextStyle(fontSize: 10, color: AppTheme.grey))),
                          )
                        : Column(
                            children: approvedQuotations.take(4).map((q) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(q.quotationNumber.isNotEmpty ? q.quotationNumber : 'QTN-${q.id}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                        Text(q.supplierName.isNotEmpty ? q.supplierName : 'Supplier', style: const TextStyle(fontSize: 8, color: AppTheme.grey)),
                                      ],
                                    ),
                                    Text('৳${q.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppTheme.successLight, borderRadius: BorderRadius.circular(4)),
                                      child: Text(q.status, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.success)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),

            // Top Customers
            Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOP CUSTOMERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                        InkWell(
                          onTap: () => _openCustomerDirectoryModal(context, customers),
                          child: const Text('View all >', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    customers.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text('No customers found.', style: TextStyle(fontSize: 10, color: AppTheme.grey))),
                          )
                        : Column(
                            children: customers.take(4).map((c) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                                        Text(c.email, style: const TextStyle(fontSize: 8, color: AppTheme.grey)),
                                      ],
                                    ),
                                    const Text('Active Client', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.success)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Footer Cards Row ───────────────────────────────────────────────────────
  Widget _buildFooterCardsRow(
    BuildContext context,
    List<QuotationResponseModel> quotations,
    List<CustomerOrderResponse> orders,
    List<ShipmentResponseModel> shipments,
    List<dynamic> notifications,
  ) {
    final int leadsCount = quotations.length;
    final int quoteCount = quotations.where((q) => q.status.toUpperCase() == 'PENDING').length;
    final int negCount = quotations.where((q) => q.status.toUpperCase() == 'UNDER_REVIEW').length;
    final int orderCount = orders.length;
    final int deliveredCount = orders.where((o) => o.status.toUpperCase() == 'DELIVERED').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Pipeline Card
            Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SALES PIPELINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _pipelineStepChip('Lead', '$leadsCount', AppTheme.successLight, AppTheme.success),
                        _pipelineStepChip('Quote', '$quoteCount', AppTheme.blueLight, AppTheme.primary),
                        _pipelineStepChip('Review', '$negCount', AppTheme.purpleLight, AppTheme.indigo),
                        _pipelineStepChip('Order', '$orderCount', AppTheme.warningLight, AppTheme.warning),
                        _pipelineStepChip('Delivered', '$deliveredCount', AppTheme.infoLight, AppTheme.info),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),

            // Shipment Information Card
            Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SHIPMENT INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                        InkWell(
                          onTap: () => _openShipmentsModal(context, shipments),
                          child: const Text('View all >', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    shipments.isEmpty
                        ? const Text('No shipments dispatched.', style: TextStyle(fontSize: 10, color: AppTheme.grey))
                        : Column(
                            children: shipments.take(2).map((s) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(s.shipmentNumber.isNotEmpty ? s.shipmentNumber : 'SH-${s.id}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                    Text(s.vehicleNumber.isNotEmpty ? s.vehicleNumber : 'Truck', style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    Text(s.estimatedDelivery.length >= 10 ? s.estimatedDelivery.substring(0, 10) : 'Pending', style: const TextStyle(fontSize: 9, color: AppTheme.dark)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pipelineStepChip(String label, String count, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
        ],
      ),
    );
  }

  // ===========================================================================
  // ── MODALS / DIALOGS IMPLEMENTATION ─────────────────────────────────────────
  // ===========================================================================



  // 1. Order Lifecycle Status Update Dialog
  void _openOrderStatusUpdateDialog(BuildContext context, CustomerOrderResponse order) {
    final user = ref.read(currentUserProvider);
    final userRole = user?.role.toUpperCase() ?? '';
    final canUpdateStatus = ['SALES_OFFICER', 'ROLE_SALES_OFFICER', 'SALES', 'MANAGER', 'ROLE_MANAGER', 'ADMIN', 'ROLE_ADMIN'].contains(userRole);
    if (!canUpdateStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied: Only Sales Officers, Managers, and Admins can update order status.'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    String selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Update Order Lifecycle Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target Order: ${order.orderNumber.isNotEmpty ? order.orderNumber : "SO-${order.id}"}', style: const TextStyle(fontSize: 11, color: AppTheme.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  items: availableStatuses.map((st) => DropdownMenuItem(
                    value: st,
                    child: Text(st, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStatus = val);
                  },
                ),
                const SizedBox(height: 8),
                const Text('This will instantly update the status on backend datastore.', style: TextStyle(fontSize: 9, color: AppTheme.grey)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    final repo = ref.read(customerOrderRepositoryProvider);
                    await repo.updateOrderStatus(order.id, selectedStatus);
                    ref.invalidate(customerOrderListProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order status updated successfully!'), backgroundColor: AppTheme.success),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating status: $e'), backgroundColor: AppTheme.danger),
                      );
                    }
                  }
                },
                child: const Text('Save Status', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }



  // 4. View All Quotations Modal
  void _openQuotationsModal(BuildContext context, List<QuotationResponseModel> quotations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Approved Quotations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: quotations.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final q = quotations[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(q.quotationNumber.isNotEmpty ? q.quotationNumber : 'QTN-${q.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    subtitle: Text('${q.supplierName} • ${q.status}', style: const TextStyle(fontSize: 10, color: AppTheme.grey)),
                    trailing: Text('৳${q.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  // 8. Customer Directory Modal
  void _openCustomerDirectoryModal(BuildContext context, List<CustomerResponseModel> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Customer Directory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = customers[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: AppTheme.blueLight, child: Icon(Icons.person, color: AppTheme.primary, size: 18)),
                    title: Text(c.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                    subtitle: Text('${c.email} • ${c.phone}', style: const TextStyle(fontSize: 10, color: AppTheme.grey)),
                    trailing: Text('ID: ${c.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 9. View Shipments Modal
  void _openShipmentsModal(BuildContext context, List<ShipmentResponseModel> shipments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Shipment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: shipments.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = shipments[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_shipping_outlined, color: AppTheme.primary),
                    title: Text(s.shipmentNumber.isNotEmpty ? s.shipmentNumber : 'SH-${s.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    subtitle: Text('Vehicle: ${s.vehicleNumber} • ETA: ${s.estimatedDelivery}', style: const TextStyle(fontSize: 10, color: AppTheme.grey)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 10. Target Breakdown Modal
  void _openTargetBreakdownModal(BuildContext context, double totalRevenue, double targetProgress) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly Sales Target Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Goal: ৳${_formatNumber(monthlyTarget)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
            const SizedBox(height: 6),
            Text('Achieved Revenue: ৳${_formatNumber(totalRevenue)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success)),
            const SizedBox(height: 6),
            Text('Remaining Goal: ৳${_formatNumber(monthlyTarget - totalRevenue > 0 ? monthlyTarget - totalRevenue : 0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.danger)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: targetProgress / 100,
              backgroundColor: AppTheme.light,
              color: AppTheme.success,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text('Completion Rate: ${targetProgress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}