import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiConstants.dart';
import 'package:scm_flutter/util/pdf_invoice_generator.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class CustomerDashboardScreen extends ConsumerStatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  ConsumerState<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends ConsumerState<CustomerDashboardScreen> {
  int _currentIndex = 0;

  double _parseNum(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _resolveProductImageUrl(String? imgPath) {
    if (imgPath == null || imgPath.trim().isEmpty) return '';
    final trimmed = imgPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/images/')) {
      return '${ApiConstants.imgUrl}${trimmed.substring(8)}';
    }
    if (trimmed.startsWith('images/')) {
      return '${ApiConstants.imgUrl}${trimmed.substring(7)}';
    }
    if (trimmed.startsWith('product/')) {
      return '${ApiConstants.imgUrl}$trimmed';
    }
    return '${ApiConstants.imgUrl}product/$trimmed';
  }

  Color _getStatusColor(String status) {
    return AppTheme.statusColor(status);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentCustomerAsync = ref.watch(currentCustomerProvider);
    final orderSummaryAsync = ref.watch(customerOrderSummaryProvider);
    final myOrdersAsync = ref.watch(myCustomerOrdersProvider);
    final productListAsync = ref.watch(productListProvider);

    final String userName = (currentUser?.name != null && currentUser!.name.isNotEmpty)
        ? currentUser.name
        : (currentCustomerAsync.value?.name.isNotEmpty == true
            ? currentCustomerAsync.value!.name
            : 'Customer');

    // Calculate dynamic due total & wallet paid total
    double dueAmountTotal = 0.0;
    double walletBalance = 0.0;

    myOrdersAsync.whenData((orders) {
      for (var order in orders) {
        dueAmountTotal += _parseNum(order.dueAmount);
        walletBalance += _parseNum(order.paidAmount);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: const DynamicScmTopNavBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(customerOrderSummaryProvider);
          ref.invalidate(myCustomerOrdersProvider);
          ref.invalidate(productListProvider);
          ref.invalidate(notificationUnreadCountProvider);
          ref.invalidate(currentCustomerProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Banner ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Welcome back, $userName ',
                                  style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text('👋', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Track your orders & profile details in real time.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                CircleAvatar(radius: 3, backgroundColor: AppTheme.success),
                                SizedBox(width: 6),
                                Text('Live System Connected', style: TextStyle(color: AppTheme.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.local_shipping_rounded, color: Colors.white24, size: 70),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Wallet & Due Cards ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.primaryDark, AppTheme.blue]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                              SizedBox(width: 6),
                              Text('Paid / Wallet', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '৳${walletBalance.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_today_outlined, color: AppTheme.danger, size: 18),
                              SizedBox(width: 6),
                              Text('Due Payments', style: TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '৳${dueAmountTotal.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppTheme.dark, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Order Metrics Grid ──────────────────────
              orderSummaryAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Text('Error loading stats: $err', style: const TextStyle(color: AppTheme.danger))),
                data: (summary) => Column(
                  children: [
                    Row(
                      children: [
                        _buildMetricCard('Total Orders', '${summary.total}', 'All-time orders', AppTheme.primary, Icons.shopping_bag_outlined),
                        const SizedBox(width: 8),
                        _buildMetricCard('Active Orders', '${summary.active}', '${summary.active} Processing', AppTheme.success, Icons.inventory_2_outlined),
                        const SizedBox(width: 8),
                        _buildMetricCard('Delivered', '${summary.completed}', 'Successfully delivered', AppTheme.success, Icons.check_circle_outline),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_empty_rounded, color: AppTheme.warning, size: 28),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${summary.pending}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const Text('Pending Orders', style: TextStyle(color: AppTheme.grey, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.cancel_outlined, color: AppTheme.danger, size: 28),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${summary.cancelled}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const Text('Cancelled Orders', style: TextStyle(color: AppTheme.grey, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Quick Actions ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/products'),
                    child: const Text('View All →', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildQuickActionItem('Place Order', Icons.shopping_cart_outlined, () {
                    Navigator.of(context).pushNamed('/customer-order');
                  }),
                  _buildQuickActionItem('Add Payment', Icons.payment_outlined, () {
                    Navigator.of(context).pushNamed('/add-payment');
                  }),
                  _buildQuickActionItem('Track Order', Icons.location_on_outlined, () {
                    Navigator.of(context).pushNamed('/customer-order-track');
                  }),
                  _buildQuickActionItem('Billing Ledger', Icons.receipt_long_outlined, () {
                    Navigator.of(context).pushNamed('/billing-ledger');
                  }),
                  _buildQuickActionItem('Invoices', Icons.description_outlined, () {
                    Navigator.of(context).pushNamed('/invoice-portal');
                  }),
                  _buildQuickActionItem('Support', Icons.headset_mic_outlined, () {
                    Navigator.of(context).pushNamed('/support');
                  }),
                  _buildQuickActionItem('Products', Icons.inventory_2_rounded, () {
                    Navigator.of(context).pushNamed('/products');
                  }),
                  _buildQuickActionItem('My Profile', Icons.person_outline_rounded, () {
                    Navigator.of(context).pushNamed('/profile');
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // ── Active Order Pipeline ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Order Pipeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/customer-orders'),
                    child: const Text('View All →', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              orderSummaryAsync.when(
                loading: () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text('Error loading orders: $err', style: const TextStyle(color: AppTheme.danger))),
                ),
                data: (summary) {
                  final recentOrders = summary.recent.take(5).toList();
                  if (recentOrders.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: const [
                          Icon(Icons.inbox_rounded, color: AppTheme.primary, size: 48),
                          SizedBox(height: 8),
                          Text('No active order records found.', style: TextStyle(color: AppTheme.grey, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: recentOrders.map((order) {
                      final statusColor = _getStatusColor(order.status);
                      final statusLabel = CustomerOrderStatusMeta.labelFor(order.status);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppTheme.borderGrey),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            child: Icon(Icons.local_shipping_outlined, color: statusColor),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderNumber.isNotEmpty ? order.orderNumber : 'Order #${order.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Items: ${order.lineItems.length} | Total: ৳${order.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.grey),
                                ),
                                Text(
                                  order.createdAt.length >= 10 ? order.createdAt.substring(0, 10) : order.createdAt,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.grey),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'View Order PDF',
                            icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primary, size: 22),
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Generating PDF for ${order.orderNumber}...'), duration: const Duration(seconds: 1)),
                              );
                              await PdfInvoiceGenerator.downloadOrPrint(order: order);
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/customer-order-track',
                              arguments: order.orderNumber,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── Recommended for You ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recommended for You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/products'),
                    child: const Text('View All →', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              productListAsync.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text('Unable to load products: $err', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('No recommended products available.', style: TextStyle(color: AppTheme.grey))),
                    );
                  }

                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        final bool inStock = item.quantity > 0;

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/product-details',
                              arguments: item,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 170,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: AppTheme.light,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      final imageUrl = _resolveProductImageUrl(item.image);
                                      return Center(
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, color: AppTheme.grey, size: 40),
                                              )
                                            : const Icon(Icons.inventory_2_outlined, color: AppTheme.grey, size: 40),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  '৳${item.sellingPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      inStock ? Icons.check_circle : Icons.remove_circle_outline,
                                      color: inStock ? AppTheme.success : AppTheme.danger,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      inStock ? 'In Stock (${item.quantity})' : 'Out of Stock',
                                      style: TextStyle(fontSize: 10, color: inStock ? AppTheme.success : AppTheme.danger),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: AppTheme.white,
                                      padding: EdgeInsets.zero,
                                      textStyle: const TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/customer-order');
                                    },
                                    icon: const Icon(Icons.shopping_cart_outlined, size: 12),
                                    label: const Text('Add to Cart'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.of(context).pushNamed('/customer-orders');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/products');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/commercial-invoice-data');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String count, String subtitle, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.dark),
            ),
          ],
        ),
      ),
    );
  }
}