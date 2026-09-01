import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/procourment/screen/shipment_pdf_screen.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/suppplier/screen/shipment_form_screen.dart';
import 'package:scm_flutter/suppplier/screen/shipment_update_form_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class ShipmentDataScreen extends ConsumerStatefulWidget {
  const ShipmentDataScreen({super.key});

  @override
  ConsumerState<ShipmentDataScreen> createState() => _ShipmentDataScreenState();
}

class _ShipmentDataScreenState extends ConsumerState<ShipmentDataScreen> {
  String searchShipmentNo = '';
  String searchPoRef = '';
  String searchSupplierName = '';
  String searchVehicle = '';

  void _deleteShipment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this cargo shipment entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(shipmentControllerProvider.notifier).deleteShipment(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Cargo shipment deleted successfully' : 'Failed to delete shipment'),
            backgroundColor: success ? AppTheme.success : AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentListAsync = ref.watch(shipmentListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);
    final currentUser = ref.watch(currentUserProvider);

    final userRole = (currentUser?.role ?? 'PROCUREMENT').toUpperCase();
    final suppliers = suppliersAsync.value ?? [];
    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: DynamicScmTopNavBar(
        title: 'Cargo Shipment Log',
        showBackButton: true,
        onRefresh: () => ref.invalidate(shipmentListProvider),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(shipmentListProvider),
          child: Column(
            children: [
              // ── 1. Header Title & Summary Banner ──
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Cargo Consignment Freight Logistics',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 28.0),
                      child: Text(
                        'Track cargo shipments, vehicle registration, origin/destination vectors, transport costs, and proof of delivery.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white54)),
                          ),
                          icon: const Icon(Icons.autorenew, size: 14),
                          label: const Text('Update Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ShipmentUpdateFormScreen()),
                            );
                          },
                        ),
                        if (userRole == 'SUPPLIER') ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Create', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ShipmentFormScreen()),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── 2. Multi-Vector Search Controls (Android Responsive) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final shpSearch = TextField(
                      decoration: _searchDecoration(hint: 'Search Shipment No...'),
                      onChanged: (val) => setState(() => searchShipmentNo = val),
                    );

                    final poSearch = TextField(
                      decoration: _searchDecoration(hint: 'Search PO Ref...'),
                      onChanged: (val) => setState(() => searchPoRef = val),
                    );

                    final supSearch = TextField(
                      decoration: _searchDecoration(hint: 'Search Supplier...'),
                      onChanged: (val) => setState(() => searchSupplierName = val),
                    );

                    final vehicleSearch = TextField(
                      decoration: _searchDecoration(hint: 'Search Vehicle / Reg...'),
                      onChanged: (val) => setState(() => searchVehicle = val),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: shpSearch),
                              const SizedBox(width: 8),
                              Expanded(child: poSearch),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (userRole != 'SUPPLIER') ...[
                                Expanded(child: supSearch),
                                const SizedBox(width: 8),
                              ],
                              Expanded(child: vehicleSearch),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: shpSearch),
                        const SizedBox(width: 8),
                        Expanded(child: poSearch),
                        if (userRole != 'SUPPLIER') ...[
                          const SizedBox(width: 8),
                          Expanded(child: supSearch),
                        ],
                        const SizedBox(width: 8),
                        Expanded(child: vehicleSearch),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── 3. Cargo Shipments List ──
              Expanded(
                child: shipmentListAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                          const SizedBox(height: 12),
                          Text('Failed to load shipments: $err', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(shipmentListProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (shipments) {
                    List<ShipmentResponseModel> roleFiltered = shipments;

                    // Role-based data isolation for Suppliers
                    if (userRole == 'SUPPLIER' && currentSupplier != null) {
                      final supName = currentSupplier.name.trim().toLowerCase();
                      roleFiltered = shipments.where((s) {
                        final isSupplierIdMatch = s.supplierId == currentSupplier.id;
                        final isSupplierNameMatch = supName.isNotEmpty && s.supplierName.trim().toLowerCase() == supName;
                        return isSupplierIdMatch || isSupplierNameMatch;
                      }).toList();
                    }

                    // Apply Search Filters
                    final filtered = roleFiltered.where((s) {
                      final shpNo = (s.shipmentNumber.isNotEmpty ? s.shipmentNumber : '#SHP-${s.id}').toLowerCase();
                      final poRefStr = 'po ref #${s.poId}'.toLowerCase();
                      final supName = s.supplierName.toLowerCase();
                      final vehicle = '${s.vehicleNumber} ${s.captainRegistrationNumber}'.toLowerCase();

                      final matchesShp = searchShipmentNo.isEmpty || shpNo.contains(searchShipmentNo.toLowerCase().trim());
                      final matchesPo = searchPoRef.isEmpty || poRefStr.contains(searchPoRef.toLowerCase().trim()) || s.poId.toString() == searchPoRef.trim();
                      final matchesSup = searchSupplierName.isEmpty || supName.contains(searchSupplierName.toLowerCase().trim());
                      final matchesVehicle = searchVehicle.isEmpty || vehicle.contains(searchVehicle.toLowerCase().trim());

                      return matchesShp && matchesPo && matchesSup && matchesVehicle;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 48, color: AppTheme.secondary),
                              SizedBox(height: 8),
                              Text('No cargo shipments match your criteria.', style: TextStyle(color: AppTheme.secondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        final estDate = s.estimatedDelivery.contains('T')
                            ? s.estimatedDelivery.split('T').first
                            : (s.estimatedDelivery.isNotEmpty ? s.estimatedDelivery : 'N/A');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
                            border: Border.all(color: AppTheme.light),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Shipment Badge & PO Ref
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.dark,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      s.shipmentNumber.isNotEmpty ? s.shipmentNumber : '#SHP-${s.id}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'PO Ref #${s.poId}',
                                      style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Supplier & Origin Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.supplierName.isNotEmpty ? s.supplierName : 'Supplier #${s.supplierId}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.danger),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                'Origin: ${s.origin.isNotEmpty ? s.origin : "N/A"}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${s.transportCost.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary, fontFamily: 'monospace'),
                                      ),
                                      const Text('Freight Transport Cost', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                ],
                              ),

                              const Divider(height: 16),

                              // Vehicle & Delivery Info Grid (Responsive Expanded)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.directions_bus_outlined, size: 14, color: AppTheme.secondary),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                s.vehicleNumber.isNotEmpty ? s.vehicleNumber : 'N/A',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.dark, fontFamily: 'monospace'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Reg: ${s.captainRegistrationNumber.isNotEmpty ? s.captainRegistrationNumber : "N/A"}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 9, color: AppTheme.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${s.shipmentQuantity} Units',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.dark, fontFamily: 'monospace'),
                                        ),
                                        const Text('Consignment Volume', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Icon(Icons.calendar_today, size: 12, color: AppTheme.danger),
                                            const SizedBox(width: 3),
                                            Flexible(
                                              child: Text(
                                                estDate,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.danger, fontFamily: 'monospace'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Text('Est Delivery Date', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Destination Address
                              if (s.sendByAddress.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.navigation_outlined, size: 12, color: AppTheme.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Destination: ${s.sendByAddress}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: AppTheme.dark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Bottom Action Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Assigned By: ${s.assignedByEmail.isNotEmpty ? s.assignedByEmail : "System"}',
                                    style: const TextStyle(fontSize: 9, color: AppTheme.secondary, fontStyle: FontStyle.italic),
                                  ),
                                   Row(
                                     children: [
                                       _buildActionButton(
                                         icon: Icons.picture_as_pdf,
                                         color: const Color(0xFF1E3A8A),
                                         onTap: () {
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(builder: (_) => ShipmentPDFScreen(shipment: s)),
                                           );
                                         },
                                       ),
                                       const SizedBox(width: 8),
                                       if (s.podFileUrl.isNotEmpty) ...[
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.teal,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          icon: const Icon(Icons.description, size: 12),
                                          label: const Text('POD File', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('POD File URL: ${s.podFileUrl}')),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (userRole == 'ADMIN' || userRole == 'MANAGER' || userRole == 'PROCUREMENT') ...[
                                        _buildActionButton(
                                          icon: Icons.delete_outline,
                                          color: AppTheme.danger,
                                          onTap: () => _deleteShipment(s.id),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: userRole == 'SUPPLIER'
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.local_shipping),
              label: const Text('Add Shipment', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShipmentFormScreen()),
                );
              },
            )
          : null,
    );
  }

  InputDecoration _searchDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: AppTheme.secondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
