import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/sales_officer/provider/sales_officer_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/system/massage/chat_workspace_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class DynamicScmTopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onRefresh;

  const DynamicScmTopNavBar({
    super.key,
    this.title = 'SCM ENTERPRISE',
    this.showBackButton = false,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  String _resolveImageUrl(String? rawUrl, {String subFolder = 'sales_officer'}) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (cleanPath.startsWith('images/')) {
      return 'http://${ApiConstants.host}:8085/$cleanPath';
    }
    if (cleanPath.startsWith('sales_officer/') ||
        cleanPath.startsWith('supplier/') ||
        cleanPath.startsWith('product/') ||
        cleanPath.startsWith('customer/') ||
        cleanPath.startsWith('driver/') ||
        cleanPath.startsWith('user/')) {
      return '${ApiConstants.imgUrl}$cleanPath';
    }
    return '${ApiConstants.imgUrl}$subFolder/$cleanPath';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final rawName = currentUser?.name.trim() ?? 'User';
    final userInitials = rawName.length >= 2
        ? rawName.substring(0, 2).toUpperCase()
        : (rawName.isNotEmpty ? rawName.toUpperCase() : 'US');

    // Resolve avatar image across User profile, Sales Officer, Customer, and Supplier providers
    String avatarUrl = '';
    
    // 1. Direct image on User model
    if (currentUser?.image != null && currentUser!.image!.trim().isNotEmpty) {
      avatarUrl = _resolveImageUrl(currentUser.image, subFolder: 'user');
    }

    // 2. Sales Officer image
    if (avatarUrl.isEmpty) {
      final salesOfficerAsync = ref.watch(currentSalesOfficerProvider);
      final currentSalesOfficer = salesOfficerAsync.value;
      if (currentSalesOfficer != null && currentSalesOfficer.image.isNotEmpty) {
        avatarUrl = _resolveImageUrl(currentSalesOfficer.image, subFolder: 'sales_officer');
      }
    }

    // 3. Customer image
    if (avatarUrl.isEmpty) {
      final customerAsync = ref.watch(currentCustomerProvider);
      final currentCustomer = customerAsync.value;
      if (currentCustomer != null && currentCustomer.image.isNotEmpty) {
        avatarUrl = _resolveImageUrl(currentCustomer.image, subFolder: 'customer');
      }
    }

    // 4. Supplier image
    if (avatarUrl.isEmpty) {
      final suppliersAsync = ref.watch(supplierListProvider);
      final suppliers = suppliersAsync.value ?? [];
      final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;
      if (currentSupplier != null && currentSupplier.image.isNotEmpty) {
        avatarUrl = _resolveImageUrl(currentSupplier.image, subFolder: 'supplier');
      }
    }

    final role = currentUser?.role.toUpperCase() ?? '';
    String displayTitle = title;
    IconData roleIcon = Icons.business_center;

    if (role.contains('CUSTOMER')) {
      roleIcon = Icons.shopping_bag_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'SCM Customer Portal';
    } else if (role.contains('DRIVER')) {
      roleIcon = Icons.local_shipping_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'Driver Logistics Console';
    } else if (role.contains('LOGISTICS')) {
      roleIcon = Icons.inventory_2_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'Logistics Officer Hub';
    } else if (role.contains('PROCUREMENT')) {
      roleIcon = Icons.shopping_cart_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'Procurement Hub';
    } else if (role.contains('COMMERCIAL')) {
      roleIcon = Icons.receipt_long_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'Commercial Portal';
    } else if (role.contains('SALES')) {
      roleIcon = Icons.point_of_sale_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'Sales Officer Console';
    } else if (role.contains('QC') || role.contains('INSPECTOR')) {
      roleIcon = Icons.fact_check_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'Quality Inspector Portal';
    } else if (role.contains('SUPPLIER')) {
      roleIcon = Icons.storefront_outlined;
      if (title == 'SCM ENTERPRISE' || title.isEmpty) displayTitle = 'Supplier Enterprise Portal';
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Branding & Optional Back Button (Responsive Expanded)
            Expanded(
              child: Row(
                children: [
                  if (showBackButton) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(roleIcon, color: const Color(0xFF2563EB), size: 18),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            // Right Actions: Refresh, Notification Badge, User Avatar Image, 3-Dot Options Dropdown
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DynamicNotificationButton(),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chat_outlined, color: AppTheme.secondary, size: 20),
                  tooltip: 'Messages & Chat',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatWorkspaceScreen()),
                    );
                  },
                ),
                const SizedBox(width: 4),
                
                // User Avatar Circle (Displays Profile & Logout Popup on click)
                PopupMenuButton<String>(
                  tooltip: 'User Account',
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 8),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      final role = currentUser?.role.toUpperCase() ?? '';
                      if (role.contains('SALES')) {
                        Navigator.pushNamed(context, '/sales-officer-profile');
                      } else if (role.contains('PROCUREMENT') || role.contains('LOGISTICS')) {
                        Navigator.pushNamed(context, '/procurement-profile');
                      } else if (role.contains('DRIVER')) {
                        Navigator.pushNamed(context, '/driver-profile');
                      } else {
                        Navigator.pushNamed(context, '/profile');
                      }
                    } else if (value == 'logout') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Logout', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text('Logged in as ${currentUser?.name ?? "User"}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text('Profile', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppTheme.primary,
                    child: avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    userInitials,
                                    style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.white),
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            userInitials,
                            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                  ),
                ),

                const SizedBox(width: 2),

                // 3-Dot Popup Menu Button (Navigation & User Options Dropdown)
                PopupMenuButton<String>(
                  tooltip: 'Options & Navigation',
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 8),
                  icon: const Icon(Icons.more_vert, color: AppTheme.secondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 220),
                  onSelected: (value) async {
                    switch (value) {
                      case 'purchase_requisition':
                        Navigator.pushNamed(context, '/purchase-requisitions');
                        break;
                      case 'purchase_order':
                        Navigator.pushNamed(context, '/purchase-orders');
                        break;
                      case 'quotation':
                        Navigator.pushNamed(context, '/quotations');
                        break;
                      case 'product_requirements':
                        Navigator.pushNamed(context, '/purchase-requisitions');
                        break;
                      case 'add_category':
                        Navigator.pushNamed(context, '/category-data');
                        break;
                      case 'products':
                        Navigator.pushNamed(context, '/products');
                        break;
                      case 'customer_requirements':
                      case 'customer_orders':
                        Navigator.pushNamed(context, '/customer-orders');
                        break;
                      case 'payment_statement':
                        Navigator.pushNamed(context, '/add-payment');
                        break;
                      case 'warehouse':
                      case 'stock':
                        Navigator.pushNamed(context, '/inventory-data');
                        break;
                      case 'stock_movement':
                        Navigator.pushNamed(context, '/stock-movements');
                        break;
                      case 'grn':
                        Navigator.pushNamed(context, '/good-received-notes');
                        break;
                      case 'qc_inspections':
                        Navigator.pushNamed(context, '/qc-inspections');
                        break;
                      case 'shipment':
                        Navigator.pushNamed(context, '/shipments');
                        break;
                      case 'delivery_trip':
                        Navigator.pushNamed(context, '/delivery-trips');
                        break;
                      case 'vehicles':
                        Navigator.pushNamed(context, '/vehicles');
                        break;
                      case 'letter_of_credit':
                        Navigator.pushNamed(context, '/letter-of-credit-data');
                        break;
                      case 'lc_bank':
                        Navigator.pushNamed(context, '/lc-bank-data');
                        break;
                      case 'billing':
                        Navigator.pushNamed(context, '/commercial-invoice-data');
                        break;
                      case 'po_line_item':
                        Navigator.pushNamed(context, '/po-line-items');
                        break;
                      case 'daily_report':
                        Navigator.pushNamed(context, '/customer-orders');
                        break;
                      case 'activity_log':
                        Navigator.pushNamed(context, '/notifications');
                        break;
                      case 'profile':
                        final role = currentUser?.role.toUpperCase() ?? '';
                        if (role.contains('SALES')) {
                          Navigator.pushNamed(context, '/sales-officer-profile');
                        } else if (role.contains('PROCUREMENT') || role.contains('LOGISTICS') || role.contains('MANAGER') || role.contains('ADMIN')) {
                          Navigator.pushNamed(context, '/procurement-profile');
                        } else if (role.contains('DRIVER')) {
                          Navigator.pushNamed(context, '/driver-profile');
                        } else {
                          Navigator.pushNamed(context, '/profile');
                        }
                        break;
                      case 'logout':
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final userRole = currentUser?.role.toUpperCase() ?? '';
                    final isManagerOrAdmin = userRole.contains('MANAGER') || userRole.contains('ADMIN');
                    final isCommercial = userRole.contains('COMMERCIAL');

                    const profileItem = PopupMenuItem<String>(
                      value: 'profile',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: AppTheme.primary),
                          SizedBox(width: 10),
                          Text('Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );

                    const logoutItem = PopupMenuItem<String>(
                      value: 'logout',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('Logout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.redAccent)),
                        ],
                      ),
                    );

                    // If Manager or Admin, show full dropdown menu matching user images
                    if (isManagerOrAdmin) {
                      return [
                        // PROCUREMENT
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 24,
                          child: Text('PROCUREMENT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'purchase_requisition',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Purchase Requisition', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'purchase_order',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Purchase Order', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'quotation',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.request_quote_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Quotations', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'product_requirements',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Product Requirements', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),

                        const PopupMenuDivider(height: 8),

                        // PRODUCTS & ORDERS
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 24,
                          child: Text('PRODUCTS & ORDERS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'add_category',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.label_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Add Category', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'products',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.grid_view_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Products', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'customer_requirements',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.assignment_ind_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Customer Requirements', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'customer_orders',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Customer Orders', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'payment_statement',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Payment Statement', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),

                        const PopupMenuDivider(height: 8),

                        // INVENTORY
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 24,
                          child: Text('INVENTORY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'warehouse',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.storefront_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Warehouse', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'stock',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.layers_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Stock', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'stock_movement',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Stock Movement', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'grn',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.move_to_inbox_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Goods Received Note', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),

                        const PopupMenuDivider(height: 8),

                        // QUALITY CONTROL
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 24,
                          child: Text('QUALITY CONTROL', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'qc_inspections',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.fact_check_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Quality Inspections', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),

                        const PopupMenuDivider(height: 8),

                        // LOGISTICS
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 24,
                          child: Text('LOGISTICS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'shipment',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Shipment', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delivery_trip',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.alt_route_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Delivery Trip', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'vehicles',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.directions_bus_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Vehicles', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),

                        const PopupMenuDivider(height: 8),

                        // COMMERCIAL
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 24,
                          child: Text('COMMERCIAL', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'letter_of_credit',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Letter Of Credit', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'lc_bank',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('LC Bank', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'billing',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Billing', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'po_line_item',
                          height: 34,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.format_list_bulleted, size: 15, color: Colors.black87),
                                  SizedBox(width: 10),
                                  Text('PO Line Item', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.green.shade400, width: 0.8),
                                ),
                                child: const Text('Active', style: TextStyle(fontSize: 8.5, color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                        const PopupMenuDivider(height: 8),

                        // REPORTS & LOGS
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 24,
                          child: Text('REPORTS & LOGS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'daily_report',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.insert_chart_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Daily Report', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'activity_log',
                          height: 34,
                          child: Row(
                            children: [
                              Icon(Icons.list_alt_outlined, size: 15, color: Colors.black87),
                              SizedBox(width: 10),
                              Text('Activity Log', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),

                        const PopupMenuDivider(height: 8),

                        profileItem,
                        logoutItem,
                      ];
                    }

                    if (!isCommercial) {
                      return [profileItem, logoutItem];
                    }

                    return [
                      // PRODUCTS & ORDERS
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 28,
                        child: Text('PRODUCTS & ORDERS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'customer_orders',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Customer Orders', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'payment_statement',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Payment Statement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),

                      const PopupMenuDivider(height: 10),

                      // LOGISTICS
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 28,
                        child: Text('LOGISTICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'shipment',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF4F46E5)),
                            SizedBox(width: 10),
                            Text('Shipment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
                          ],
                        ),
                      ),

                      const PopupMenuDivider(height: 10),

                      // COMMERCIAL
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 28,
                        child: Text('COMMERCIAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'letter_of_credit',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Letter Of Credit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'lc_bank',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('LC Bank', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'billing',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Billing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'po_line_item',
                        height: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.format_list_bulleted, size: 16, color: Colors.black87),
                                SizedBox(width: 10),
                                Text('PO Line Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade400, width: 0.8),
                              ),
                              child: const Text('Active', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                      const PopupMenuDivider(height: 10),

                      profileItem,
                      logoutItem,
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
