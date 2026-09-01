import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class CustomerOrderTrackScreen extends ConsumerStatefulWidget {
  const CustomerOrderTrackScreen({super.key, this.initialOrderNumber});

  final String? initialOrderNumber;

  @override
  ConsumerState<CustomerOrderTrackScreen> createState() => _CustomerOrderTrackScreenState();
}

class _CustomerOrderTrackScreenState extends ConsumerState<CustomerOrderTrackScreen> {
  late TextEditingController _searchController;
  String? searchedOrderNumber;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialOrderNumber ?? '');
    searchedOrderNumber = widget.initialOrderNumber;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = (searchedOrderNumber != null && searchedOrderNumber!.isNotEmpty)
        ? ref.watch(trackCustomerOrderProvider(searchedOrderNumber!))
        : null;

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'SCM PRO',
              style: TextStyle(color: AppTheme.dark, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          const DynamicNotificationButton(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: AppTheme.borderGrey,
              child: const Icon(Icons.person, color: AppTheme.dark),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Track Banner & Search Box ──────────────────
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Track Your Shipment',
                    style: TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter your tracking ID to view real-time shipment details',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: AppTheme.grey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Tracking ID (e.g. SCM-TRK-587421)',
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 12, color: AppTheme.grey),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              setState(() {
                                searchedOrderNumber = _searchController.text.trim();
                              });
                            }
                          },
                          child: const Text('Track Now', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Order Details Result Section ───────────────
            if (searchedOrderNumber == null || searchedOrderNumber!.isEmpty)
              _buildEmptyState('Please enter a tracking ID to search.')
            else
              orderAsync!.when(
                data: (order) => _buildTrackingResult(order),
                loading: () => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => _buildEmptyState('Order not found or invalid tracking ID.'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingResult(CustomerOrderResponse order) {
    final status = order.status.toUpperCase();

    final bool isPendingDone = true;
    final bool isConfirmedDone = status == 'CONFIRMED' || status == 'PROCESSING' || status == 'SHIPPED' || status == 'DELIVERED';
    final bool isProcessingDone = status == 'PROCESSING' || status == 'SHIPPED' || status == 'DELIVERED';
    final bool isShippedDone = status == 'SHIPPED' || status == 'DELIVERED';
    final bool isDeliveredDone = status == 'DELIVERED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Reference Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ORDER REFERENCE', style: TextStyle(color: AppTheme.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(radius: 3, backgroundColor: AppTheme.success),
                        const SizedBox(width: 6),
                        Text(order.status, style: const TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(order.orderNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, size: 16, color: AppTheme.primary),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recipient Customer', style: TextStyle(color: AppTheme.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Settlement Financial State', style: TextStyle(color: AppTheme.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(order.paymentStatus, style: const TextStyle(color: AppTheme.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimated Arrival Roadmap', style: TextStyle(color: AppTheme.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text(order.estimatedDelivery, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Consignment Value', style: TextStyle(color: AppTheme.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('৳${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _subInfoColumn(Icons.location_on_outlined, 'Current Location', 'Dhaka Hub'),
                  _subInfoColumn(Icons.local_shipping_outlined, 'Service Type', order.serviceType),
                  _subInfoColumn(Icons.access_time, 'Last Updated', order.createdAt),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Milestone Progress Pipeline ────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('MILESTONE PROGRESS PIPELINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.grey)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _milestoneStep('Pending', Icons.access_time, isPendingDone),
              _milestoneStep('Confirmed', Icons.check, isConfirmedDone),
              _milestoneStep('Processing', Icons.settings, isProcessingDone),
              _milestoneStep('Shipped', Icons.local_shipping, isShippedDone),
              _milestoneStep('Delivered', Icons.inventory, isDeliveredDone),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Shipment Details Card ──────────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('SHIPMENT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.grey)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Column(
            children: [
              _detailRow('Order ID', order.orderNumber, 'Total Items', '${order.lineItems.length} Items'),
              const Divider(height: 20),
              _detailRow('Package Weight', '${order.weight} kg', 'Shipping Address', order.deliveryAddress),
              const Divider(height: 20),
              _detailRow('Payment Method', order.paymentMethod, 'Total Amount', '৳${order.totalAmount.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }
  Widget _subInfoColumn(IconData icon, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.grey),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: AppTheme.grey, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _milestoneStep(String title, IconData icon, bool isCompleted) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isCompleted ? AppTheme.success : AppTheme.borderGrey,
          child: Icon(icon, size: 16, color: isCompleted ? AppTheme.white : AppTheme.grey),
        ),
        const SizedBox(height: 6),
        Text(title, style: TextStyle(fontSize: 10, color: isCompleted ? AppTheme.dark : AppTheme.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _detailRow(String title1, String val1, String title2, String val2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title1, style: const TextStyle(color: AppTheme.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(val1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title2, style: const TextStyle(color: AppTheme.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(val2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 50, color: AppTheme.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
        ],
      ),
    );
  }
}