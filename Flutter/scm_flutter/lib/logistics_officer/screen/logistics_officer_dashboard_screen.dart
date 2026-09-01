import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/logistics_officer/provider/delivery_trip_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/good_received_note_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/inventory_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/stock_movement_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/vehicle_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/warehouse_provider.dart';
import 'package:scm_flutter/qc_inspactor/provider/qc_inspection_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/inventory_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/stock_movement_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/delivery_trip_data_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/vehicle_data_screen.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_inspection_data_screen.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

extension ShipmentStatusExt on ShipmentResponseModel {
  String get status {
    if (podFileUrl.isNotEmpty) return 'DELIVERED';
    if (shipmentNumber.isNotEmpty) return 'IN_TRANSIT';
    return 'PENDING';
  }

  String get destination {
    if (sendByAddress.isNotEmpty) return sendByAddress;
    if (origin.isNotEmpty) return origin;
    return 'Dhaka';
  }

  String get receiverName {
    if (supplierName.isNotEmpty) return supplierName;
    return 'Apex Logistics';
  }
}

class LogisticsOfficerDashboardScreen extends ConsumerStatefulWidget {
  const LogisticsOfficerDashboardScreen({super.key});

  @override
  ConsumerState<LogisticsOfficerDashboardScreen> createState() => _LogisticsOfficerDashboardScreenState();
}

class _LogisticsOfficerDashboardScreenState extends ConsumerState<LogisticsOfficerDashboardScreen> {
  int selectedPerformanceMonth = DateTime.now().month - 1;
  int selectedPerformanceYear = DateTime.now().year;

  final List<Map<String, dynamic>> monthsList = const [
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
  Widget build(BuildContext context) {
    // ── Watch Riverpod Async Providers ──
    final currentUser = ref.watch(currentUserProvider);
    final shipmentsAsync = ref.watch(shipmentListProvider);
    final inventoryAsync = ref.watch(inventoryListProvider);
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final tripsAsync = ref.watch(deliveryTripListProvider);
    final warehousesAsync = ref.watch(warehouseListProvider);
    final stockMovementsAsync = ref.watch(stockMovementListProvider);
    final grnAsync = ref.watch(goodReceivedNoteListProvider);
    final qcAsync = ref.watch(qcInspectionListProvider);

    final userName = currentUser?.name ?? 'Logistics Officer';

    // ── Extract Data Lists ──
    final shipments = shipmentsAsync.value ?? [];
    final inventory = inventoryAsync.value ?? [];
    final vehicles = vehiclesAsync.value ?? [];
    final trips = tripsAsync.value ?? [];
    final warehouses = warehousesAsync.value ?? [];
    final movements = stockMovementsAsync.value ?? [];
    final grns = grnAsync.value ?? [];
    final qcs = qcAsync.value ?? [];

    // ── Calculate Dynamic KPI Metrics ──
    final totalShipments = shipments.length;
    final activeShipments = shipments.where((s) => s.status == 'IN_TRANSIT' || s.status == 'DISPATCHING' || s.status == 'PENDING').length;
    
    // Date Comparisons for Trends
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    int shipmentsToday = 0;
    int shipmentsYesterday = 0;
    for (final s in shipments) {
      if (s.createdAt.isNotEmpty) {
        final d = DateTime.tryParse(s.createdAt);
        if (d != null) {
          if (d.year == today.year && d.month == today.month && d.day == today.day) {
            shipmentsToday++;
          } else if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
            shipmentsYesterday++;
          }
        }
      }
    }
    int shipmentsTrend = 0;
    if (shipmentsYesterday > 0) {
      shipmentsTrend = (((shipmentsToday - shipmentsYesterday) / shipmentsYesterday) * 100).round();
    } else if (shipmentsToday > 0) {
      shipmentsTrend = 100;
    }

    final lowStockItems = inventory.where((i) => ((i.quantityReserved as num?) ?? 0) <= 5 || ((i.quantityOnHand as num?) ?? 0) <= 10).toList();
    final lowStockCount = lowStockItems.length;

    final totalVehicles = vehicles.length;
    final availableVehicles = vehicles.where((v) => v.status == 'AVAILABLE').length;

    final totalInventoryCount = inventory.fold<int>(0, (sum, i) => sum + (((i.quantityOnHand as num?) ?? 0).toInt()));
    final totalAvailableQty = inventory.fold<int>(0, (sum, i) => sum + (((i.availableQuantity as num?) ?? 0).toInt()));

    // Movements Today Calculation
    int movementsTodayCount = 0;
    int movementsYesterdayCount = 0;
    int inCount = 0;
    int outCount = 0;
    int transferCount = 0;

    for (final m in movements) {
      if (m.movedAt.isNotEmpty) {
        final d = DateTime.tryParse(m.movedAt);
        if (d != null) {
          if (d.year == today.year && d.month == today.month && d.day == today.day) {
            movementsTodayCount++;
            if (m.movementType == 'INWARD') {
              inCount++;
            } else if (m.movementType == 'OUTWARD') {
              outCount++;
            } else {
              transferCount++;
            }
          } else if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
            movementsYesterdayCount++;
          }
        }
      }
    }
    int inventoryTrend = 0;
    if (movementsYesterdayCount > 0) {
      inventoryTrend = (((movementsTodayCount - movementsYesterdayCount) / movementsYesterdayCount) * 100).round();
    } else if (movementsTodayCount > 0) {
      inventoryTrend = 100;
    }

