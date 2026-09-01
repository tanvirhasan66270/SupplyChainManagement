import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/driver/provider/driver_provider.dart';
import 'package:scm_flutter/entity/vehicle_model.dart';
import 'package:scm_flutter/logistics_officer/provider/vehicle_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class VehicleFormScreen extends ConsumerStatefulWidget {
  const VehicleFormScreen({super.key, this.vehicleToEdit});

  final VehicleResponseModel? vehicleToEdit;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String plateNumber = '';
  String type = 'VAN';
  double capacity = 0;
  String status = 'AVAILABLE';
  String? lastServiceDate;
  double fuelLevel = 100;
  int? driverId;

  final List<String> vehicleTypes = ['TRUCK', 'VAN', 'BIKE', 'AIR', 'RIVER_SHIP'];
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    if (widget.vehicleToEdit != null) {
      final v = widget.vehicleToEdit!;
      plateNumber = v.plateNumber;
      type = v.type;
      capacity = v.capacity;
      status = v.status;
      lastServiceDate = v.lastServiceDate;
      fuelLevel = v.fuelLevel;
      driverId = v.driverId;
    }
    _dateController = TextEditingController(text: lastServiceDate ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.tealPrimary,
              onPrimary: AppTheme.white,
              onSurface: AppTheme.dark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        lastServiceDate = formattedDate;
        _dateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicleToEdit != null;
    final driversAsync = ref.watch(driverListProvider);
    final drivers = driversAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ১. Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.tealPrimary, AppTheme.tealLight, AppTheme.tealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: AppTheme.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Modify Fleet Attributes' : 'Register Vehicle Hub',
                            style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Register and manage corporate vehicle profiles & fleet attributes',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppTheme.white, size: 22),
                  ),
                ],
              ),
            ),

            // ২. Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: BRTA License Plate Number
                      _buildNumberedLabel(1, 'BRTA LICENSE PLATE NUMBER *'),
                      TextFormField(
                        initialValue: plateNumber,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g., Dhaka Metro-GA-11-2026',
                          prefixIcon: const Icon(Icons.pin_outlined, size: 18, color: AppTheme.secondary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Validation Error: Vehicle Plate Number is mandatory.' : null,
                        onChanged: (val) => plateNumber = val,
                      ),
                      const SizedBox(height: 16),

                      // Step 2: Vehicle Logistics Type
                      _buildNumberedLabel(2, 'VEHICLE LOGISTICS TYPE *'),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: _inputDecoration().copyWith(
                          prefixIcon: const Icon(Icons.local_shipping_outlined, size: 18, color: AppTheme.secondary),
                        ),
                        items: vehicleTypes.map((vt) => DropdownMenuItem(
                          value: vt,
                          child: Text(vt, style: const TextStyle(fontSize: 12)),
                        )).toList(),
                        onChanged: (val) => setState(() => type = val ?? 'VAN'),
                      ),
                      const SizedBox(height: 16),

                      // Step 3: Load Capacity
                      _buildNumberedLabel(3, 'LOAD CAPACITY (KG) *'),
                      TextFormField(
                        initialValue: capacity == 0 ? '' : capacity.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(
                          hintText: '0',
                          prefixIcon: const Icon(Icons.fitness_center, size: 18, color: AppTheme.secondary),
                        ),
                        onChanged: (val) => capacity = double.tryParse(val) ?? 0,
                      ),
                      const SizedBox(height: 16),

                      // Step 4: Current Fleet State
                      _buildNumberedLabel(4, 'CURRENT FLEET STATE *'),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: _inputDecoration().copyWith(
                          fillColor: AppTheme.borderGrey.withValues(alpha: 0.3),
                          prefixIcon: const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.tealPrimary),
                        ),
                        items: VehicleStatus.values.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.tealPrimary)),
                        )).toList(),
                        onChanged: null,
                      ),
                      const SizedBox(height: 2),
                      const Text('🔒 Read-only from form control.', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                      const SizedBox(height: 16),

                      // Step 5: Fuel Level Volume (%)
                      _buildNumberedLabel(5, 'FUEL LEVEL VOLUME (%) *'),
                      TextFormField(
                        initialValue: fuelLevel.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(
                          hintText: '100',
                          prefixIcon: const Icon(Icons.local_gas_station, size: 18, color: AppTheme.secondary),
                        ),
                        onChanged: (val) => fuelLevel = double.tryParse(val) ?? 100,
                      ),
                      const SizedBox(height: 16),

                      // Step 6: Bind Captain Personnel (Driver)
                      _buildNumberedLabel(6, 'BIND CAPTAIN PERSONNEL (DRIVER)'),
                      DropdownButtonFormField<int?>(
                        initialValue: driverId,
                        decoration: _inputDecoration().copyWith(
                          hintText: '-- Leave Unassigned / Standby --',
                          prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppTheme.secondary),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('-- Leave Unassigned / Standby --', style: TextStyle(fontSize: 12))),
                          ...drivers.map((d) => DropdownMenuItem<int?>(
                            value: d.id,
                            child: Text('${d.driverName} (${d.phone})', style: const TextStyle(fontSize: 12)),
                          )),
                        ],
                        onChanged: (val) => setState(() => driverId = val),
                      ),
                      const SizedBox(height: 16),

                      // Step 7: Last Workshop Service Audit Date
                      _buildNumberedLabel(7, 'LAST WORKSHOP SERVICE AUDIT DATE'),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: _inputDecoration().copyWith(
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.secondary),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.event, size: 18, color: AppTheme.tealPrimary),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        onChanged: (val) => lastServiceDate = val,
                      ),
                      const SizedBox(height: 24),

                      // Footer Action Buttons (Push Attribute Patch / Execute Asset Genesis & Clear)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                final request = VehicleRequestModel(
                                  plateNumber: plateNumber.trim(),
                                  type: type,
                                  capacity: capacity,
                                  status: status,
                                  lastServiceDate: lastServiceDate?.trim().isEmpty ?? true ? null : lastServiceDate?.trim(),
                                  fuelLevel: fuelLevel,
                                  driverId: driverId,
                                );

                                bool success = false;
                                if (isEdit && widget.vehicleToEdit != null) {
                                  success = await ref
                                      .read(vehicleControllerProvider.notifier)
                                      .updateVehicle(widget.vehicleToEdit!.id, request);
                                } else {
                                  success = await ref
                                      .read(vehicleControllerProvider.notifier)
                                      .createVehicle(request);
                                }

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEdit ? 'Fleet vehicle parameters updated successfully.' : 'New vehicle asset logged into logistics database.',
                                      ),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.cloud_upload, size: 18),
                              label: Text(
                                isEdit ? 'PUSH ATTRIBUTE PATCH' : 'EXECUTE ASSET GENESIS',
                                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.tealPrimary,
                                foregroundColor: AppTheme.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                plateNumber = '';
                                capacity = 0;
                                fuelLevel = 100;
                                driverId = null;
                                lastServiceDate = null;
                                _dateController.clear();
                              }),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.borderGrey),
                                foregroundColor: AppTheme.dark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('CLEAR FORM', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberedLabel(int stepNum, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: AppTheme.tealBackground, shape: BoxShape.circle),
            child: Center(
              child: Text(
                stepNum.toString(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.tealPrimary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.tealPrimary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}