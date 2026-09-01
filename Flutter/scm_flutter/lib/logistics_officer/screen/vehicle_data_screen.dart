import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/driver/provider/driver_provider.dart';
import 'package:scm_flutter/entity/vehicle_model.dart';
import 'package:scm_flutter/logistics_officer/provider/vehicle_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/vehicle_form_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class VehicleDataScreen extends ConsumerStatefulWidget {
  const VehicleDataScreen({super.key});

  @override
  ConsumerState<VehicleDataScreen> createState() => _VehicleDataScreenState();
}

class _VehicleDataScreenState extends ConsumerState<VehicleDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppTheme.success;
      case 'ON_TRIP':
        return AppTheme.primary;
      case 'MAINTENANCE':
        return AppTheme.warning;
      case 'OUT_OF_SERVICE':
        return AppTheme.danger;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppTheme.successLight;
      case 'ON_TRIP':
        return AppTheme.light;
      case 'MAINTENANCE':
        return AppTheme.warningLight;
      case 'OUT_OF_SERVICE':
        return AppTheme.dangerLight;
      default:
        return AppTheme.light;
    }
  }

  Color _getFuelColor(double fuel) {
    if (fuel > 50) return AppTheme.success;
    if (fuel >= 20) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentDriverAsync = ref.watch(currentDriverProvider);

    final userRole = currentUser?.role.toUpperCase() ?? '';
    final isDriver = userRole == 'DRIVER' || userRole == 'ROLE_DRIVER';
    final isProcurement = userRole == 'PROCUREMENT' || userRole == 'ROLE_PROCUREMENT';
    final actualDriverId = currentDriverAsync.value?.id;

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Corporate Fleet Asset Matrix',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      floatingActionButton: !isProcurement
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
              ),
              backgroundColor: AppTheme.tealPrimary,
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.surfaceWhite),
              label: const Text(
                'Register Vehicle Hub',
                style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vehicleListProvider);
          ref.invalidate(driverListProvider);
        },
        child: vehiclesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load corporate fleet asset matrix: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(vehicleListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (allVehicles) {
            List<VehicleResponseModel> vehicles = allVehicles;
            if (isDriver && actualDriverId != null) {
              vehicles = allVehicles.where((v) => v.driverId == actualDriverId).toList();
            }

            final filteredList = vehicles.where((v) {
              final matchesSearch = _searchQuery.isEmpty ||
                  'FLEET-${v.id}'.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  v.plateNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  v.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  v.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (v.driverName != null && v.driverName!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                  (v.driverPhone != null && v.driverPhone!.toLowerCase().contains(_searchQuery.toLowerCase()));

              final matchesFilter = _selectedStatusFilter == 'ALL' ||
                  v.status.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesFilter;
            }).toList();

            int totalCount = vehicles.length;
            int availableCount = vehicles.where((v) => v.status == 'AVAILABLE').length;
            int onTripCount = vehicles.where((v) => v.status == 'ON_TRIP').length;
            int maintenanceCount = vehicles.where((v) => v.status == 'MAINTENANCE').length;
            int outOfServiceCount = vehicles.where((v) => v.status == 'OUT_OF_SERVICE').length;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ১. Summary Metrics Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.tealDark, AppTheme.tealPrimary, AppTheme.dark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.directions_bus, color: AppTheme.surfaceWhite, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'CORPORATE FLEET LOGISTICS MATRIX',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track capacity weight, fuel levels, workshop service dates, and bound driver links.',
                          style: TextStyle(color: AppTheme.surfaceWhite.withValues(alpha: 0.8), fontSize: 10),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildBannerMetric('Total Fleet', '$totalCount', AppTheme.surfaceWhite)),
                            Expanded(child: _buildBannerMetric('Available', '$availableCount', AppTheme.success)),
                            Expanded(child: _buildBannerMetric('On Trip', '$onTripCount', AppTheme.primaryLight)),
                            Expanded(child: _buildBannerMetric('Maintenance', '$maintenanceCount', AppTheme.warning)),
                            Expanded(child: _buildBannerMetric('Out of Service', '$outOfServiceCount', AppTheme.danger)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ২. Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by Plate#, Type, Driver Name, Phone, Status...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.secondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.tealPrimary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ৩. Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Assets ($totalCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('AVAILABLE', 'Available ($availableCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('ON_TRIP', 'On Trip ($onTripCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('MAINTENANCE', 'Maintenance ($maintenanceCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('OUT_OF_SERVICE', 'Out of Service ($outOfServiceCount)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ৪. Data List Cards
                  if (filteredList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.directions_bus_outlined, size: 48, color: AppTheme.secondary),
                          SizedBox(height: 12),
                          Text('No vehicular fleet logistics metrics localized in datastore contexts.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or status filter.', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final vehicle = filteredList[index];
                        final stColor = _getStatusColor(vehicle.status);
                        final stBg = _getStatusBg(vehicle.status);
                        final fuelColor = _getFuelColor(vehicle.fuelLevel);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderGrey),
                            boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: FLEET ID & Status Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'FLEET-${vehicle.id}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.surfaceWhite),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: stBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: stColor)),
                                    child: Text(
                                      vehicle.status,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Plate Number & Vehicle Type Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.numbers, size: 16, color: AppTheme.secondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        vehicle.plateNumber,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.light,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.borderGrey),
                                    ),
                                    child: Text(
                                      vehicle.type.toUpperCase(),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Max Capacity & Fuel Level Bar
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.fitness_center, size: 14, color: AppTheme.indigo),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Cap: ${vehicle.capacity.toStringAsFixed(0)} KG',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.local_gas_station, size: 14, color: AppTheme.secondary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: (vehicle.fuelLevel / 100).clamp(0.0, 1.0),
                                              backgroundColor: AppTheme.borderGrey,
                                              valueColor: AlwaysStoppedAnimation<Color>(fuelColor),
                                              minHeight: 6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${vehicle.fuelLevel.toStringAsFixed(0)}%',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fuelColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Bound Driver Information
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: AppTheme.tealPrimary),
                                  const SizedBox(width: 4),
                                  if (vehicle.driverId != null)
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Bound Driver: ${vehicle.driverName ?? "Captain #${vehicle.driverId}"}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
                                          ),
                                          if (vehicle.driverPhone != null && vehicle.driverPhone!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${vehicle.driverPhone})',
                                              style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                            ),
                                          ],
                                        ],
                                      ),
                                    )
                                  else
                                    const Text(
                                      'Unassigned / Standby Vehicle',
                                      style: TextStyle(fontSize: 10, color: AppTheme.secondary, fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                              if (vehicle.lastServiceDate != null && vehicle.lastServiceDate!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.build_circle_outlined, size: 13, color: AppTheme.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Last Workshop Audit: ${vehicle.lastServiceDate}',
                                      style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderGrey),
                              const SizedBox(height: 6),

                              // Bottom Row Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    tooltip: 'Quick Change Maintenance Status',
                                    icon: const Icon(Icons.shield_outlined, color: AppTheme.success, size: 18),
                                    onPressed: () => _openStatusModal(context, vehicle),
                                  ),
                                  if (!isProcurement) ...[
                                    IconButton(
                                      tooltip: 'Modify Vehicle Asset Parameters',
                                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VehicleFormScreen(vehicleToEdit: vehicle),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Decommission Asset',
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Decommission Vehicle Asset?'),
                                            content: Text('Are you sure you want to decommission fleet vehicle ${vehicle.plateNumber}?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Decommission', style: TextStyle(color: AppTheme.danger))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await ref.read(vehicleControllerProvider.notifier).deleteVehicle(vehicle.id);
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBannerMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.surfaceWhite.withValues(alpha: 0.7), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildFilterChip(String statusKey, String label) {
    final isSelected = _selectedStatusFilter == statusKey;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isSelected ? AppTheme.surfaceWhite : AppTheme.dark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: AppTheme.surfaceWhite,
      selectedColor: AppTheme.tealPrimary,
      checkmarkColor: AppTheme.surfaceWhite,
      side: BorderSide(color: isSelected ? AppTheme.tealPrimary : AppTheme.borderGrey),
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? statusKey : 'ALL';
        });
      },
    );
  }

  void _openStatusModal(BuildContext context, VehicleResponseModel vehicle) {
    String selectedStatus = vehicle.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Patch Fleet Workshop Console', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configure Target Vehicle State Flag (${vehicle.plateNumber})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'AVAILABLE', child: Text('🟢 AVAILABLE (Ready for Mission)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'ON_TRIP', child: Text('🔵 ON_TRIP (Dispatched Node)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'MAINTENANCE', child: Text('🟡 MAINTENANCE (Workshop Maintenance)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'OUT_OF_SERVICE', child: Text('🔴 OUT_OF_SERVICE (Decommissioned)', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) => setDialogState(() => selectedStatus = val ?? vehicle.status),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tealPrimary),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final patchPayload = VehicleRequestModel(
                    plateNumber: vehicle.plateNumber,
                    type: vehicle.type,
                    capacity: vehicle.capacity,
                    status: selectedStatus.toUpperCase(),
                    lastServiceDate: vehicle.lastServiceDate,
                    fuelLevel: vehicle.fuelLevel,
                    driverId: vehicle.driverId,
                  );

                  await ref.read(vehicleControllerProvider.notifier).updateVehicle(
                    vehicle.id,
                    patchPayload,
                  );
                },
                icon: const Icon(Icons.check_circle, color: AppTheme.surfaceWhite, size: 16),
                label: const Text('Commit Status', style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
