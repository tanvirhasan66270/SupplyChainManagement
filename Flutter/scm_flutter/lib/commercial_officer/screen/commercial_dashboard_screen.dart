import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/commercial_officer/provider/invoice_provider.dart';
import 'package:scm_flutter/commercial_officer/provider/lc_bank_provider.dart';
import 'package:scm_flutter/commercial_officer/provider/letter_of_credit_provider.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/invoiceModel.dart';
import 'package:scm_flutter/entity/lc_bank.dart';
import 'package:scm_flutter/entity/letter_of_cradit_model.dart';
import 'package:scm_flutter/entity/po_line_item_model.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/suppplier/provider/po_line_item_provider.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/commercial_officer/screen/letter_of_credit_form_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/letter_of_credit_data_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/commercial_invoice_data_screen.dart';
import 'package:scm_flutter/cutomer/screen/customer_order_data_screen.dart';
import 'package:scm_flutter/procourment/screen/shipment_data_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/customer_payment_data_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class CommercialDashboardScreen extends ConsumerStatefulWidget {
  const CommercialDashboardScreen({super.key});

  @override
  ConsumerState<CommercialDashboardScreen> createState() => _CommercialDashboardScreenState();
}

class _CommercialDashboardScreenState extends ConsumerState<CommercialDashboardScreen> {
  String lcSearchTerm = '';
  String customerOrderMasterSearchTerm = '';
  String invoiceMasterSearchTerm = '';
  String shipmentMasterSearchTerm = '';
  String lcRegistrySearchTerm = '';
  String lineItemsSearchTerm = '';

  // Form State for Adding New LC
  int _selectedPoId = 0;
  int _selectedSupplierId = 0;
  int _selectedBankId = 0;
  String _selectedIncoTerms = 'FOB';
  String _selectedCurrency = 'USD';
  String _selectedLcStatus = 'OPENED';
  double _contractAmount = 0.0;
  String _portOfLoading = '';
  String _portOfDischarge = '';
  DateTime? _latestShipmentDate;
  DateTime? _expiryDate;
  File? _selectedLcFile;

  bool _isLcFormLoading = false;
  String? _lcFormSuccessMessage;
  String? _lcFormErrorMessage;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final lcsAsync = ref.watch(letterOfCreditListProvider);
    final invoicesAsync = ref.watch(invoiceListProvider);
    final shipmentsAsync = ref.watch(shipmentListProvider);
    final banksAsync = ref.watch(lcBankListProvider);
    final lineItemsAsync = ref.watch(poLineItemListProvider);
    final customerOrdersAsync = ref.watch(customerOrderListProvider);
    final notificationsAsync = ref.watch(notificationListProvider);

    final userName = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Commercial Officer';
    final lcs = lcsAsync.value ?? [];
    final invoices = invoicesAsync.value ?? [];
    final shipments = shipmentsAsync.value ?? [];
    final banks = banksAsync.value ?? [];
    final lineItems = lineItemsAsync.value ?? [];
    final customerOrders = customerOrdersAsync.value ?? [];
    final notifications = notificationsAsync.value ?? [];

    // Filter Active LCs
    final activeLCs = lcs.where((lc) => lc.lcStatus != 'CANCELLED').toList();
    final totalLCValue = activeLCs.fold<double>(0.0, (sum, lc) => sum + lc.amount);
    final totalLCValueBDT = activeLCs
        .where((lc) => lc.currency.isEmpty || lc.currency.toUpperCase() == 'BDT' || lc.currency.toUpperCase() == 'TAKA')
        .fold<double>(0.0, (sum, lc) => sum + lc.amount);
    final totalLCValueUSD = activeLCs
        .where((lc) => lc.currency.toUpperCase() == 'USD')
        .fold<double>(0.0, (sum, lc) => sum + lc.amount);

    // Filter Pending Customs
    final pendingCustoms = shipments.where((s) => s.customPoNumber == 'PENDING' || s.customPoNumber == 'CUSTOMS').length;

    // Filter Paid Amount across Invoices
    final totalPaidBDT = invoices.fold<double>(0.0, (sum, inv) => sum + inv.paidAmount);

