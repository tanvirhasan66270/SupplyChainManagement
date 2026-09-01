import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/supplier_model.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final SupplierResponseDTO? supplierToEdit;

  const SupplierFormScreen({super.key, this.supplierToEdit});

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController contactPersonController;
  late TextEditingController addressController;
  late TextEditingController nidController;
  late TextEditingController leadTimeController;
  late double rating;
  late String gender;

  @override
  void initState() {
    super.initState();
    final isEdit = widget.supplierToEdit != null;
    final s = widget.supplierToEdit;

    nameController = TextEditingController(text: isEdit ? s!.name : '');
    emailController = TextEditingController(text: isEdit ? s!.email : '');
    phoneController = TextEditingController(text: isEdit ? s!.phone : '');
    contactPersonController = TextEditingController(text: isEdit ? s!.contactPerson : '');
    addressController = TextEditingController(text: isEdit ? s!.address : '');
    nidController = TextEditingController(text: isEdit ? s!.nidNumber : '');
    leadTimeController = TextEditingController(text: isEdit ? s!.averageLeadTimeDays.toString() : '7');
    rating = isEdit ? s!.rating : 4.5;
    gender = isEdit ? (s!.gender.isNotEmpty ? s.gender : 'MALE') : 'MALE';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    contactPersonController.dispose();
    addressController.dispose();
    nidController.dispose();
    leadTimeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    contactPersonController.clear();
    addressController.clear();
    nidController.clear();
    leadTimeController.text = '7';
    setState(() {
      rating = 4.5;
      gender = 'MALE';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplierToEdit != null;

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Enterprise Bar (Fully Dynamic) ──
            DynamicScmTopNavBar(
              onRefresh: () => ref.invalidate(supplierListProvider),
            ),

            // ── 2. Blue Banner Header Card with View All Button ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.indigoDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back, color: AppTheme.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'Modify Supplier Profile' : 'Register New Vendor / Supplier',
                              style: const TextStyle(color: AppTheme.white, fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Text(
                            'Onboard corporate vendor profiles and configure logistic parameters',
                            style: TextStyle(color: AppTheme.white.withValues(alpha: 0.7), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/suppliers');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.list_alt, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'View All',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 3. Form Content Scrollable Area ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Supplier / Company Name
                      _buildNumberedStepLabel(1, 'VENDOR / COMPANY NAME *'),
                      TextFormField(
                        controller: nameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Supplier / Company Name is required' : null,
                        decoration: _inputDecoration(icon: Icons.business, hint: 'Supplier / Company Name *'),
                      ),
                      const SizedBox(height: 14),

                      // Step 2: Email Address
                      _buildNumberedStepLabel(2, 'EMAIL ADDRESS *'),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                        decoration: _inputDecoration(icon: Icons.email_outlined, hint: 'vendor@domain.com'),
                      ),
                      const SizedBox(height: 14),

                      // Step 3: Phone Number
                      _buildNumberedStepLabel(3, 'PHONE NUMBER *'),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
                        decoration: _inputDecoration(icon: Icons.phone_outlined, hint: '+8801...'),
                      ),
                      const SizedBox(height: 14),

                      // Step 4: Contact Person
                      _buildNumberedStepLabel(4, 'CONTACT PERSON'),
                      TextFormField(
                        controller: contactPersonController,
                        decoration: _inputDecoration(icon: Icons.person_outline, hint: 'Manager / Owner Name'),
                      ),
                      const SizedBox(height: 14),

                      // Step 5: NID / Registration No
                      _buildNumberedStepLabel(5, 'NID / REGISTRATION NO'),
                      TextFormField(
                        controller: nidController,
                        decoration: _inputDecoration(icon: Icons.badge_outlined, hint: 'NID or Trade License No'),
                      ),
                      const SizedBox(height: 14),

                      // Step 6: Location Address
                      _buildNumberedStepLabel(6, 'LOCATION & LOGISTIC SPECIFICATIONS'),
                      TextFormField(
                        controller: addressController,
                        decoration: _inputDecoration(icon: Icons.location_on_outlined, hint: 'Full Business Address / Location *'),
                      ),
                      const SizedBox(height: 14),

                      // Step 7: Avg Lead Time
                      _buildNumberedStepLabel(7, 'AVG LEAD TIME (DAYS)'),
                      TextFormField(
                        controller: leadTimeController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(icon: Icons.timer_outlined, hint: '7'),
                      ),
                      const SizedBox(height: 14),

                      // Step 8: Performance Rating
                      _buildNumberedStepLabel(8, 'PERFORMANCE RATING: ${rating.toStringAsFixed(1)} ⭐'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderGrey),
                        ),
                        child: Slider(
                          value: rating,
                          min: 1.0,
                          max: 5.0,
                          divisions: 40,
                          activeColor: Colors.amber,
                          onChanged: (val) => setState(() => rating = val),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            final request = SupplierRequestDTO(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              phone: phoneController.text.trim(),
                              contactPerson: contactPersonController.text.trim().isNotEmpty ? contactPersonController.text.trim() : nameController.text.trim(),
                              address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : 'N/A',
                              nidNumber: nidController.text.trim().isNotEmpty ? nidController.text.trim() : 'N/A',
                              passportNumber: 'N/A',
                              gender: gender,
                              dob: '1990-01-01',
                              image: '',
                              rating: rating,
                              averageLeadTimeDays: int.tryParse(leadTimeController.text) ?? 7,
                              policeStationId: 1,
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);

                            bool success;
                            if (isEdit) {
                              success = await ref.read(supplierControllerProvider.notifier).updateSupplier(widget.supplierToEdit!.id, request, null);
                            } else {
                              success = await ref.read(supplierControllerProvider.notifier).createSupplier(request, null);
                            }

                            if (success) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? 'Supplier ${request.name} updated successfully!' : 'Supplier ${request.name} registered successfully!'),
                                  backgroundColor: const Color(0xFF16A34A),
                                ),
                              );
                              nav.pop();
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(isEdit ? 'COMMIT SUPPLIER MUTATIONS' : 'REGISTER SUPPLIER NODE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _resetForm,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.borderGrey),
                            foregroundColor: AppTheme.dark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CLEAR', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
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

  Widget _buildNumberedStepLabel(int stepNum, String label) {
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
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon, required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.secondary),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
    );
  }
}
