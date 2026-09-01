import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/commercial_officer/provider/lc_bank_provider.dart';
import 'package:scm_flutter/entity/lc_bank.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class LCBankFormScreen extends ConsumerStatefulWidget {
  const LCBankFormScreen({super.key, this.bankToEdit});

  final LCBankResponseModel? bankToEdit;

  @override
  ConsumerState<LCBankFormScreen> createState() => _LCBankFormScreenState();
}

class _LCBankFormScreenState extends ConsumerState<LCBankFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String name = '';
  String swiftCode = '';
  String branchName = '';
  String address = '';
  String contactEmail = '';
  String contactPhone = '';

  @override
  void initState() {
    super.initState();
    if (widget.bankToEdit != null) {
      final b = widget.bankToEdit!;
      name = b.name;
      swiftCode = b.swiftCode;
      branchName = b.branchName;
      address = b.address;
      contactEmail = b.contactEmail;
      contactPhone = b.contactPhone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bankToEdit != null;

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
                  colors: [AppTheme.dark, AppTheme.indigoDark, AppTheme.primary],
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
                      Text(
                        isEdit ? 'Modify Terminal Context' : 'Register SWIFT Terminal',
                        style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
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

            // ২. Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field 1: Financial Institution Name
                      _buildNumberedLabel(1, 'FINANCIAL INSTITUTION NAME *', Icons.account_balance),
                      TextFormField(
                        initialValue: name,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. Standard Chartered Bank',
                          prefixIcon: const Icon(Icons.account_balance_outlined, size: 18, color: AppTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Institution name is required!' : null,
                        onChanged: (val) => name = val,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 16),
                        child: Text('Enter the name of the financial institution.', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                      ),

                      // Field 2: SWIFT Routing Code
                      _buildNumberedLabel(2, 'SWIFT ROUTING CODE *', Icons.code),
                      TextFormField(
                        initialValue: swiftCode,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. SCBLBDDHXXX',
                          prefixIcon: const Icon(Icons.language, size: 18, color: AppTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'SWIFT routing code is required!' : null,
                        onChanged: (val) => swiftCode = val,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 16),
                        child: Text('Enter the SWIFT routing code.', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                      ),

                      // Field 3: Branch Name / Specification
                      _buildNumberedLabel(3, 'BRANCH NAME / SPECIFICATION *', Icons.place_outlined),
                      TextFormField(
                        initialValue: branchName,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. Gulshan Branch',
                          prefixIcon: const Icon(Icons.business_outlined, size: 18, color: AppTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Branch specification is required!' : null,
                        onChanged: (val) => branchName = val,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 16),
                        child: Text('Enter the branch name or specification.', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                      ),

                      // Field 4: Corporate Gateway Email (LC Desk)
                      _buildNumberedLabel(4, 'CORPORATE GATEWAY EMAIL (LC DESK) *', Icons.email_outlined),
                      TextFormField(
                        initialValue: contactEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. lc.desk@bank.com',
                          prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Gateway email is required!' : null,
                        onChanged: (val) => contactEmail = val,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 16),
                        child: Text('Enter the corporate gateway email for LC desk.', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                      ),

                      // Field 5: Official Hotline Phone Number
                      _buildNumberedLabel(5, 'OFFICIAL HOTLINE PHONE NUMBER *', Icons.phone_outlined),
                      TextFormField(
                        initialValue: contactPhone,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. +8802998833',
                          prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Hotline phone number is required!' : null,
                        onChanged: (val) => contactPhone = val,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 16),
                        child: Text('Enter the official hotline phone number.', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                      ),

                      // Field 6: Institutional Physical Address
                      _buildNumberedLabel(6, 'INSTITUTIONAL PHYSICAL ADDRESS *', Icons.location_on_outlined),
                      TextFormField(
                        initialValue: address,
                        maxLines: 3,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'Full head office or branch terminal location details...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 32),
                            child: Icon(Icons.location_on_outlined, size: 18, color: AppTheme.primary),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Physical address is required!' : null,
                        onChanged: (val) => address = val,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 24),
                        child: Text('Enter the full physical address.', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                      ),

                      // Footer Action Buttons (Publish Banking Terminal & Clear)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                final request = LCBankRequestModel(
                                  name: name.trim(),
                                  swiftCode: swiftCode.trim(),
                                  branchName: branchName.trim(),
                                  address: address.trim(),
                                  contactEmail: contactEmail.trim(),
                                  contactPhone: contactPhone.trim(),
                                );

                                bool success = false;
                                if (isEdit && widget.bankToEdit != null) {
                                  success = await ref
                                      .read(lcBankControllerProvider.notifier)
                                      .updateBank(widget.bankToEdit!.id, request);
                                } else {
                                  success = await ref
                                      .read(lcBankControllerProvider.notifier)
                                      .createBank(request);
                                }

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('SWIFT Banking terminal registered successfully!'), backgroundColor: AppTheme.success),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.cloud_upload, size: 18),
                              label: Text(isEdit ? 'COMMIT CONFIGURATION' : 'PUBLISH BANKING TERMINAL'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                foregroundColor: AppTheme.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _formKey.currentState?.reset();
                                setState(() {
                                  name = '';
                                  swiftCode = '';
                                  branchName = '';
                                  address = '';
                                  contactEmail = '';
                                  contactPhone = '';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.borderGrey),
                                foregroundColor: AppTheme.dark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('CLEAR', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildNumberedLabel(int stepNum, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Center(
              child: Text(
                stepNum.toString(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.indigoDark),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}