    // Documents Vault List
    final List<Map<String, String>> documents = [];
    for (var lc in lcs) {
      if (lc.documentVaultUrl.isNotEmpty) {
        documents.add({
          'name': 'LC Document - ${lc.lcNumber}',
          'type': 'Letter of Credit',
          'date': lc.createdAt.isNotEmpty ? lc.createdAt.split('T').first : 'N/A',
          'status': lc.lcStatus == 'OPENED' ? 'Approved' : 'Pending Review',
          'url': lc.documentVaultUrl,
        });
      }
    }
    for (var s in shipments) {
      if (s.podFileUrl.isNotEmpty) {
        documents.add({
          'name': 'POD - ${s.shipmentNumber}',
          'type': 'Shipment',
          'date': s.createdAt.isNotEmpty ? s.createdAt.split('T').first : 'N/A',
          'status': 'Approved',
          'url': s.podFileUrl,
        });
      }
    }
    final approvedDocsCount = documents.where((d) => d['status'] == 'Approved').length;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(letterOfCreditListProvider);
            ref.invalidate(invoiceListProvider);
            ref.invalidate(shipmentListProvider);
            ref.invalidate(lcBankListProvider);
            ref.invalidate(poLineItemListProvider);
            ref.invalidate(customerOrderListProvider);
            ref.invalidate(notificationListProvider);
            ref.invalidate(purchaseOrderListProvider);
            ref.invalidate(supplierListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Header (Dynamic Navigation Bar) ─────────
                DynamicScmTopNavBar(
                  onRefresh: () {
                    ref.invalidate(letterOfCreditListProvider);
                    ref.invalidate(invoiceListProvider);
                    ref.invalidate(shipmentListProvider);
                    ref.invalidate(lcBankListProvider);
                    ref.invalidate(poLineItemListProvider);
                    ref.invalidate(customerOrderListProvider);
                    ref.invalidate(notificationListProvider);
                  },
                ),

                Padding(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2. Welcome Banner (Procurement Styled Gradient)
                      _buildWelcomeBanner(userName),
                      const SizedBox(height: 20),

                      // ── 3. KPI Stats Grid (4 Cards Responsive) ──────────────────
                      _buildKpiStatsGrid(context, activeLCs.length, totalPaidBDT, totalLCValueUSD, approvedDocsCount),
                      const SizedBox(height: 24),

                      // ── 4. Commercial Quick Actions & Tools (6 Nodes) ──
                      _buildQuickActionsCard(context),
                      const SizedBox(height: 24),

                      // ── 5. LC Registry & Shipping Documents Manifest Vault
                      if (isMobile) ...[
                        _buildLcRegistryCard(activeLCs),
                        const SizedBox(height: 16),
                        _buildShippingDocsCard(documents),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: _buildLcRegistryCard(activeLCs)),
                            const SizedBox(width: 16),
                            Expanded(flex: 5, child: _buildShippingDocsCard(documents)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── 6. Commercial Invoices Ledger & Cargo Consignments
                      if (isMobile) ...[
                        _buildInvoicesLedgerCard(invoices),
                        const SizedBox(height: 16),
                        _buildConsignmentsCard(shipments),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildInvoicesLedgerCard(invoices)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildConsignmentsCard(shipments)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── 7. Customer Payment Verification & PO Line Items Matrix
                      if (isMobile) ...[
                        _buildPaymentVerificationCard(customerOrders),
                        const SizedBox(height: 16),
                        _buildPoLineItemsCard(lineItems),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPaymentVerificationCard(customerOrders)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPoLineItemsCard(lineItems)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── 8. Commercial Parameters & Quotas ─────────────
                      if (isMobile) ...[
                        _buildCapitalQuotasCard(totalLCValueBDT, totalLCValueUSD, totalLCValue),
                        const SizedBox(height: 16),
                        _buildDocComplianceCard(approvedDocsCount, pendingCustoms),
                        const SizedBox(height: 16),
                        _buildShipmentVectorsCard(),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCapitalQuotasCard(totalLCValueBDT, totalLCValueUSD, totalLCValue)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDocComplianceCard(approvedDocsCount, pendingCustoms)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildShipmentVectorsCard()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── 9. SWIFT Banking Terminals & Tariff Matrix ────
                      if (isMobile) ...[
                        _buildSwiftBanksCard(banks),
                        const SizedBox(height: 16),
                        _buildTariffMatrixCard(),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _buildSwiftBanksCard(banks)),
                            const SizedBox(width: 16),
                            Expanded(flex: 5, child: _buildTariffMatrixCard()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── 10. Commercial Notifications & System Audit Log
                      _buildNotificationsSection(notifications),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ── WELCOME BANNER (Procurement Styled Gradient) ─────────────────────
  Widget _buildWelcomeBanner(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, $userName 👋', style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Commercial Officer - Financial metrics, LC registries & commercial insights.', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: AppTheme.success),
                SizedBox(width: 6),
                Text('Live Commercial Ledger Connected', style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. KPI STATS GRID (4 Cards Responsive Grid) ─────────────────────
  Widget _buildKpiStatsGrid(BuildContext context, int lcCount, double paidBdt, double lcDuesUsd, int approvedDocs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;

        final card1 = _buildKpiCard('ACTIVE IMPORT LCS', '$lcCount LCs', Icons.account_balance_outlined, AppTheme.primary);
        final card2 = _buildKpiCard('CUSTOMER PAID (BDT)', '৳ ${paidBdt.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined, AppTheme.warning);
        final card3 = _buildKpiCard('LC DUES (USD)', '\$${lcDuesUsd.toStringAsFixed(2)}', Icons.monetization_on_outlined, AppTheme.info);
        final card4 = _buildKpiCard('DOCS APPROVED TODAY', '$approvedDocs Sets', Icons.verified_outlined, AppTheme.success);

        if (isWide) {
          return Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 12),
              Expanded(child: card2),
              const SizedBox(width: 12),
              Expanded(child: card3),
              const SizedBox(width: 12),
              Expanded(child: card4),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 10),
                Expanded(child: card2),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: card3),
                const SizedBox(width: 10),
                Expanded(child: card4),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
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
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 20),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
          const Text('LIVE LEDGER', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── 4. COMMERCIAL QUICK ACTIONS & TOOLS (6 Operational Nodes) ────────
  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: AppTheme.warning, size: 18),
                  SizedBox(width: 6),
                  Text('Commercial Quick Actions & Tools', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.purpleLight, borderRadius: BorderRadius.circular(12)),
                child: const Text('6 OPERATIONAL NODES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width > 800 ? 6 : (width > 500 ? 3 : 2);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.15,
                children: [
                  _buildQuickActionItem('Add New LC', 'Issue new credit', Icons.add_circle_outline, const Color(0xFF4F46E5), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LetterOfCreditFormScreen()));
                  }),
                  _buildQuickActionItem('LC Registry', 'Audit LCs', Icons.account_balance_outlined, const Color(0xFF4F46E5), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LetterOfCreditDataScreen()));
                  }),
                  _buildQuickActionItem('Customer Orders', 'View & audit orders', Icons.shopping_bag_outlined, AppTheme.danger, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerOrderDataScreen()));
                  }),
                  _buildQuickActionItem('Commercial Invoice', 'Audit billing & search', Icons.description_outlined, AppTheme.primary, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CommercialInvoiceDataScreen()));
                  }),
                  _buildQuickActionItem('Shipping & Cargo', 'Track consignments', Icons.local_shipping_outlined, AppTheme.success, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentDataScreen()));
                  }),
                  _buildQuickActionItem('Customer Payment', 'Verify payment proof', Icons.verified_user_outlined, AppTheme.info, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerPaymentDataScreen()));
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ── 5. ACTIVE LCS REGISTRY CARD ──────────────────────────────────────
  Widget _buildLcRegistryCard(List<LetterOfCreditResponseModel> activeLCs) {
    final filtered = lcSearchTerm.isEmpty
        ? activeLCs
        : activeLCs.where((lc) => lc.lcNumber.toLowerCase().contains(lcSearchTerm.toLowerCase()) || lc.issuingBankName.toLowerCase().contains(lcSearchTerm.toLowerCase())).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.checklist, color: AppTheme.indigo, size: 18),
                  SizedBox(width: 6),
                  Text('Active Letters of Credit (LC) Registry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                ],
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LetterOfCreditDataScreen())),
                child: const Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No active LC records found', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ...filtered.take(4).map((lc) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lc.lcNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          Text(lc.issuingBankName.isNotEmpty ? lc.issuingBankName : 'Bank N/A', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${lc.currency == 'USD' ? '\$' : '৳'}${lc.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text(lc.lcStatus, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── 6. SHIPPING DOCUMENTS MANIFEST CARD ──────────────────────────────
  Widget _buildShippingDocsCard(List<Map<String, String>> documents) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.upload_file, color: AppTheme.primary, size: 18),
                  SizedBox(width: 6),
                  Text('Shipping Documents Manifest', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                ],
              ),
              Text('VAULT REPOSITORY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          if (documents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No vault documents indexed', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ...documents.take(3).map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['name'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          Text('Date: ${doc['date']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(doc['status'] ?? 'Approved', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── 7. COMMERCIAL INVOICES LEDGER CARD ───────────────────────────────
  Widget _buildInvoicesLedgerCard(List<InvoiceResponseModel> invoices) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.description, color: AppTheme.primary, size: 18),
                  SizedBox(width: 6),
                  Text('Commercial Invoices Ledger', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CommercialInvoiceDataScreen()));
                },
                child: const Text('View All Invoices →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No commercial invoices generated', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ...invoices.take(3).map((inv) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inv.invoiceNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          Text(inv.issuedToName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('৳${inv.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                          Text(inv.paymentStatus, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── 8. CARGO CONSIGNMENTS CARD ───────────────────────────────────────
  Widget _buildConsignmentsCard(List<ShipmentResponseModel> shipments) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_shipping, color: AppTheme.success, size: 18),
                  SizedBox(width: 6),
                  Text('Cargo & Shipping Consignments', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentDataScreen()));
                },
                child: const Text('Track Consignments →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.success)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (shipments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No active shipping consignments', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ...shipments.take(3).map((shp) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shp.shipmentNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success)),
                          Text(shp.supplierName.isNotEmpty ? shp.supplierName : 'Commercial Partner', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      Text('৳${shp.transportCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── 9. CUSTOMER PAYMENT VERIFICATION CARD ────────────────────────────
  Widget _buildPaymentVerificationCard(List<CustomerOrderResponse> orders) {
    final pendingOrders = orders.where((o) => o.paymentStatus == 'UNPAID' || o.paymentStatus == 'PARTIALLY_PAID').toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_user, color: AppTheme.info, size: 18),
                  SizedBox(width: 6),
                  Text('Customer Payment Verification', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                ],
              ),
              InkWell(
                onTap: () => _openPaymentModal(context),
                child: const Text('Audit Payment Queue →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.info)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pendingOrders.isEmpty) ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
                  SizedBox(height: 6),
                  Text('All Clear!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                  Text('No pending payment verification requests in queue.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ] else ...[
            ...pendingOrders.take(2).map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order #${o.orderNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () => _openPaymentModal(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.info, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                        child: const Text('Verify', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ── 10. PO LINE ITEMS CARD ───────────────────────────────────────────
  Widget _buildPoLineItemsCard(List<POLineItemResponseDTO> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.format_list_bulleted, color: AppTheme.warning, size: 18),
                  SizedBox(width: 6),
                  Text('Purchase Order Line Items Matrix', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                ],
              ),
              InkWell(
                onTap: () => _openLineItemsModal(context),
                child: const Text('Manage Line Items →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.warning)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No line distributions allocated', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ...items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('#${item.poNumber.isNotEmpty ? item.poNumber : item.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                            Text(item.productName.isNotEmpty ? item.productName : item.productCode, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Text('৳${item.unitPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── 11. PARAMETER CARDS ──────────────────────────────────────────────
  Widget _buildCapitalQuotasCard(double bdt, double usd, double total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LC Financial Quota Parameters', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('BDT Local Quota:', style: TextStyle(fontSize: 10, color: Colors.grey)), Text('৳${bdt.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))]),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: 0.75, backgroundColor: Colors.grey.shade200, color: AppTheme.primary),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('USD Foreign Quota:', style: TextStyle(fontSize: 10, color: Colors.grey)), Text('\$${usd.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.info))]),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: 0.45, backgroundColor: Colors.grey.shade200, color: AppTheme.info),
        ],
      ),
    );
  }

  Widget _buildDocComplianceCard(int approved, int customs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Document Vault Compliance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 10),
          const Text('98.4%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          const Text('Vault Health Score', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const Divider(height: 16),
          Text('Approved Manifest Sets: $approved Sets', style: const TextStyle(fontSize: 10, color: AppTheme.dark)),
          Text('Pending Customs: $customs Consignments', style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildShipmentVectorsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))]),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shipment Vector Parameters', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          SizedBox(height: 10),
          Text('🚢 Ocean Vessel Sea Freight: 65%', style: TextStyle(fontSize: 10)),
          SizedBox(height: 4),
          Text('✈️ International Air Express: 25%', style: TextStyle(fontSize: 10)),
          SizedBox(height: 4),
          Text('🚚 Local Road Transport: 10%', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // ── 12. SWIFT BANKS & TARIFF MATRIX ──────────────────────────────────
  Widget _buildSwiftBanksCard(List<LCBankResponseModel> banks) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SWIFT Banking Terminals & LC Quotas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/lcbank'),
                child: const Text('Manage Banks →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (banks.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: Text('No LC issuing bank terminals registered', style: TextStyle(fontSize: 11, color: Colors.grey))))
          else
            ...banks.take(3).map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(b.swiftCode, style: const TextStyle(fontSize: 10, color: AppTheme.indigo, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildTariffMatrixCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))]),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Import Tariff & Customs Matrix', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          SizedBox(height: 10),
          Text('🇨🇳 China (Guangzhou Port) - CLEARED', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('🇸🇬 Singapore (Jurong Hub) - CLEARED', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('🇩🇪 Germany (Hamburg Port) - INSPECTION', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── 13. NOTIFICATIONS SECTION ────────────────────────────────────────
  Widget _buildNotificationsSection(List<dynamic> notifications) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Commercial Notifications & System Updates', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 10),
          if (notifications.isEmpty)
            const Text('No new commercial notifications', style: TextStyle(fontSize: 10, color: Colors.grey))
          else
            ...notifications.take(3).map((n) {
              String title = 'System Alert';
              if (n is Map) {
                title = (n['title'] ?? n['message'] ?? n['text'] ?? n['content'] ?? 'System Alert').toString();
              } else if (n != null) {
                title = n.toString();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: AppTheme.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── 14. BOTTOM NAVIGATION BAR (Procurement Styled) ──────────────────
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Dashboard', true, onTap: () {}),
          _buildNavItem(Icons.account_balance, 'LC Registry', false, onTap: () => _openLcRegistryModal(context)),
          GestureDetector(
            onTap: () => _openAddLcModal(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: AppTheme.surfaceWhite, size: 26),
            ),
          ),
          _buildNavItem(Icons.notifications, 'Notifications', false, badge: '!', onTap: () => Navigator.pushNamed(context, '/notifications')),
          _buildNavItem(Icons.more_horiz, 'More', false, onTap: () => Navigator.pushNamed(context, '/commercial-profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {String? badge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Icon(icon, color: isActive ? AppTheme.primary : AppTheme.secondary, size: 22),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 7)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primary : AppTheme.secondary, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // ── MODAL 1: ADD NEW LC ──────────────────────────────────────────────
  void _openAddLcModal(BuildContext context) {
    _selectedPoId = 0;
    _selectedSupplierId = 0;
    _selectedBankId = 0;
    _selectedIncoTerms = 'FOB';
    _selectedCurrency = 'USD';
    _selectedLcStatus = 'OPENED';
    _contractAmount = 0.0;
    _portOfLoading = '';
    _portOfDischarge = '';
    _latestShipmentDate = null;
    _expiryDate = null;
    _selectedLcFile = null;
    _lcFormErrorMessage = null;
    _lcFormSuccessMessage = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final pos = ref.watch(purchaseOrderListProvider).value ?? [];
          final suppliers = ref.watch(supplierListProvider).value ?? [];
          final banks = ref.watch(lcBankListProvider).value ?? [];

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.account_balance, color: AppTheme.primary, size: 22),
                SizedBox(width: 8),
                Text('Issue New Letter of Credit (LC)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_lcFormSuccessMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(_lcFormSuccessMessage!, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    if (_lcFormErrorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(_lcFormErrorMessage!, style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),

                    const Text('Issuing Bank *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedBankId == 0 ? null : _selectedBankId,
                      hint: const Text('Select Bank', style: TextStyle(fontSize: 11)),
                      items: banks.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 11)))).toList(),
                      onChanged: (val) => setDialogState(() => _selectedBankId = val ?? 0),
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    const Text('Supplier Beneficiary *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedSupplierId == 0 ? null : _selectedSupplierId,
                      hint: const Text('Select Supplier', style: TextStyle(fontSize: 11)),
                      items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 11)))).toList(),
                      onChanged: (val) => setDialogState(() => _selectedSupplierId = val ?? 0),
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    const Text('Purchase Order (PO) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedPoId == 0 ? null : _selectedPoId,
                      hint: const Text('Select PO', style: TextStyle(fontSize: 11)),
                      items: pos.map((p) => DropdownMenuItem(value: p.id, child: Text('PO #${p.poNumber.isNotEmpty ? p.poNumber : p.id}', style: const TextStyle(fontSize: 11)))).toList(),
                      onChanged: (val) => setDialogState(() => _selectedPoId = val ?? 0),
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Amount *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(hintText: 'e.g. 50000', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                                onChanged: (val) => _contractAmount = double.tryParse(val) ?? 0.0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Currency', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCurrency,
                                items: const [
                                  DropdownMenuItem(value: 'USD', child: Text('USD (\$)', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'BDT', child: Text('BDT (৳)', style: TextStyle(fontSize: 11))),
                                ],
                                onChanged: (val) => setDialogState(() => _selectedCurrency = val ?? 'USD'),
                                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    const Text('Shipment IncoTerms', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedIncoTerms,
                      items: const [
                        DropdownMenuItem(value: 'FOB', child: Text('FOB - Free on Board', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'CIF', child: Text('CIF - Cost Insurance & Freight', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'CFR', child: Text('CFR - Cost & Freight', style: TextStyle(fontSize: 11))),
                      ],
                      onChanged: (val) => setDialogState(() => _selectedIncoTerms = val ?? 'FOB'),
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    OutlinedButton.icon(
                      onPressed: () async {
                        final file = await _picker.pickImage(source: ImageSource.gallery);
                        if (file != null) setDialogState(() => _selectedLcFile = File(file.path));
                      },
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: Text(_selectedLcFile == null ? 'Attach Document Vault File' : 'File Attached', style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: _isLcFormLoading
                    ? null
                    : () async {
                        if (_selectedBankId == 0 || _selectedSupplierId == 0 || _selectedPoId == 0 || _contractAmount <= 0) {
                          setDialogState(() => _lcFormErrorMessage = 'Please select valid Bank, Supplier, PO and enter contract amount > 0.');
                          return;
                        }
                        setDialogState(() {
                          _isLcFormLoading = true;
                          _lcFormErrorMessage = null;
                        });

                        final req = LetterOfCreditRequestModel(
                          purchaseOrderId: _selectedPoId,
                          issuingBankId: _selectedBankId,
                          shipmentIncoTerms: _selectedIncoTerms,
                          latestShipmentDate: _latestShipmentDate?.toIso8601String() ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
                          portOfLoading: _portOfLoading.isNotEmpty ? _portOfLoading : 'Shanghai Port',
                          portOfDischarge: _portOfDischarge.isNotEmpty ? _portOfDischarge : 'Chattogram Port',
                          amount: _contractAmount,
                          supplierId: _selectedSupplierId,
                          currency: _selectedCurrency,
                          expiryDate: _expiryDate?.toIso8601String() ?? DateTime.now().add(const Duration(days: 90)).toIso8601String(),
                          lcStatus: _selectedLcStatus,
                          documentVaultUrl: '',
                        );

                        final ok = await ref.read(letterOfCreditControllerProvider.notifier).saveLC(req, _selectedLcFile);
                        if (dialogCtx.mounted) {
                          setDialogState(() => _isLcFormLoading = false);
                          if (ok) {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Letter of Credit issued successfully!'), backgroundColor: Colors.green));
                          } else {
                            setDialogState(() => _lcFormErrorMessage = 'Failed to issue LC.');
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                child: _isLcFormLoading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Issue LC'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── MODAL 2: LC REGISTRY MASTER VIEW ─────────────────────────────────
  void _openLcRegistryModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Active Letters of Credit Master Registry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 400,
            child: Consumer(
              builder: (context, ref, _) {
                final lcs = ref.watch(letterOfCreditListProvider).value ?? [];
                return ListView.builder(
                  itemCount: lcs.length,
                  itemBuilder: (ctx, i) {
                    final lc = lcs[i];
                    return ListTile(
                      title: Text(lc.lcNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text('Bank: ${lc.issuingBankName} | Status: ${lc.lcStatus}', style: const TextStyle(fontSize: 10)),
                      trailing: Text('${lc.currency == 'USD' ? '\$' : '৳'}${lc.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11)),
                    );
                  },
                );
              },
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  // ── MODAL 6: CUSTOMER PAYMENT VERIFICATION ───────────────────────────
  void _openPaymentModal(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerPaymentDataScreen()));
  }

  // ── MODAL 7: PO LINE ITEMS MATRIX ────────────────────────────────────
  void _openLineItemsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Purchase Order Line Items Matrix', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 400,
            child: Consumer(
              builder: (context, ref, _) {
                final items = ref.watch(poLineItemListProvider).value ?? [];
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return ListTile(
                      title: Text('#${item.poNumber.isNotEmpty ? item.poNumber : item.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text('Product: ${item.productName} | Status: ${item.status}', style: const TextStyle(fontSize: 10)),
                      trailing: Text('৳${item.unitPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11)),
                    );
                  },
                );
              },
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }
}