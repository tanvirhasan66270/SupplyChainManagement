import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/delivery_trip_model.dart';
import 'package:scm_flutter/entity/vehicle_model.dart';
import 'package:scm_flutter/logistics_officer/provider/delivery_trip_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/vehicle_provider.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  String _summaryMode = 'ALL'; // 'TODAY' or 'ALL'

  // Modal States
  final _searchTripController = TextEditingController();
  DeliveryTripResponseModel? _searchedTrip;
  String? _trackerSearchError;
  String _selectedTrackerStatus = 'IN_TRANSIT';
  XFile? _signatureImage;
  XFile? _photoImage;
  bool _isUpdatingTrip = false;
  final ImagePicker _picker = ImagePicker();

  // Vehicle Status Update State
  String _selectedVehicleStatus = 'AVAILABLE';
  bool _isUpdatingVehicle = false;

  @override
  void dispose() {
    _searchTripController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final tripsAsync = ref.watch(deliveryTripListProvider);
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final notificationsAsync = ref.watch(notificationListProvider);

    final allTrips = tripsAsync.value ?? [];
    final allVehicles = vehiclesAsync.value ?? [];
    final notifications = notificationsAsync.value ?? [];

    final userName = (currentUser != null && currentUser.name.isNotEmpty) ? currentUser.name : 'Driver';

    // Filter trips strictly assigned to logged in driver (by driverId, driverEmail, or driverName)
    final isDriverRole = currentUser?.role.toUpperCase() == 'DRIVER' || currentUser?.role.toUpperCase() == 'ROLE_DRIVER';
    final myTrips = allTrips.where((t) {
      if (!isDriverRole) return true; // Admins / Managers see all
      if (currentUser == null) return true;
      final matchId = t.driverId == currentUser.userId;
      final matchEmail = t.driverEmail.isNotEmpty && t.driverEmail.toLowerCase() == currentUser.email.toLowerCase();
      final matchName = t.driverName.isNotEmpty && t.driverName.toLowerCase() == currentUser.name.toLowerCase();
      return matchId || matchEmail || matchName;
    }).toList();

    // Filter vehicle assigned to logged in driver or default to first
    final assignedVehicle = allVehicles.firstWhere(
      (v) => currentUser != null && v.driverId == currentUser.userId,
      orElse: () => allVehicles.isNotEmpty
          ? allVehicles.first
          : VehicleResponseModel(
              id: 0,
              plateNumber: 'Dhaka Metro-HA-22-9981',
              type: 'VAN',
              capacity: 2.5,
              status: 'AVAILABLE',
              fuelLevel: 90,
            ),
    );

    // Calculate Summary Metrics
    List<DeliveryTripResponseModel> filteredTrips = myTrips;
    if (_summaryMode == 'TODAY') {
      final now = DateTime.now();
      filteredTrips = myTrips.where((t) {
        if (t.createdAt.isEmpty) return false;
        try {
          final tripDate = DateTime.parse(t.createdAt);
          return tripDate.year == now.year && tripDate.month == now.month && tripDate.day == now.day;
        } catch (_) {
          return true;
        }
      }).toList();
    }

    final totalTrips = filteredTrips.length;
    final deliveredCount = filteredTrips.where((t) => t.status == 'DELIVERED').length;
    final inTransitCount = filteredTrips.where((t) => t.status == 'IN_TRANSIT').length;
    final pendingCount = filteredTrips.where((t) => t.status == 'PENDING').length;
    final cancelledCount = filteredTrips.where((t) => t.status == 'CANCELLED').length;
    final distanceCovered = deliveredCount * 35;
    final deliveryProgress = totalTrips > 0 ? ((deliveredCount / totalTrips) * 100).round() : 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(deliveryTripListProvider);
            ref.invalidate(vehicleListProvider);
            ref.invalidate(notificationListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Header (Procurement Styled Dynamic Navigation Bar)
                DynamicScmTopNavBar(
                  onRefresh: () {
                    ref.invalidate(deliveryTripListProvider);
                    ref.invalidate(vehicleListProvider);
                    ref.invalidate(notificationListProvider);
                  },
                ),

                Padding(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2. Welcome Banner (Procurement Styled Gradient Container)
                      _buildWelcomeBanner(userName),
                      const SizedBox(height: 20),

                      // ── OVERVIEW Section (4 KPI Cards) ───────────────
                      _buildSectionHeader('OVERVIEW'),
                      const SizedBox(height: 10),
                      _buildKpiGrid(totalTrips, deliveredCount, inTransitCount, assignedVehicle, distanceCovered),
                      const SizedBox(height: 24),

                      // ── QUICK ACTIONS Section ────────────────────────
                      _buildSectionHeader('QUICK ACTIONS'),
                      const SizedBox(height: 10),
                      _buildQuickActionsRow(context, assignedVehicle),
                      const SizedBox(height: 24),

                      // ── TRIP SUMMARY & VEHICLE STATUS ────────────────
                      if (isMobile) ...[
                        _buildTripSummaryCard(totalTrips, deliveredCount, inTransitCount, pendingCount, cancelledCount),
                        const SizedBox(height: 16),
                        _buildVehicleStatusCard(assignedVehicle),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTripSummaryCard(totalTrips, deliveredCount, inTransitCount, pendingCount, cancelledCount),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildVehicleStatusCard(assignedVehicle),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── RECENT DELIVERY TRIPS & DELIVERY PROGRESS ────
                      if (isMobile) ...[
                        _buildRecentTripsCard(myTrips),
                        const SizedBox(height: 16),
                        _buildDeliveryProgressCard(deliveryProgress, deliveredCount, pendingCount + inTransitCount),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildRecentTripsCard(myTrips),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDeliveryProgressCard(deliveryProgress, deliveredCount, pendingCount + inTransitCount),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── ALERTS & NOTIFICATIONS Card ──────────────────
                      _buildAlertsSection(notifications),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(assignedVehicle),
    );
  }

  // ── 1. WELCOME BANNER (Procurement Styled) ──────────────────────────
  Widget _buildWelcomeBanner(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, $userName 👋', style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Track delivery trips & vehicle status in real time.', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                Text('ACTIVE DRIVER & VEHICLE LINKED', style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER HELPER ──────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark, letterSpacing: 0.8),
    );
  }

  // ── 2. OVERVIEW KPI GRID ───────────────────────────────────────────
  Widget _buildKpiGrid(int totalTrips, int delivered, int inTransit, VehicleResponseModel vehicle, int distance) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 4;
        double aspectRatio = 1.35;

        if (width < 420) {
          crossAxisCount = 2;
          aspectRatio = 1.18;
        } else if (width < 700) {
          crossAxisCount = 2;
          aspectRatio = 1.45;
        } else if (width < 1000) {
          crossAxisCount = 4;
          aspectRatio = 1.25;
        } else {
          crossAxisCount = 4;
          aspectRatio = 1.4;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            _buildKpiCard(
              title: 'TOTAL TRIPS',
              value: '$totalTrips',
              subtitle: '$delivered delivered,\n$inTransit in transit',
              icon: Icons.location_on,
              iconBg: const Color(0xFF2563EB),
            ),
            _buildKpiCard(
              title: 'VEHICLE HEALTH',
              value: vehicle.type.toUpperCase(),
              badgeText: vehicle.status == 'AVAILABLE' ? 'All systems normal' : vehicle.status,
              badgeIsSuccess: vehicle.status == 'AVAILABLE',
              icon: Icons.monitor_heart_outlined,
              iconBg: const Color(0xFF10B981),
            ),
            _buildKpiCard(
              title: 'FUEL LEVEL',
              value: '${vehicle.fuelLevel}%',
              badgeText: vehicle.fuelLevel > 20 ? 'Optimal' : 'Low Fuel',
              badgeIsSuccess: vehicle.fuelLevel > 20,
              icon: Icons.local_gas_station_outlined,
              iconBg: const Color(0xFFF59E0B),
            ),
            _buildKpiCard(
              title: 'DISTANCE COVERED',
              value: '$distance km',
              subtitle: 'Based on $delivered deliveries',
              icon: Icons.speed_outlined,
              iconBg: const Color(0xFF0EA5E9),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    String? subtitle,
    String? badgeText,
    bool badgeIsSuccess = true,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (badgeText != null)
            Row(
              children: [
                Icon(
                  badgeIsSuccess ? Icons.check_circle : Icons.warning_amber_rounded,
                  size: 11,
                  color: badgeIsSuccess ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: badgeIsSuccess ? Colors.green : Colors.orange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── 3. QUICK ACTIONS ROW ───────────────────────────────────────────
  Widget _buildQuickActionsRow(BuildContext context, VehicleResponseModel vehicle) {
    final status = vehicle.status.toUpperCase();
    final isAvailableOrOnTrip = status == 'AVAILABLE' || status == 'ON_TRIP';
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 700;

    final List<Widget> buttons = [
      if (isAvailableOrOnTrip) ...[
        _buildQuickActionButton(
          icon: Icons.play_arrow_rounded,
          iconColor: Colors.green,
          label: 'Start Trip',
          onTap: () => _openTrackerModal('START'),
        ),
        _buildQuickActionButton(
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          label: 'Complete Delivery',
          onTap: () => _openTrackerModal('COMPLETE'),
        ),
      ],
      _buildQuickActionButton(
        icon: Icons.directions_car_outlined,
        iconColor: AppTheme.primary,
        label: 'Update Status',
        onTap: () => _openVehicleStatusModal(vehicle),
      ),
      if (isAvailableOrOnTrip) ...[
        _buildQuickActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: AppTheme.primary,
          label: 'Message',
          onTap: () => Navigator.pushNamed(context, '/messages'),
        ),
      ],
    ];

    if (isWide) {
      return Row(
        children: buttons
            .map((btn) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: btn,
                  ),
                ))
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: buttons
            .map((btn) => Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 8),
                  child: btn,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. TRIP SUMMARY CARD ───────────────────────────────────────────
  Widget _buildTripSummaryCard(int total, int delivered, int inTransit, int pending, int cancelled) {
    String formatNum(int n) => n < 10 && n > 0 ? '0$n' : '$n';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TRIP SUMMARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.list_alt, 'Assigned Trips', formatNum(total), Colors.grey),
          const SizedBox(height: 8),
          _buildSummaryRow(Icons.check_circle_outline, 'Completed', formatNum(delivered), Colors.green),
          const SizedBox(height: 8),
          _buildSummaryRow(Icons.local_shipping_outlined, 'In Transit', formatNum(inTransit), AppTheme.primary),
          const SizedBox(height: 8),
          _buildSummaryRow(Icons.access_time, 'Pending', formatNum(pending), Colors.orange),
          const SizedBox(height: 8),
          _buildSummaryRow(Icons.cancel_outlined, 'Cancelled', formatNum(cancelled), Colors.red),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _summaryMode = 'TODAY'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: _summaryMode == 'TODAY' ? AppTheme.primary : Colors.grey,
                    side: BorderSide(color: _summaryMode == 'TODAY' ? AppTheme.primary : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _summaryMode = 'ALL'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('View All', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
        ),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ── 5. VEHICLE STATUS CARD ─────────────────────────────────────────
  Widget _buildVehicleStatusCard(VehicleResponseModel vehicle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VEHICLE STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildVehicleRow(Icons.directions_car_outlined, 'Status', vehicle.status, Colors.green),
          const SizedBox(height: 8),
          _buildVehicleRow(Icons.local_gas_station_outlined, 'Fuel', '${vehicle.fuelLevel}%', Colors.orange),
          const SizedBox(height: 8),
          _buildVehicleRow(Icons.badge_outlined, 'License Plate', vehicle.plateNumber, const Color(0xFF1E293B)),
          const SizedBox(height: 8),
          _buildVehicleRow(Icons.local_shipping_outlined, 'Type', vehicle.type, Colors.green),
          const SizedBox(height: 8),
          _buildVehicleRow(Icons.calendar_month_outlined, 'Next Maint.', 'N/A', AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildVehicleRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ── 6. RECENT DELIVERY TRIPS CARD ──────────────────────────────────
  Widget _buildRecentTripsCard(List<DeliveryTripResponseModel> trips) {
    final recent = trips.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RECENT DELIVERY TRIPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No recent trips', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ...recent.map((trip) => _buildRecentTripItem(trip)),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/delivery-trips'),
              child: const Text('View All Trips', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTripItem(DeliveryTripResponseModel trip) {
    final statusColor = trip.status == 'DELIVERED'
        ? Colors.green
        : (trip.status == 'IN_TRANSIT' ? AppTheme.primary : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  trip.recipientName.isNotEmpty ? trip.recipientName : 'Trip #${trip.id}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  trip.status.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Colors.red),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trip.customerAddress.isNotEmpty ? trip.customerAddress : 'Destination',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 7. DELIVERY PROGRESS CARD ──────────────────────────────────────
  Widget _buildDeliveryProgressCard(int progressPercent, int completed, int pending) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DELIVERY PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progressPercent / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                  Text(
                    '$progressPercent%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Colors.green),
                      SizedBox(width: 4),
                      Text('Completed', style: TextStyle(fontSize: 8, color: Colors.grey)),
                    ],
                  ),
                  Text('$completed', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              Column(
                children: [
                  const Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Colors.orange),
                      SizedBox(width: 4),
                      Text('Pending', style: TextStyle(fontSize: 8, color: Colors.grey)),
                    ],
                  ),
                  Text('$pending', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/delivery-trips'),
              child: const Text('View Details', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 8. ALERTS & NOTIFICATIONS SECTION ─────────────────────────────
  Widget _buildAlertsSection(List<dynamic> notifications) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: Colors.red, size: 16),
                  SizedBox(width: 6),
                  Text('ALERTS & NOTIFICATIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: const Text('View All Alerts', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (notifications.isEmpty)
            const Column(
              children: [
                Center(
                  child: Icon(Icons.check_circle_outline, color: Colors.green, size: 36),
                ),
                SizedBox(height: 6),
                Center(
                  child: Text('All systems clear. No new alerts.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ),
              ],
            )
          else
            ...notifications.take(2).map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          n.title ?? 'System Notification',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── 9. BOTTOM NAVIGATION BAR (Procurement Styled) ──────────────────
  Widget _buildBottomNavigationBar(VehicleResponseModel vehicle) {
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
          _buildNavItem(Icons.local_shipping, 'Trips', false, onTap: () => Navigator.pushNamed(context, '/delivery-trips')),
          GestureDetector(
            onTap: () => _openTrackerModal('START'),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: AppTheme.surfaceWhite, size: 26),
            ),
          ),
          _buildNavItem(Icons.notifications, 'Notifications', false, badge: '!', onTap: () => Navigator.pushNamed(context, '/notifications')),
          _buildNavItem(Icons.directions_car, 'Vehicle', false, onTap: () => _openVehicleStatusModal(vehicle)),
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
                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primary : AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── 10. MODAL: TRIP TRACKER (Start / Complete Delivery) ─────────────
  void _openTrackerModal(String contextType) {
    _selectedTrackerStatus = contextType == 'START' ? 'IN_TRANSIT' : 'DELIVERED';
    _searchTripController.clear();
    _searchedTrip = null;
    _trackerSearchError = null;
    _signatureImage = null;
    _photoImage = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                contextType == 'START' ? 'Start Trip Tracker' : 'Complete Delivery',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter Trip ID:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchTripController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g. 101',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final query = _searchTripController.text.trim();
                          if (query.isEmpty) return;
                          final numericStr = query.replaceAll(RegExp(r'\D'), '');
                          final id = int.tryParse(numericStr);
                          if (id == null) {
                            setDialogState(() => _trackerSearchError = 'Invalid Trip ID format. Please ensure it contains a number.');
                            return;
                          }
                          try {
                            final repo = ref.read(deliveryTripRepositoryProvider);
                            final trips = await repo.findAll();
                            final found = trips.where((t) => t.id == id).firstOrNull;
                            final user = ref.read(currentUserProvider);
                            final isDriverRole = user?.role.toUpperCase() == 'DRIVER' || user?.role.toUpperCase() == 'ROLE_DRIVER';

                            setDialogState(() {
                              if (found != null) {
                                final matchId = user != null && found.driverId == user.userId;
                                final matchEmail = user != null && found.driverEmail.isNotEmpty && found.driverEmail.toLowerCase() == user.email.toLowerCase();
                                final matchName = user != null && found.driverName.isNotEmpty && found.driverName.toLowerCase() == user.name.toLowerCase();
                                final isMyTrip = !isDriverRole || matchId || matchEmail || matchName;

                                if (!isMyTrip) {
                                  final assignedName = found.driverName.isNotEmpty ? found.driverName : found.driverEmail;
                                  _trackerSearchError = 'Trip #$id is issued to another driver ($assignedName). You can only update your own trips.';
                                  _searchedTrip = null;
                                } else if (found.status == 'DELIVERED') {
                                  _trackerSearchError = 'This trip is already DELIVERED and cannot be modified.';
                                  _searchedTrip = null;
                                } else {
                                  _searchedTrip = found;
                                  _trackerSearchError = null;
                                }
                              } else {
                                _trackerSearchError = 'Trip #$id not found in database.';
                                _searchedTrip = null;
                              }
                            });
                          } catch (e) {
                            setDialogState(() => _trackerSearchError = 'Error fetching trip details.');
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                        child: const Text('Search', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  if (_trackerSearchError != null) ...[
                    const SizedBox(height: 6),
                    Text(_trackerSearchError!, style: const TextStyle(color: Colors.red, fontSize: 10)),
                  ],

                  if (_searchedTrip != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trip #${_searchedTrip!.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Recipient: ${_searchedTrip!.recipientName}', style: const TextStyle(fontSize: 11)),
                          Text('Address: ${_searchedTrip!.customerAddress}', style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 8),
                          Text('Status: ${_searchedTrip!.status}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Action Status:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTrackerStatus,
                      items: const [
                        DropdownMenuItem(value: 'IN_TRANSIT', child: Text('IN TRANSIT (Start Trip)')),
                        DropdownMenuItem(value: 'DELIVERED', child: Text('DELIVERED (Complete Delivery)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => _selectedTrackerStatus = val);
                      },
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    ),

                    if (_selectedTrackerStatus == 'DELIVERED') ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final file = await _picker.pickImage(source: ImageSource.gallery);
                          if (file != null) setDialogState(() => _signatureImage = file);
                        },
                        icon: const Icon(Icons.draw, size: 16),
                        label: Text(_signatureImage == null ? 'Attach Signature Proof' : 'Signature Attached'),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final file = await _picker.pickImage(source: ImageSource.camera);
                          if (file != null) setDialogState(() => _photoImage = file);
                        },
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: Text(_photoImage == null ? 'Take Photo Proof' : 'Photo Captured'),
                      ),
                    ],

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isUpdatingTrip
                          ? null
                          : () async {
                              if (_selectedTrackerStatus == 'DELIVERED' && _signatureImage == null && _photoImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Proof of delivery (Signature or Photo) is recommended when marking as DELIVERED.')),
                                );
                              }

                              setDialogState(() => _isUpdatingTrip = true);
                              try {
                                MultipartFile? sigFile;
                                MultipartFile? photoFile;
                                if (_signatureImage != null) {
                                  sigFile = await MultipartFile.fromFile(_signatureImage!.path, filename: _signatureImage!.name);
                                }
                                if (_photoImage != null) {
                                  photoFile = await MultipartFile.fromFile(_photoImage!.path, filename: _photoImage!.name);
                                }

                                final ok = await ref.read(deliveryTripControllerProvider.notifier).changeStatus(
                                      _searchedTrip!.id,
                                      _selectedTrackerStatus,
                                      sigFile,
                                      photoFile,
                                    );

                                if (mounted && ok) {
                                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Trip status updated successfully!'), backgroundColor: Colors.green),
                                  );
                                }
                              } finally {
                                setDialogState(() => _isUpdatingTrip = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isUpdatingTrip
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Status Update', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  // ── 11. MODAL: VEHICLE STATUS UPDATE ──────────────────────────────
  void _openVehicleStatusModal(VehicleResponseModel vehicle) {
    _selectedVehicleStatus = vehicle.status;
    final isAssigned = vehicle.id != 0 && vehicle.plateNumber.isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.directions_car, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                isAssigned ? 'My Assigned Vehicle' : 'Vehicle Details',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isAssigned) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No vehicle currently assigned to your driver account in system.',
                              style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Plate: ${vehicle.plateNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: vehicle.status == 'AVAILABLE' ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(vehicle.status, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Type: ${vehicle.type}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Capacity: ${vehicle.capacity} tons', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Fuel Level: ${vehicle.fuelLevel}%', style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Update Status:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedVehicleStatus,
                      items: const [
                        DropdownMenuItem(value: 'AVAILABLE', child: Text('AVAILABLE (Ready)')),
                        DropdownMenuItem(value: 'ON_TRIP', child: Text('ON_TRIP (Dispatched)')),
                        DropdownMenuItem(value: 'MAINTENANCE', child: Text('MAINTENANCE (Workshop)')),
                        DropdownMenuItem(value: 'OUT_OF_SERVICE', child: Text('OUT_OF_SERVICE (Decommissioned)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => _selectedVehicleStatus = val);
                      },
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            if (isAssigned)
              ElevatedButton(
                onPressed: _isUpdatingVehicle
                    ? null
                    : () async {
                        setDialogState(() => _isUpdatingVehicle = true);
                        try {
                          final req = VehicleRequestModel(
                            plateNumber: vehicle.plateNumber,
                            type: vehicle.type,
                            capacity: vehicle.capacity,
                            status: _selectedVehicleStatus,
                            fuelLevel: vehicle.fuelLevel,
                            driverId: vehicle.driverId,
                          );

                          final ok = await ref.read(vehicleControllerProvider.notifier).updateVehicle(vehicle.id, req);
                          if (mounted && ok) {
                            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vehicle status updated successfully!'), backgroundColor: Colors.green),
                            );
                          }
                        } finally {
                          setDialogState(() => _isUpdatingVehicle = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                child: _isUpdatingVehicle
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Commit Status'),
              ),
          ],
        ),
      ),
    );
  }
}
