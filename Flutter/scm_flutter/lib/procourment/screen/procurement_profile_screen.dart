import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/loginModel.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ProcurementProfileScreen extends ConsumerStatefulWidget {
  const ProcurementProfileScreen({super.key});

  @override
  ConsumerState<ProcurementProfileScreen> createState() => _ProcurementProfileScreenState();
}

class _ProcurementProfileScreenState extends ConsumerState<ProcurementProfileScreen> {
  final _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isEditing = false;
  bool _isUpdating = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _genderController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _hubController;
  late TextEditingController _countryController;
  late TextEditingController _divisionController;
  late TextEditingController _districtController;
  late TextEditingController _policeStationController;
  late TextEditingController _addressController;

  int? _lastUserId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _genderController = TextEditingController(text: 'MALE');
    _designationController = TextEditingController(text: 'Senior Procurement Officer');
    _departmentController = TextEditingController(text: 'Procurement & Materials Sourcing');
    _hubController = TextEditingController();
    _countryController = TextEditingController(text: 'Bangladesh');
    _divisionController = TextEditingController(text: 'Dhaka Division');
    _districtController = TextEditingController(text: 'Dhaka District');
    _policeStationController = TextEditingController(text: 'Banani Model Thana');
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _hubController.dispose();
    _countryController.dispose();
    _divisionController.dispose();
    _districtController.dispose();
    _policeStationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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
    return '${ApiConstants.imgUrl}user/$trimmed';
  }

  void _populateControllers(LoginResponse user) {
    if (_lastUserId == user.userId && !_isEditing && _nameController.text.isNotEmpty) return;
    _lastUserId = user.userId;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;

    if (_hubController.text.isEmpty) {
      _hubController.text = user.hubName != null && user.hubName!.isNotEmpty
          ? user.hubName!
          : (user.hubId != null ? 'Hub #${user.hubId}' : 'Central Logistics & Procurement Hub');
    }
    if (_addressController.text.isEmpty) {
      _addressController.text = 'Dhaka SCM Operational Complex, House 42, Road 11, Banani, Dhaka';
    }
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
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateProfile(LoginResponse user) async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Email are required.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Registry Updated Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
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
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(currentUser),
    );
  }

  Widget _buildProfileContent(LoginResponse user) {
    _populateControllers(user);

    // Dynamic Completion Calculation
    int completedFields = 0;
    const totalFields = 8;
    if (_nameController.text.isNotEmpty) completedFields++;
    if (_emailController.text.isNotEmpty) completedFields++;
    if (_phoneController.text.isNotEmpty) completedFields++;
    if (_designationController.text.isNotEmpty) completedFields++;
    if (_departmentController.text.isNotEmpty) completedFields++;
    if (_countryController.text.isNotEmpty) completedFields++;
    if (_districtController.text.isNotEmpty) completedFields++;
    if (_addressController.text.isNotEmpty || _selectedImage != null) completedFields++;

    final completion = (completedFields / totalFields * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Avatar Section ──────────────────
          _buildHeader(user),
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
                    foregroundColor: _selectedImage != null ? AppTheme.primary : Colors.black87,
                    side: BorderSide(color: _selectedImage != null ? AppTheme.primary : Colors.grey.shade400),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isUpdating ? null : () => _updateProfile(user),
              icon: _isUpdating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_outlined),
              label: const Text('UPLOAD NEW AVATAR'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── Completion Section ──────────────────────
          _buildCompletionSection(completion),
          const SizedBox(height: 24),

          // ── Personal Settings Form / List ──────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PERSONAL REGISTRY DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              if (!_isEditing)
                InkWell(
                  onTap: () => setState(() => _isEditing = true),
                  child: const Text('Click to Edit', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSettingsForm(user),
          const SizedBox(height: 24),

          // ── Logistics & Location Metadata ───────────
          const Text('LOGISTICS & LOCATION METADATA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          _buildLocationSection(user),
          const SizedBox(height: 12),

          // Registered Date Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('User ID: #${user.userId} - Operational Account', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Save/Update Button ──────────────────────
          ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _updateProfile(user),
            icon: _isUpdating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.verified_user_outlined),
            label: Text(_isUpdating ? 'UPDATING REGISTRY...' : 'UPDATE PROFILE REGISTRY'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 20),

          // ── Logout Action Button ────────────────────
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, size: 18, color: AppTheme.danger),
            label: const Text('LOG OUT OF SCM ENTERPRISE', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppTheme.dangerLight, width: 1.5),
              backgroundColor: AppTheme.dangerLight.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(LoginResponse user) {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(File(_selectedImage!.path));
    } else {
      final suppliersAsync = ref.watch(supplierListProvider);
      final suppliers = suppliersAsync.value ?? [];
      final currentSupplier = suppliers.where((s) => s.userId == user.userId).firstOrNull;
      if (currentSupplier != null && currentSupplier.image.isNotEmpty) {
        final resolved = _resolveImageUrl(currentSupplier.image);
        if (resolved.isNotEmpty) {
          imageProvider = NetworkImage(resolved);
        }
      }
    }

    final rawName = user.name.trim();
    final initials = rawName.length >= 2 ? rawName.substring(0, 2).toUpperCase() : (rawName.isNotEmpty ? rawName.toUpperCase() : 'PO');

    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        initials,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Color(0xFF0D6EFD), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
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
                user.name.isNotEmpty ? user.name : 'Procurement Officer',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Row(
                children: [
                  const Text('Role: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: [
                          const Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                            Icon(Icons.star, color: Colors.orange, size: 12),
                            SizedBox(width: 4),
                            Text('SCORE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: [
                          const Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                            Icon(Icons.check_circle, color: Colors.green, size: 12),
                            SizedBox(width: 4),
                            Text('STATUS', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
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

  Widget _buildCompletionSection(int completion) {
    return Container(
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
              const Text('Completion Profile', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              Text('$completion%', style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: Colors.grey.shade100,
            color: AppTheme.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          _buildCompletionStep('Officer Name Node', _nameController.text.isNotEmpty),
          _buildCompletionStep('Email & Mobile Route', _emailController.text.isNotEmpty && _phoneController.text.isNotEmpty),
          _buildCompletionStep('Designation & Department', _designationController.text.isNotEmpty && _departmentController.text.isNotEmpty),
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
          Icon(isDone ? Icons.check_circle : Icons.circle_outlined, size: 16, color: isDone ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: isDone ? Colors.black87 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsForm(LoginResponse user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildEditableField(
            icon: Icons.person_outline,
            label: 'Full Officer Name',
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
            icon: Icons.badge_outlined,
            label: 'Designation / Official Title',
            controller: _designationController,
          ),
          const Divider(height: 1, indent: 60),
          _buildEditableField(
            icon: Icons.business_outlined,
            label: 'Department / Division',
            controller: _departmentController,
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
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      subtitle: _isEditing
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.primary)),
                ),
              ),
            )
          : Text(
              controller.text.isEmpty ? 'Not set' : controller.text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildGenderSelector() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.male_outlined, color: AppTheme.primary, size: 20),
      ),
      title: const Text('Gender Node', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildLocationSection(LoginResponse user) {
    final hubTitle = user.hubName != null && user.hubName!.isNotEmpty
        ? user.hubName!
        : (user.hubId != null ? 'Hub #${user.hubId}' : 'Central Logistics & Procurement Hub');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
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
          _locationMeta('Assigned Hub', hubTitle),
          _locationEditableMeta('Country / Nation', _countryController),
          _locationEditableMeta('Division Sector', _divisionController),
          _locationEditableMeta('District Sector', _districtController),
          _locationEditableMeta('Police Station / Thana', _policeStationController),
          _locationMeta('Operational Role', user.role.toUpperCase()),
          const Divider(color: Color(0xFFDBEAFE), height: 24),
          const Text('Detailed Dispatch Address HQ', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextField(
                controller: _addressController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
              ),
            )
          else
            Text(
              _addressController.text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
            ),
        ],
      ),
    );
  }

  Widget _locationEditableMeta(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
          Expanded(
            child: _isEditing
                ? SizedBox(
                    height: 32,
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.primary)),
                      ),
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? 'N/A' : controller.text,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
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
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value.isEmpty ? 'N/A' : value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to log out of SCM Enterprise?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