    // Warehouse Aggregate Capacity Calculation
    int aggregateUsed = 0;
    int aggregateCap = 0;
    for (final wh in warehouses) {
      final cap = ((wh.capacity as num?) ?? 0) > 0 ? (wh.capacity as num).toInt() : 1000;
      int used = 0;
      for (final inv in inventory) {
        if (inv.warehouseId == wh.id) {
          used += ((inv.quantityOnHand as num?) ?? 0).toInt();
        }
      }
      aggregateUsed += used;
      aggregateCap += cap;
    }
    final aggregateCapacityPercent = aggregateCap > 0 ? ((aggregateUsed / aggregateCap) * 100).clamp(0, 100).round() : 0;

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(shipmentListProvider);
            ref.invalidate(inventoryListProvider);
            ref.invalidate(vehicleListProvider);
            ref.invalidate(deliveryTripListProvider);
            ref.invalidate(warehouseListProvider);
            ref.invalidate(stockMovementListProvider);
            ref.invalidate(goodReceivedNoteListProvider);
            ref.invalidate(qcInspectionListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. Top Bar
                DynamicScmTopNavBar(
                  onRefresh: () {
                    ref.invalidate(shipmentListProvider);
                    ref.invalidate(inventoryListProvider);
                    ref.invalidate(vehicleListProvider);
                    ref.invalidate(deliveryTripListProvider);
                    ref.invalidate(warehouseListProvider);
                    ref.invalidate(stockMovementListProvider);
                    ref.invalidate(goodReceivedNoteListProvider);
                    ref.invalidate(qcInspectionListProvider);
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ২. Welcome Banner
                      _buildWelcomeBanner(userName),
                      const SizedBox(height: 16),

                      // ৩. KPI Grid (6 Metric Cards)
                      _buildKpiGrid(
                        totalShipments: totalShipments,
                        activeShipments: activeShipments,
                        shipmentsTrend: shipmentsTrend,
                        lowStockCount: lowStockCount,
                        lowStockItems: lowStockItems,
                        totalVehicles: totalVehicles,
                        availableVehicles: availableVehicles,
                        totalStock: totalInventoryCount,
                        availableQty: totalAvailableQty,
                        inventoryTrend: inventoryTrend,
                        warehouseCapacityPercent: aggregateCapacityPercent,
                        usedCapacity: aggregateUsed,
                        totalCapacity: aggregateCap,
                      ),
                      const SizedBox(height: 20),

                      // ৪. Quick Navigation Section
                      Row(
                        children: const [
                          Icon(Icons.grid_view_rounded, color: AppTheme.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Quick Navigation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.dark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildQuickNavigationGrid(context),
                      const SizedBox(height: 20),

                      // ৫. Schedule & Fleet Overview Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 800) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildDispatchScheduleCard(trips)),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildFleetStatusOverviewCard(vehicles)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildDispatchScheduleCard(trips),
                                const SizedBox(height: 16),
                                _buildFleetStatusOverviewCard(vehicles),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // ৬. Shipment Performance, Warehouse Capacity & Inventory Movement Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildShipmentPerformanceCard(shipments)),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildWarehouseCapacityCard(warehouses, inventory)),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildInventoryMovementCard(movements, movementsTodayCount, inCount, outCount, transferCount, inventoryTrend)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildShipmentPerformanceCard(shipments),
                                const SizedBox(height: 16),
                                _buildWarehouseCapacityCard(warehouses, inventory),
                                const SizedBox(height: 16),
                                _buildInventoryMovementCard(movements, movementsTodayCount, inCount, outCount, transferCount, inventoryTrend),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // ৭. Dispatch Queue & Live Tracking Map Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 800) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildDispatchQueueCard(shipments)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildLiveTrackingMapCard(shipments)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildDispatchQueueCard(shipments),
                                const SizedBox(height: 16),
                                _buildLiveTrackingMapCard(shipments),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // ৮. Alerts & Notifications Footer Section
                      const Text('Alerts & Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.dark)),
                      const SizedBox(height: 12),
                      _buildAlertsSection(grns.length, qcs.length, lowStockCount),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }



  // --- WELCOME BANNER ---
  Widget _buildWelcomeBanner(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.tealPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, $userName 👋', style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Logistics Officer', style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.successLight, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: const [
                          CircleAvatar(radius: 3, backgroundColor: AppTheme.success),
                          SizedBox(width: 4),
                          Text('Live System', style: TextStyle(color: AppTheme.success, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping_outlined, color: Colors.white30, size: 48),
        ],
      ),
    );
  }

  // --- KPI GRID (6 Cards) ---
  Widget _buildKpiGrid({
    required int totalShipments,
    required int activeShipments,
    required int shipmentsTrend,
    required int lowStockCount,
    required List<dynamic> lowStockItems,
    required int totalVehicles,
    required int availableVehicles,
    required int totalStock,
    required int availableQty,
    required int inventoryTrend,
    required int warehouseCapacityPercent,
    required int usedCapacity,
    required int totalCapacity,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900 ? 6 : (constraints.maxWidth >= 600 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            _buildKpiCard('OUTBOUND SHIPMENTS', '$totalShipments', 'Active: $activeShipments', Icons.local_shipping, AppTheme.primary, '${shipmentsTrend >= 0 ? '+$shipmentsTrend%' : '$shipmentsTrend%'} vs yesterday'),
            _buildKpiCard('LOW STOCK ALERT', '$lowStockCount', 'Items', Icons.warning_amber_rounded, AppTheme.warning, 'Reserved Quota <= 5'),
            _buildKpiCard('ACTIVE VEHICLES', '$totalVehicles', 'Total', Icons.directions_car, AppTheme.indigo, '$availableVehicles Available'),
            _buildKpiCard('TOTAL STOCK', '$totalStock', 'Units', Icons.layers, AppTheme.tealPrimary, '${inventoryTrend >= 0 ? '+$inventoryTrend%' : '$inventoryTrend%'} vs yesterday'),
            _buildKpiCard('AVAILABLE QUANTITY', '$availableQty', 'Available', Icons.inventory_2_outlined, AppTheme.orange, 'Net available units'),
            _buildKpiCard('WAREHOUSE CAPACITY', '$warehouseCapacityPercent%', 'Utilized', Icons.store, AppTheme.success, '$usedCapacity / $totalCapacity Utilized'),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, String badge, IconData icon, Color color, String subtext) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.dark)),
            ],
          ),
          Text(subtext, style: const TextStyle(fontSize: 8, color: AppTheme.secondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- QUICK NAVIGATION GRID ---
  Widget _buildQuickNavigationGrid(BuildContext context) {
    final navItems = [
      {'title': 'Stock', 'sub': 'Inventory Control', 'icon': Icons.layers, 'color': AppTheme.primary, 'route': '/inventory-data'},
      {'title': 'Stock Movement', 'sub': 'Stock Transfers', 'icon': Icons.swap_horiz, 'color': Colors.cyan, 'route': '/stock-movement-data'},
      {'title': 'Goods Received', 'sub': 'Inbound GRN', 'icon': Icons.download, 'color': AppTheme.success, 'route': '/grn-data'},
      {'title': 'Delivery Trip', 'sub': 'Dispatch Routes', 'icon': Icons.alt_route, 'color': AppTheme.purple, 'route': '/delivery-trip-data'},
      {'title': 'Vehicles', 'sub': 'Fleet Management', 'icon': Icons.directions_bus, 'color': AppTheme.orange, 'route': '/vehicle-data'},
      {'title': 'QC Inspection', 'sub': 'Quality Control Logs', 'icon': Icons.fact_check, 'color': AppTheme.tealPrimary, 'route': '/qc-inspections'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900 ? 6 : (constraints.maxWidth >= 600 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: navItems.map((item) {
            final routeName = item['route'] as String;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (routeName == '/inventory-data') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryDataScreen()));
                } else if (routeName == '/stock-movement-data') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StockMovementDataScreen()));
                } else if (routeName == '/grn-data') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GoodReceivedNoteDataScreen()));
                } else if (routeName == '/delivery-trip-data') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryTripDataScreen()));
                } else if (routeName == '/vehicle-data') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleDataScreen()));
                } else if (routeName == '/qc-inspections') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const QCInspectionDataScreen()));
                } else {
                  Navigator.pushNamed(context, routeName);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderGrey),
                  boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: (item['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.dark)),
                          Text(item['sub'] as String, style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- DISPATCH SCHEDULE ---
  Widget _buildDispatchScheduleCard(List<dynamic> trips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Dispatch Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
              TextButton(
                onPressed: () {},
                child: const Text('View All', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(color: AppTheme.borderGrey),
          trips.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No dispatch trips scheduled', style: TextStyle(fontSize: 11, color: AppTheme.secondary))),
                )
              : Table(
                  columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1.5)},
                  children: [
                    const TableRow(children: [
                      Text('Trip ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      Text('Destination', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      Text('Time', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      Text('Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                    ]),
                    ...trips.take(4).map((t) {
                      final statusStr = t.status.toString();
                      final isPass = statusStr == 'DELIVERED' || statusStr == 'IN_TRANSIT';
                      return TableRow(children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('#TR-${t.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t.customerAddress.isNotEmpty ? t.customerAddress : (t.recipientName.isNotEmpty ? t.recipientName : 'Dhaka'), style: const TextStyle(fontSize: 11, color: AppTheme.dark))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t.startedAt != null ? t.startedAt.toString().split('T').first : '10:30 AM', style: const TextStyle(fontSize: 11, color: AppTheme.secondary))),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPass ? AppTheme.successLight : AppTheme.warningLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusStr,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isPass ? AppTheme.success : AppTheme.warning),
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  // --- FLEET STATUS OVERVIEW ---
  Widget _buildFleetStatusOverviewCard(List<dynamic> vehicles) {
    final availableCount = vehicles.where((v) => v.status == 'AVAILABLE').length;
    final onRouteCount = vehicles.where((v) => v.status == 'IN_TRANSIT' || v.status == 'ON_ROUTE').length;
    final maintenanceCount = vehicles.where((v) => v.status == 'MAINTENANCE').length;
    final offlineCount = vehicles.where((v) => v.status == 'OFFLINE' || v.status == 'INACTIVE').length;
    final total = vehicles.isNotEmpty ? vehicles.length : 1;

    final availPct = ((availableCount / total) * 100).round();
    final routePct = ((onRouteCount / total) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fleet Status Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: availableCount / total,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.warning,
                    color: AppTheme.success,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${vehicles.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                    const Text('Total Vehicles', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFleetDot(AppTheme.success, 'Available ($availableCount, $availPct%)'),
              _buildFleetDot(AppTheme.primary, 'On Route ($onRouteCount, $routePct%)'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFleetDot(AppTheme.warning, 'Maint ($maintenanceCount)'),
              _buildFleetDot(AppTheme.danger, 'Offline ($offlineCount)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFleetDot(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: AppTheme.dark)),
      ],
    );
  }

  // --- SHIPMENT PERFORMANCE ---
  Widget _buildShipmentPerformanceCard(List<ShipmentResponseModel> shipments) {
    final selectedMonthObj = monthsList.firstWhere((m) => m['value'] == selectedPerformanceMonth, orElse: () => monthsList[7]);
    final monthLabel = selectedMonthObj['label'] as String;

    final monthShipments = shipments.where((s) {
      if (s.createdAt.isEmpty) return false;
      final d = DateTime.tryParse(s.createdAt);
      if (d == null) return false;
      return d.month == selectedPerformanceMonth + 1 && d.year == selectedPerformanceYear;
    }).toList();

    final targetList = monthShipments.isEmpty ? shipments : monthShipments;
    final totalCount = targetList.length;
    final deliveredCount = targetList.where((s) => s.status == 'DELIVERED').length;
    final inTransitCount = targetList.where((s) => s.status == 'IN_TRANSIT' || s.status == 'DISPATCHING').length;
    final delayedCount = targetList.where((s) => s.status == 'DELAYED').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipment Performance ($monthLabel)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
              DropdownButton<int>(
                value: selectedPerformanceMonth,
                items: monthsList.map((m) => DropdownMenuItem<int>(value: m['value'] as int, child: Text(m['label'] as String, style: const TextStyle(fontSize: 11)))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selectedPerformanceMonth = val);
                  }
                },
                underline: const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PerfMetric('Total', '$totalCount', '+18%'),
              _PerfMetric('Delivered', '$deliveredCount', '+22%'),
              _PerfMetric('In Transit', '$inTransitCount', '-5%'),
              _PerfMetric('Delayed', '$delayedCount', '-33%'),
            ],
          ),
        ],
      ),
    );
  }

  // --- WAREHOUSE CAPACITY ---
  Widget _buildWarehouseCapacityCard(List<dynamic> warehouses, List<dynamic> inventory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Warehouse Capacity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(color: AppTheme.borderGrey),
          const SizedBox(height: 8),
          warehouses.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('No warehouse facilities logged', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                )
              : Column(
                  children: warehouses.take(2).map((wh) {
                    final cap = (wh.capacity != null && ((wh.capacity as num?) ?? 0) > 0) ? (wh.capacity as num).toInt() : 1000;
                    int used = 0;
                    for (final inv in inventory) {
                      if (inv.warehouseId == wh.id) {
                        used += ((inv.quantityOnHand as num?) ?? 0).toInt();
                      }
                    }
                    final pct = cap > 0 ? ((used / cap) * 100).clamp(0, 100).round() : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(wh.name.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                              Text('$pct% ($used / $cap)', style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: AppTheme.light,
                            color: pct >= 90 ? AppTheme.danger : (pct >= 70 ? AppTheme.warning : AppTheme.success),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // --- INVENTORY MOVEMENT ---
  Widget _buildInventoryMovementCard(List<dynamic> movements, int movementsTodayCount, int inCount, int outCount, int transferCount, int inventoryTrend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inventory Movement (Today)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('$movementsTodayCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                const Text('Total Movements', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('In: $inCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success)),
              Text('Out: $outCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              Text('Shift: $transferCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.warning)),
            ],
          ),
        ],
      ),
    );
  }

  // --- DISPATCH QUEUE ---
  Widget _buildDispatchQueueCard(List<ShipmentResponseModel> shipments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dispatch Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
          const Divider(color: AppTheme.borderGrey),
          shipments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('No active shipments in queue', style: TextStyle(fontSize: 11, color: AppTheme.secondary))),
                )
              : Table(
                  columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1)},
                  children: [
                    const TableRow(children: [
                      Text('Shipment ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      Text('Customer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      Text('Destination', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      Text('Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                    ]),
                    ...shipments.take(3).map((s) => TableRow(children: [
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s.shipmentNumber.isNotEmpty ? s.shipmentNumber : '#SHP-${s.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s.receiverName, style: const TextStyle(fontSize: 11, color: AppTheme.dark))),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s.destination, style: const TextStyle(fontSize: 11, color: AppTheme.secondary))),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: s.status == 'DELIVERED' ? AppTheme.success : AppTheme.warning))),
                        ])),
                  ],
                ),
        ],
      ),
    );
  }

  // --- LIVE TRACKING MAP ---
  Widget _buildLiveTrackingMapCard(List<ShipmentResponseModel> shipments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Live Tracking Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
              Text('5 Active Nodes', style: TextStyle(fontSize: 10, color: AppTheme.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: AppTheme.borderGrey),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.light,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  left: 20,
                  child: _buildMapNodeBadge('Rajshahi', AppTheme.primary),
                ),
                Positioned(
                  top: 15,
                  right: 20,
                  child: _buildMapNodeBadge('Sylhet', AppTheme.primary),
                ),
                Positioned(
                  bottom: 15,
                  left: 20,
                  child: _buildMapNodeBadge('Khulna', AppTheme.primary),
                ),
                Positioned(
                  bottom: 15,
                  right: 20,
                  child: _buildMapNodeBadge('Chattogram', AppTheme.primary),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
                        child: const Icon(Icons.local_shipping, color: AppTheme.surfaceWhite, size: 20),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.surfaceWhite, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.borderGrey)),
                        child: const Text('Dhaka Central Hub', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapNodeBadge(String name, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppTheme.surfaceWhite, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.borderGrey)),
          child: Text(name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.dark)),
        ),
        const SizedBox(height: 2),
        CircleAvatar(radius: 4, backgroundColor: color),
      ],
    );
  }

  // --- ALERTS SECTION ---
  Widget _buildAlertsSection(int grnCount, int qcCount, int lowStockCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Row(
            children: [
              Expanded(child: _buildAlertBox('Goods Received Notes', '$grnCount Inbound GRNs logged.', Icons.download, AppTheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildAlertBox('Low Stock Alert', '$lowStockCount items low on stock.', Icons.warning, AppTheme.warning)),
              const SizedBox(width: 12),
              Expanded(child: _buildAlertBox('QC Inspections Logged', '$qcCount Quality control records.', Icons.check_circle, AppTheme.success)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildAlertBox('Goods Received Notes', '$grnCount Inbound GRNs logged.', Icons.download, AppTheme.primary),
              const SizedBox(height: 8),
              _buildAlertBox('Low Stock Alert', '$lowStockCount items low on stock.', Icons.warning, AppTheme.warning),
              const SizedBox(height: 8),
              _buildAlertBox('QC Inspections Logged', '$qcCount Quality control records.', Icons.check_circle, AppTheme.success),
            ],
          );
        }
      },
    );
  }

  Widget _buildAlertBox(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.dark)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM NAV BAR ---
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.dashboard, 'Dashboard', true, '/logistics-dashboard'),
          _buildNavItem(context, Icons.local_shipping, 'Shipments', false, '/customer-orders'),
          _buildNavItem(context, Icons.alt_route, 'Trips', false, '/customer-orders'),
          _buildNavItem(context, Icons.fact_check, 'QC Logs', false, '/qc-inspections'),
          _buildNavItem(context, Icons.person, 'Profile', false, '/driver-profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, String routeName) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          if (routeName == '/qc-inspections') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QCInspectionDataScreen()));
          } else {
            Navigator.pushNamed(context, routeName);
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? AppTheme.primary : AppTheme.secondary, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppTheme.primary : AppTheme.secondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfMetric extends StatelessWidget {
  final String label;
  final String val;
  final String trend;

  const _PerfMetric(this.label, this.val, this.trend);

  @override
  Widget build(BuildContext context) {
    final isPos = trend.startsWith('+');
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dark)),
            const SizedBox(width: 4),
            Text(
              trend,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isPos ? AppTheme.success : AppTheme.danger),
            ),
          ],
        ),
      ],
    );
  }
}