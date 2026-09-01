import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/delivery_trip_model.dart';
import 'package:scm_flutter/logistics_officer/provider/delivery_trip_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/delivery_trip_form_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/delivery_trip_pdf_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class DeliveryTripDataScreen extends ConsumerStatefulWidget {
  const DeliveryTripDataScreen({super.key});

  @override
  ConsumerState<DeliveryTripDataScreen> createState() => _DeliveryTripDataScreenState();
}

class _DeliveryTripDataScreenState extends ConsumerState<DeliveryTripDataScreen> {
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
      case 'PENDING':
        return AppTheme.secondary;
      case 'IN_TRANSIT':
        return AppTheme.warning;
      case 'DELIVERED':
        return AppTheme.success;
      case 'CANCELLED':
        return AppTheme.danger;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppTheme.light;
      case 'IN_TRANSIT':
        return AppTheme.warningLight;
      case 'DELIVERED':
        return AppTheme.successLight;
      case 'CANCELLED':
        return AppTheme.dangerLight;
      default:
        return AppTheme.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(deliveryTripListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userRole = currentUser?.role.toUpperCase() ?? '';
    final canConsoleActions = userRole == 'ADMIN' || userRole == 'LOGISTICS_OFFICER' || userRole == 'ROLE_ADMIN' || userRole == 'ROLE_LOGISTICS_OFFICER';
    final canStatusActions = canConsoleActions || userRole == 'DRIVER' || userRole == 'ROLE_DRIVER';

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Fleet Delivery Trip Matrix',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      floatingActionButton: canConsoleActions
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeliveryTripFormScreen()),
              ),
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.add_location_alt_outlined, color: AppTheme.surfaceWhite),
              label: const Text(
                'Dispatch New Route',
                style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(deliveryTripListProvider);
        },
        child: tripsAsync.when(
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
                    'Failed to load delivery trips matrix: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(deliveryTripListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (allTrips) {
            final isDriverRole = userRole == 'DRIVER' || userRole == 'ROLE_DRIVER';
            final trips = allTrips.where((t) {
              if (!isDriverRole) return true; // Admins / Logistics Officers see all
              if (currentUser == null) return true;
              final matchId = t.driverId == currentUser.userId;
              final matchEmail = t.driverEmail.isNotEmpty && t.driverEmail.toLowerCase() == currentUser.email.toLowerCase();
              final matchName = t.driverName.isNotEmpty && t.driverName.toLowerCase() == currentUser.name.toLowerCase();
              return matchId || matchEmail || matchName;
            }).toList();

            final filteredList = trips.where((t) {
              final matchesSearch = _searchQuery.isEmpty ||
                  'TRIP-#${t.id}'.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.recipientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.driverName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.vehiclePlateNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.customerAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.status.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesFilter = _selectedStatusFilter == 'ALL' ||
                  t.status.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesFilter;
            }).toList();

            int pendingCount = trips.where((t) => t.status == 'PENDING').length;
            int transitCount = trips.where((t) => t.status == 'IN_TRANSIT').length;
            int deliveredCount = trips.where((t) => t.status == 'DELIVERED').length;
            int cancelledCount = trips.where((t) => t.status == 'CANCELLED').length;

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
                        colors: [AppTheme.purple, AppTheme.dark],
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
                            Icon(Icons.alt_route, color: AppTheme.surfaceWhite, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'FLEET DISPATCH & DELIVERY TRIP MATRIX SUMMARY',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildBannerMetric('Total Trips', '${trips.length}', AppTheme.surfaceWhite)),
                            Expanded(child: _buildBannerMetric('Pending', '$pendingCount', AppTheme.secondary)),
                            Expanded(child: _buildBannerMetric('In Transit', '$transitCount', AppTheme.warning)),
                            Expanded(child: _buildBannerMetric('Delivered', '$deliveredCount', AppTheme.success)),
                            Expanded(child: _buildBannerMetric('Cancelled', '$cancelledCount', AppTheme.danger)),
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
                      hintText: 'Search by Trip#, Consignee, Captain, Vehicle Plate, Address...',
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
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ৩. Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Trips (${trips.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip('PENDING', 'Pending ($pendingCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('IN_TRANSIT', 'In Transit ($transitCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('DELIVERED', 'Delivered ($deliveredCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('CANCELLED', 'Cancelled ($cancelledCount)'),
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
                          Icon(Icons.alt_route_outlined, size: 48, color: AppTheme.secondary),
                          SizedBox(height: 12),
                          Text('No deployment tracking maps localized in matrix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark)),
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
                        final item = filteredList[index];
                        final stColor = _getStatusColor(item.status);
                        final stBg = _getStatusBg(item.status);

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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.dark,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'TRIP-#${item.id}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.surfaceWhite),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: stBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: stColor)),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Consignee: ${item.recipientName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: AppTheme.danger),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.customerAddress,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.secondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.badge, size: 14, color: AppTheme.secondary),
                                      const SizedBox(width: 4),
                                      Text('Captain: ${item.driverName}', style: const TextStyle(fontSize: 11, color: AppTheme.dark, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.light,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.borderGrey),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.directions_car, size: 12, color: AppTheme.primary),
                                        const SizedBox(width: 4),
                                        Text(item.vehiclePlateNumber, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Start: ${item.startedAt ?? "Not Triggered"}  |  Completed: ${item.completedAt ?? "In-flight"}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (item.recipientSignature != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppTheme.infoLight, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('✍️ SIG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                                    ),
                                  if (item.deliveryPhotoUrl != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppTheme.successLight, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('📷 POD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.success)),
                                    ),
                                  if (item.recipientSignature == null && item.deliveryPhotoUrl == null)
                                    const Text('No attached POD docs', style: TextStyle(fontSize: 10, color: AppTheme.secondary, fontStyle: FontStyle.italic)),
                                ],
                              ),
                              if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Remarks: ${item.remarks}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderGrey),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Dispatcher ID: #${item.dispatcherId}', style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                  Row(
                                    children: [
                                      if (canStatusActions)
                                        IconButton(
                                          tooltip: 'Patch Transit Status & POD Files',
                                          icon: const Icon(Icons.shield_outlined, color: AppTheme.success, size: 18),
                                          onPressed: () => _showStatusPatchModal(context, item),
                                        ),
                                      IconButton(
                                        tooltip: 'Preview Delivery PDF',
                                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.danger, size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DeliveryTripFormPDFScreen(trip: item),
                                          ),
                                        ),
                                      ),
                                      if (canConsoleActions)
                                        IconButton(
                                          tooltip: 'Modify Manifest Settings',
                                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DeliveryTripFormScreen(tripToEdit: item),
                                            ),
                                          ),
                                        ),
                                      if (canConsoleActions)
                                        IconButton(
                                          tooltip: 'Terminate Pointer',
                                          icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Terminate Delivery Manifest?'),
                                                content: const Text('Definitively remove this delivery trip manifest pointer from matrix?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Terminate', style: TextStyle(color: AppTheme.danger))),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await ref.read(deliveryTripControllerProvider.notifier).deleteTrip(item.id);
                                            }
                                          },
                                        ),
                                    ],
                                  ),
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
      selectedColor: AppTheme.primary,
      checkmarkColor: AppTheme.surfaceWhite,
      side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderGrey),
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? statusKey : 'ALL';
        });
      },
    );
  }

  void _showStatusPatchModal(BuildContext context, DeliveryTripResponseModel item) {
    String selectedStatus = item.status;
    XFile? signatureFile;
    XFile? photoFile;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Patch Transit Console State', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Update Status Flag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PENDING', child: Text('PENDING', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'IN_TRANSIT', child: Text('IN_TRANSIT (Trigger Starting Time)', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'DELIVERED', child: Text('DELIVERED (Require Signature/POD)', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) => setDialogState(() => selectedStatus = val ?? item.status),
                  ),
                  const SizedBox(height: 12),

                  if (selectedStatus == 'DELIVERED') ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.light,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Upload Digital Recipient Signature', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          const SizedBox(height: 4),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                setDialogState(() => signatureFile = picked);
                              }
                            },
                            icon: const Icon(Icons.gesture, size: 16),
                            label: Text(
                              signatureFile != null ? signatureFile!.name : 'Choose Signature Image',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Upload Proof of Delivery (POD) Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          const SizedBox(height: 4),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                setDialogState(() => photoFile = picked);
                              }
                            },
                            icon: const Icon(Icons.camera_alt, size: 16),
                            label: Text(
                              photoFile != null ? photoFile!.name : 'Choose POD Photo',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                onPressed: () async {
                  Navigator.pop(ctx);
                  MultipartFile? sigPart;
                  if (signatureFile != null) {
                    final bytes = await signatureFile!.readAsBytes();
                    sigPart = MultipartFile.fromBytes(bytes, filename: signatureFile!.name);
                  }
                  MultipartFile? photoPart;
                  if (photoFile != null) {
                    final bytes = await photoFile!.readAsBytes();
                    photoPart = MultipartFile.fromBytes(bytes, filename: photoFile!.name);
                  }

                  await ref.read(deliveryTripControllerProvider.notifier).changeStatus(
                    item.id,
                    selectedStatus,
                    sigPart,
                    photoPart,
                  );
                },
                icon: const Icon(Icons.check_circle, color: AppTheme.surfaceWhite, size: 16),
                label: const Text('Execute Patch', style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
