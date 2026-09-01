import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/entity/delivery_trip_model.dart';
import 'package:scm_flutter/logistics_officer/provider/delivery_trip_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/vehicle_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class DeliveryTripFormScreen extends ConsumerStatefulWidget {
  const DeliveryTripFormScreen({super.key, this.tripToEdit});

  final DeliveryTripResponseModel? tripToEdit;

  @override
  ConsumerState<DeliveryTripFormScreen> createState() => _DeliveryTripFormScreenState();
}

class _DeliveryTripFormScreenState extends ConsumerState<DeliveryTripFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int dispatcherId = 0;
  int customerId = 0;
  int vehicleId = 0;
  int driverId = 0;
  String status = 'PENDING';
  String customerAddress = '';
  String remarks = '';
  String selectedVehicleType = '';
  List<dynamic> filteredVehicles = [];
  String? errorMessage;
  bool isSaving = false;

  final List<Map<String, String>> vehicleTypes = [
    {'value': 'TRUCK', 'label': '🚛 TRUCK DISPATCH'},
    {'value': 'VAN', 'label': '🚐 VAN INFRASTRUCTURE'},
    {'value': 'BIKE', 'label': '🏍️ BIKE FAST DELIVERY'},
    {'value': 'AIR', 'label': '✈️ AIR FREIGHT CORE'},
    {'value': 'RIVER_SHIP', 'label': '🚢 RIVER SHIFT NETWORK'},
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    dispatcherId = currentUser?.userId ?? 0;

    if (widget.tripToEdit != null) {
      final t = widget.tripToEdit!;
      dispatcherId = t.dispatcherId;
      customerId = t.customerId;
      vehicleId = t.vehicleId;
      driverId = t.driverId;
      status = t.status;
      customerAddress = t.customerAddress;
      remarks = t.remarks ?? '';
    }
  }

  void _onVehicleTypeChange(String? type, List<dynamic> allVehicles) {
    setState(() {
      selectedVehicleType = type ?? '';
      vehicleId = 0;
      driverId = 0;
      if (selectedVehicleType.isEmpty) {
        filteredVehicles = [];
      } else {
        filteredVehicles = allVehicles.where((v) =>
          v.type.toUpperCase() == selectedVehicleType.toUpperCase() && v.driverId != null
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tripToEdit != null;
    final customersAsync = ref.watch(customerListProvider);
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final allVehicles = vehiclesAsync.value ?? [];

    if (isEdit && filteredVehicles.isEmpty && allVehicles.isNotEmpty && selectedVehicleType.isEmpty) {
      final matched = allVehicles.firstWhereOrNull((v) => v.id == vehicleId);
      if (matched != null) {
        selectedVehicleType = matched.type;
        filteredVehicles = allVehicles.where((v) =>
          v.type.toUpperCase() == selectedVehicleType.toUpperCase() && v.driverId != null
        ).toList();
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modify Transit Settings' : 'Dispatch New Route Node',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.purple, AppTheme.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route, color: AppTheme.surfaceWhite, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Fleet Route Deployment Matrix',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Control logistics dispatch operations & allocate fleet vehicle captains',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.danger),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 1. Target Customer Account
                _buildStepLabel(1, 'TARGET CUSTOMER ACCOUNT *'),
                customersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading customers: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (customerList) {
                    return DropdownButtonFormField<int>(
                      initialValue: customerId != 0 && customerList.any((c) => c.id == customerId) ? customerId : null,
                      decoration: _inputDecoration('-- Choose Client Nodes --', Icons.person_pin_outlined),
                      items: customerList.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text('${c.name} (${c.email.isNotEmpty ? c.email : c.phone})', style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => customerId = val ?? 0),
                      validator: (val) => (val == null || val == 0) ? 'Customer selection required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. Select Vehicle Mode
                _buildStepLabel(2, 'SELECT VEHICLE MODE *'),
                DropdownButtonFormField<String>(
                  initialValue: selectedVehicleType.isNotEmpty ? selectedVehicleType : null,
                  decoration: _inputDecoration('-- Choose Fleet Mode --', Icons.directions_bus_outlined),
                  items: vehicleTypes.map((vt) {
                    return DropdownMenuItem<String>(
                      value: vt['value'],
                      child: Text(vt['label']!, style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                    );
                  }).toList(),
                  onChanged: (val) => _onVehicleTypeChange(val, allVehicles),
                  validator: (val) => (val == null || val.isEmpty) ? 'Vehicle mode selection required' : null,
                ),
                const SizedBox(height: 16),

                // 3. Assign Captain & Fleet Asset
                _buildStepLabel(3, 'ASSIGN CAPTAIN & FLEET ASSET *'),
                vehiclesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading vehicles: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (_) {
                    final vehicleOptions = filteredVehicles;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: vehicleId != 0 && vehicleOptions.any((v) => v.id == vehicleId) ? vehicleId : null,
                          decoration: _inputDecoration(
                            vehicleOptions.isEmpty
                                ? '-- Choose Fleet Mode First / No Driver Available --'
                                : '-- Choose Captain (Vehicle Number) --',
                            Icons.directions_car_outlined,
                          ),
                          items: vehicleOptions.map((v) {
                            return DropdownMenuItem<int>(
                              value: v.id as int,
                              child: Text('👤 ${v.driverName} (🚗 ${v.plateNumber})', style: const TextStyle(fontSize: 12, color: AppTheme.dark, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: vehicleOptions.isEmpty
                              ? null
                              : (val) {
                                  setState(() {
                                    vehicleId = val ?? 0;
                                    final selectedV = vehicleOptions.firstWhereOrNull((v) => v.id == vehicleId);
                                    if (selectedV != null) {
                                      driverId = selectedV.driverId ?? 0;
                                    }
                                  });
                                },
                          validator: (val) => (val == null || val == 0) ? 'Fleet vehicle & captain required' : null,
                        ),
                        if (selectedVehicleType.isNotEmpty && vehicleOptions.isEmpty) ...[
                          const SizedBox(height: 6),
                          const Text(
                            '⚠️ Business Notice: No active captain assigned to any vehicle inside database for this type.',
                            style: TextStyle(color: AppTheme.danger, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 4. Initial Operational State
                _buildStepLabel(4, 'INITIAL OPERATIONAL STATE'),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: _inputDecoration('State Status', Icons.flag_outlined),
                  items: const [
                    DropdownMenuItem(value: 'PENDING', child: Text('📁 PENDING (Manifest Locked)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'IN_TRANSIT', child: Text('🔄 IN_TRANSIT (Dispatched Fleet)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'DELIVERED', child: Text('✅ DELIVERED (Consignment Unloaded)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'CANCELLED', child: Text('❌ CANCELLED (Revoked Manifest)', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: isEdit ? (val) => setState(() => status = val ?? 'PENDING') : null,
                ),
                const SizedBox(height: 16),

                // 5. Consignment Drop Coordinate Address
                _buildStepLabel(5, 'CONSIGNMENT DROP COORDINATE ADDRESS *'),
                TextFormField(
                  initialValue: customerAddress,
                  maxLines: 3,
                  decoration: _inputDecoration('Input target shipping map coordinates & address...', Icons.location_on_outlined),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Drop address required' : null,
                  onSaved: (val) => customerAddress = val?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // 6. Operational Transit Notes
                _buildStepLabel(6, 'OPERATIONAL TRANSIT NOTES'),
                TextFormField(
                  initialValue: remarks,
                  maxLines: 2,
                  decoration: _inputDecoration('Log route delays, damage profiles or general variables...', Icons.notes_outlined),
                  onSaved: (val) => remarks = val?.trim() ?? '',
                ),
                const SizedBox(height: 24),

                // 7. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.borderGrey),
                          foregroundColor: AppTheme.dark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppTheme.surfaceWhite, strokeWidth: 2))
                            : const Icon(Icons.cloud_upload_outlined, color: AppTheme.surfaceWhite),
                        label: Text(
                          isEdit ? 'Update Manifest Matrix' : 'Commit Manifest Deployment',
                          style: const TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepLabel(int stepNum, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Color(0xFFE0E7FF), shape: BoxShape.circle),
            child: Center(
              child: Text(
                stepNum.toString(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppTheme.secondary),
      filled: true,
      fillColor: AppTheme.surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (customerId == 0 || vehicleId == 0) {
      setState(() => errorMessage = 'Validation Fault: Customer mapping and Fleet allocation with assigned captain are required.');
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    final payload = DeliveryTripRequestModel(
      dispatcherId: dispatcherId != 0 ? dispatcherId : 1,
      customerId: customerId,
      vehicleId: vehicleId,
      driverId: driverId,
      status: status.toUpperCase(),
      customerAddress: customerAddress,
      remarks: remarks.isNotEmpty ? remarks : null,
    );

    bool success = false;
    if (widget.tripToEdit != null) {
      success = await ref.read(deliveryTripControllerProvider.notifier).updateTrip(widget.tripToEdit!.id, payload);
    } else {
      success = await ref.read(deliveryTripControllerProvider.notifier).createTrip(payload);
    }

    setState(() => isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.tripToEdit != null ? 'Trip manifest routing modified.' : 'New delivery trip blueprint deployed successfully.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => errorMessage = 'Runtime Communication Exception.');
    }
  }
}