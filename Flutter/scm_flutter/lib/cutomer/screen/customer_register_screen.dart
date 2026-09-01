import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/address/screen/location_screen.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/entity/customerModel.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';

class CustomerRegisterScreen extends ConsumerStatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  ConsumerState<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends ConsumerState<CustomerRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();

  String _gender = 'MALE';
  int? _policeStationId;
  LocationSelection? _currentLocation;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _streetAddressController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  void _updateFullAddress() {
    final parts = <String>[];
    final street = _streetAddressController.text.trim();
    if (street.isNotEmpty) parts.add(street);

    if (_currentLocation != null) {
      if (_currentLocation!.policeStationName != null && _currentLocation!.policeStationName!.isNotEmpty) {
        parts.add(_currentLocation!.policeStationName!);
      }
      if (_currentLocation!.districtName != null && _currentLocation!.districtName!.isNotEmpty) {
        parts.add(_currentLocation!.districtName!);
      }
      if (_currentLocation!.divisionName != null && _currentLocation!.divisionName!.isNotEmpty) {
        parts.add(_currentLocation!.divisionName!);
      }
      if (_currentLocation!.countryName != null && _currentLocation!.countryName!.isNotEmpty) {
        parts.add(_currentLocation!.countryName!);
      }
    }

    final generatedAddress = parts.join(', ');
    setState(() {
      _addressController.text = generatedAddress;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = picked.name;
          if (!kIsWeb) {
            _selectedImage = File(picked.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(1995, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1930),
      lastDate: now,
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  Future<void> _registerCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_policeStationId == null || _policeStationId == 0) {
      setState(() {
        _errorMessage = 'Location Fault: Please complete the Country -> Division -> District -> Police Station location cascade selection.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password Fault: Password and Confirm Password do not match.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final request = CustomerRequestModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        address: _addressController.text.trim(),
        gender: _gender,
        dob: _dobController.text.trim(),
        nidNumber: _nidController.text.trim(),
        policeStationId: _policeStationId!,
      );

      final repo = ref.read(customerRepositoryProvider);
      final response = await repo.create(
        request,
        _selectedImage,
        imageBytes: _selectedImageBytes,
        imageName: _selectedImageName,
      );

      ref.invalidate(customerListProvider);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: AppTheme.success, size: 28),
              SizedBox(width: 10),
              Text('Registration Successful!'),
            ],
          ),
          content: Text(
            'Welcome ${response.name}! Your customer account has been registered successfully. You can now sign in with your credentials.',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.white),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('PROCEED TO LOGIN'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = apiErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text('Customer Self-Registration', style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ── Header Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.indigoDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Customer Profile Account',
                            style: TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Join SCM Enterprise Network to manage purchase orders, track parcels, and view billing statements',
                            style: TextStyle(color: AppTheme.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Error Banner ──
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.danger, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppTheme.danger),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Form Container ──
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Account Credentials
                    _buildSectionCard(
                      title: '1. ACCOUNT & CONTACT CREDENTIALS',
                      icon: Icons.badge_outlined,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name *',
                            hint: 'e.g. Rashed Khan',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Full Name is required' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address *',
                            hint: 'customer@domain.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Mobile Phone Number *',
                            hint: '01XXXXXXXXX',
                            icon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Phone number is required';
                              if (v.trim().length < 11) return 'Enter a valid 11-digit mobile number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _passwordController,
                                  label: 'Password *',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscureText: !_showPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppTheme.grey),
                                    onPressed: () => setState(() => _showPassword = !_showPassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Password is required';
                                    if (v.length < 6) return 'Minimum 6 characters';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password *',
                                  hint: '••••••••',
                                  icon: Icons.lock_clock_outlined,
                                  obscureText: !_showConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppTheme.grey),
                                    onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Confirm password is required';
                                    if (v != _passwordController.text) return 'Passwords do not match';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Personal Information & Avatar
                    _buildSectionCard(
                      title: '2. PERSONAL DETAILS & PROFILE AVATAR',
                      icon: Icons.account_circle_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image Picker
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: AppTheme.blueLight,
                                        backgroundImage: _selectedImageBytes != null
                                            ? MemoryImage(_selectedImageBytes!)
                                            : (_selectedImage != null ? FileImage(_selectedImage!) as ImageProvider : null),
                                        child: (_selectedImageBytes == null && _selectedImage == null)
                                            ? const Icon(Icons.person, size: 45, color: AppTheme.primary)
                                            : null,
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
                                const SizedBox(height: 6),
                                Text(
                                  (_selectedImageBytes == null && _selectedImage == null)
                                      ? 'Tap to upload profile photo (Optional)'
                                      : 'Photo attached (${_selectedImageName ?? 'profile.jpg'})',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.grey, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Gender Selector
                          const Text('Gender *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          const SizedBox(height: 6),
                          Row(
                            children: ['MALE', 'FEMALE', 'OTHER'].map((g) {
                              final selected = _gender == g;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ChoiceChip(
                                    label: SizedBox(
                                      width: double.infinity,
                                      child: Text(g, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? AppTheme.white : AppTheme.dark)),
                                    ),
                                    selected: selected,
                                    selectedColor: AppTheme.primary,
                                    backgroundColor: AppTheme.light,
                                    onSelected: (val) {
                                      if (val) setState(() => _gender = g);
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),

                          // Date of Birth & NID Number
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _dobController,
                                  label: 'Date of Birth *',
                                  hint: 'YYYY-MM-DD',
                                  icon: Icons.calendar_today_outlined,
                                  readOnly: true,
                                  onTap: _selectDate,
                                  suffixIcon: const Icon(Icons.calendar_month, size: 18, color: AppTheme.primary),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Date of Birth is required' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _nidController,
                                  label: 'National ID (NID) *',
                                  hint: '10/13/17 digits',
                                  icon: Icons.credit_card_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'NID Number is required' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Location Cascade & Shipping Address
                    _buildSectionCard(
                      title: '3. REGIONAL MATRIX BASE & FULL ADDRESS',
                      icon: Icons.location_on_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Country → Division → District → Police Station Cascade *',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
                          ),
                          const SizedBox(height: 8),

                          // Reusable Cascaded Location Picker
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.light,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderGrey),
                            ),
                            child: LocationCascade(
                              onChanged: (selection) {
                                setState(() {
                                  _policeStationId = selection.policeStationId;
                                  _currentLocation = selection;
                                  _updateFullAddress();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Local Street Address Vector Input
                          _buildTextField(
                            controller: _streetAddressController,
                            label: 'Local Street Vector / House / Road *',
                            hint: 'e.g. House #12, Road #4, Sector 7',
                            icon: Icons.home_outlined,
                            onChanged: (_) => _updateFullAddress(),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Street address is required' : null,
                          ),
                          const SizedBox(height: 14),

                          // Auto-Generated Full Address Field & Live Manifest Box
                          const Text(
                            'Aggregated Manifest Full Address (Auto-Filled) *',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.blueLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.location_city_outlined, size: 16, color: AppTheme.primary),
                                    SizedBox(width: 6),
                                    Text(
                                      'AUTO-GENERATED FULL ADDRESS MANIFEST',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _addressController.text.isNotEmpty
                                      ? _addressController.text
                                      : 'Awaiting location cascade & street address input...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _addressController.text.isNotEmpty ? AppTheme.dark : AppTheme.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _registerCustomer,
                        icon: _isSubmitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white))
                            : const Icon(Icons.cloud_upload_outlined, size: 20),
                        label: Text(
                          _isSubmitting ? 'REGISTERING ACCOUNT...' : 'REGISTER CUSTOMER ACCOUNT',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?', style: TextStyle(fontSize: 12, color: AppTheme.secondary)),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            child: const Text('Sign In Here', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark, letterSpacing: 0.5)),
            ],
          ),
          const Divider(color: AppTheme.borderGrey, height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.dark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: AppTheme.secondary, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11, color: AppTheme.grey),
        prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      ),
      validator: validator,
    );
  }
}
