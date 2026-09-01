import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/driver/provider/driver_provider.dart';
import 'package:scm_flutter/entity/driver_model.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';
import 'package:scm_flutter/widget/commonWidget.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  final _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isEditing = false;
  bool _isUpdating = false;

  String _resolveImageUrl(String? imgPath) {
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
    if (trimmed.startsWith('driver/') || trimmed.startsWith('user/')) {
      return '${ApiConstants.imgUrl}$trimmed';
    }
    return '${ApiConstants.imgUrl}driver/$trimmed';
  }

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;
  late TextEditingController _nidController;

  int? _lastDriverId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _genderController = TextEditingController();
    _dobController = TextEditingController();
    _nidController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  void _populateControllers(DriverResponseModel driver) {
    if (_lastDriverId == driver.id && !_isEditing) return;
    _lastDriverId = driver.id;
    _nameController.text = driver.driverName;
    _emailController.text = driver.email;
    _phoneController.text = driver.phone;
    _addressController.text = driver.address;
    _genderController.text = driver.gender;
    _dobController.text = driver.dob;
    _nidController.text = driver.nidNumber;
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  Future<void> _selectDob() async {
    final now = DateTime.now();
    final initialDate = DateTime.tryParse(_dobController.text) ?? DateTime(1995, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
    );

    if (picked != null) {
      final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  Future<void> _updateProfile(DriverResponseModel driver) async {
    setState(() => _isUpdating = true);
    final currentContext = context;

    try {
      final repo = ref.read(driverRepositoryProvider);
      final request = DriverRequestModel(
        id: driver.id,
        driverName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _genderController.text.trim().isEmpty ? driver.gender : _genderController.text.trim(),
        dob: _dobController.text.trim(),
        nidNumber: _nidController.text.trim(),
        vehicleType: driver.vehicleType,
        vehicleNumber: driver.vehicleNumber,
        rating: driver.rating,
        totalDeliveries: driver.totalDeliveries,
        totalEarnings: driver.totalEarnings,
        image: driver.image,
        password: "",
        policeStationId: driver.policeStationId,
        warehouseIds: [],
      );

      File? imageFile;
      if (_selectedImage != null) {
        imageFile = File(_selectedImage!.path);
      }

      await repo.update(driver.id, request, imageFile);

      ref.invalidate(currentDriverProvider);

      if (mounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Driver Profile Registry Updated Successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e)), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverAsync = ref.watch(currentDriverProvider);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text('My Driver Profile', style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined, size: 18),
            label: Text(_isEditing ? 'Cancel' : 'Edit'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: driverAsync.when(
        data: (driver) {
          if (driver == null) {
            return const Center(child: Text('Driver profile not found.'));
          }
          _populateControllers(driver);
          return _buildProfileBody(driver);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ErrorBanner(message: apiErrorMessage(e))),
      ),
    );
  }

  Widget _buildProfileBody(DriverResponseModel driver) {
    // Dynamic Completion Calculation
    int completedFields = 0;
    final totalFields = 8;
    if (_nameController.text.isNotEmpty) completedFields++;
    if (_emailController.text.isNotEmpty) completedFields++;
    if (_phoneController.text.isNotEmpty) completedFields++;
    if (_genderController.text.isNotEmpty) completedFields++;
    if (_dobController.text.isNotEmpty) completedFields++;
    if (_nidController.text.isNotEmpty) completedFields++;
    if (_addressController.text.isNotEmpty) completedFields++;
    if (driver.image.isNotEmpty || _selectedImage != null) completedFields++;

    final completion = (completedFields / totalFields * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Avatar Section ──────────────────
          _buildHeader(driver),
          const SizedBox(height: 20),

          // ── Action Buttons for Avatar ─────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: Text(_selectedImage == null ? 'Choose New Image' : 'Image Selected: ${_selectedImage!.name}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: _selectedImage != null ? AppTheme.primary : AppTheme.dark,
                    side: BorderSide(color: _selectedImage != null ? AppTheme.primary : AppTheme.borderGrey),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isUpdating ? null : () => _updateProfile(driver),
              icon: _isUpdating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white))
                  : const Icon(Icons.cloud_upload_outlined),
              label: const Text('UPLOAD NEW AVATAR'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── KPI Summary Section ─────────────────────
          Row(
            children: [
              Expanded(child: _buildKpiBox('Total Deliveries', '${driver.totalDeliveries}', Icons.local_shipping_outlined, AppTheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiBox('Total Earnings', '৳${driver.totalEarnings.toStringAsFixed(0)}', Icons.payments_outlined, AppTheme.success)),
            ],
          ),
          const SizedBox(height: 24),

          // ── Completion Section ──────────────────────
          _buildCompletionSection(completion),
          const SizedBox(height: 24),

          // ── Personal Settings Form / List ──────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PERSONAL REGISTRY DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
              if (!_isEditing)
                InkWell(
                  onTap: () => setState(() => _isEditing = true),
                  child: const Text('Click to Edit', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSettingsForm(driver),
          const SizedBox(height: 24),

          // ── Vehicle Information ─────────────────────
          const Text('VEHICLE & FLEET INFORMATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 12),
          _buildVehicleInfo(driver),
          const SizedBox(height: 24),

          // ── Warehouse Assignments ───────────────────
          const Text('ASSIGNED WAREHOUSE NODES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 12),
          _buildWarehouseChips(driver),
          const SizedBox(height: 24),

          // ── Logistics & Location Metadata ───────────
          const Text('LOGISTICS & LOCATION METADATA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 12),
          _buildLocationSection(driver),
          const SizedBox(height: 12),

          // Registered Date Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppTheme.grey),
                const SizedBox(width: 8),
                Text('Registered: ${driver.createdAt}', style: const TextStyle(color: AppTheme.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Save/Update Button ──────────────────────
          ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _updateProfile(driver),
            icon: _isUpdating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white))
                : const Icon(Icons.verified_user_outlined),
            label: Text(_isUpdating ? 'UPDATING REGISTRY...' : 'UPDATE PROFILE REGISTRY'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(DriverResponseModel driver) {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(File(_selectedImage!.path));
    } else {
      final resolvedUrl = _resolveImageUrl(driver.image);
      if (resolvedUrl.isNotEmpty) {
        imageProvider = NetworkImage(resolvedUrl);
      }
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: AppTheme.borderGrey,
                backgroundImage: imageProvider,
                child: imageProvider == null ? const Icon(Icons.person, size: 50, color: AppTheme.grey) : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: AppTheme.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.driverName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.dark),
              ),
              Row(
                children: [
                  const Text('Role: ', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
                  Text(
                    driver.role.toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.borderGrey)),
                      child: Column(
                        children: [
                          Text('${driver.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                            Icon(Icons.star, color: AppTheme.warning, size: 12),
                            SizedBox(width: 4),
                            Text('SCORE', style: TextStyle(fontSize: 9, color: AppTheme.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.borderGrey)),
                      child: Column(
                        children: [
                          const Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.success)),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                            Icon(Icons.check_circle, color: AppTheme.success, size: 12),
                            SizedBox(width: 4),
                            Text('STATUS', style: TextStyle(fontSize: 9, color: AppTheme.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCompletionSection(int completion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Completion Profile', style: TextStyle(fontSize: 12, color: AppTheme.grey, fontWeight: FontWeight.w500)),
              Text('$completion%', style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: AppTheme.light,
            color: AppTheme.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          _buildCompletionStep('Driver Name Node', _nameController.text.isNotEmpty),
          _buildCompletionStep('Email & Mobile Route', _emailController.text.isNotEmpty && _phoneController.text.isNotEmpty),
          _buildCompletionStep('National ID & DOB', _nidController.text.isNotEmpty && _dobController.text.isNotEmpty),
          _buildCompletionStep('Identity Avatar Image', completion > 80),
        ],
      ),
    );
  }

  Widget _buildCompletionStep(String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.circle_outlined, size: 16, color: isDone ? AppTheme.success : AppTheme.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: isDone ? AppTheme.dark : AppTheme.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsForm(DriverResponseModel driver) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        children: [
          _buildEditableField(
            icon: Icons.person_outline,
            label: 'Full Driver Name',
            controller: _nameController,
          ),
          const Divider(height: 1, indent: 60),
          _buildEditableField(
            icon: Icons.email_outlined,
            label: 'Corporate Secure Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const Divider(height: 1, indent: 60),
          _buildEditableField(
            icon: Icons.phone_outlined,
            label: 'Secure Mobile Route',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const Divider(height: 1, indent: 60),
          _buildGenderSelector(),
          const Divider(height: 1, indent: 60),
          _buildEditableField(
            icon: Icons.calendar_today_outlined,
            label: 'Date of Birth (YYYY-MM-DD)',
            controller: _dobController,
            readOnly: true,
            onTap: _selectDob,
            trailingIcon: Icons.calendar_month,
          ),
          const Divider(height: 1, indent: 60),
          _buildEditableField(
            icon: Icons.badge_outlined,
            label: 'National ID (NID)',
            controller: _nidController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.blueLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.grey, fontWeight: FontWeight.bold)),
      subtitle: _isEditing
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.primary)),
                ),
              ),
            )
          : Text(
              controller.text.isEmpty ? 'Not set' : controller.text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark),
            ),
      trailing: trailingIcon != null
          ? IconButton(icon: Icon(trailingIcon, size: 20, color: AppTheme.primary), onPressed: onTap)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildGenderSelector() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.blueLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.male_outlined, color: AppTheme.primary, size: 20),
      ),
      title: const Text('Gender Node', style: TextStyle(fontSize: 10, color: AppTheme.grey, fontWeight: FontWeight.bold)),
      subtitle: _isEditing
          ? DropdownButtonFormField<String>(
              initialValue: ['MALE', 'FEMALE', 'OTHER'].contains(_genderController.text.toUpperCase())
                  ? _genderController.text.toUpperCase()
                  : 'MALE',
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('MALE')),
                DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
                DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _genderController.text = val);
                }
              },
            )
          : Text(
              _genderController.text.toUpperCase(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildVehicleInfo(DriverResponseModel driver) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        children: [
          _buildStaticInfoTile(Icons.directions_car_outlined, 'Vehicle Type', driver.vehicleType, AppTheme.info),
          const Divider(height: 1, indent: 60),
          _buildStaticInfoTile(Icons.numbers_outlined, 'Vehicle License Plate', driver.vehicleNumber, AppTheme.info),
        ],
      ),
    );
  }

  Widget _buildStaticInfoTile(IconData icon, String label, String value, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.grey, fontWeight: FontWeight.bold)),
      subtitle: Text(
        value.isEmpty ? 'N/A' : value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildWarehouseChips(DriverResponseModel driver) {
    if (driver.warehouseNames.isEmpty) {
      return const Text('No warehouses assigned.', style: TextStyle(fontSize: 12, color: AppTheme.grey, fontStyle: FontStyle.italic));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: driver.warehouseNames.map((w) => Chip(
        label: Text(w, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.white)),
        backgroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      )).toList(),
    );
  }

  Widget _buildLocationSection(DriverResponseModel driver) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blueLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.blueLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: AppTheme.primary, size: 18),
              SizedBox(width: 8),
              Text('SYSTEM TRACK TERMINAL', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _locationMeta('Division Node', driver.divisionName),
          _locationMeta('District Sector', driver.districtName),
          _locationMeta('Police Station', driver.policeStationName),
          const Divider(color: AppTheme.borderGrey, height: 24),
          const Text('Detailed Dispatch Address HQ', style: TextStyle(fontSize: 10, color: AppTheme.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextField(
                controller: _addressController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.dark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.white,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                ),
              ),
            )
          else
            Text(
              _addressController.text.isEmpty ? driver.address : _addressController.text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.dark),
            ),
        ],
      ),
    );
  }

  Widget _locationMeta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppTheme.dark),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value.isEmpty ? 'N/A' : value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
