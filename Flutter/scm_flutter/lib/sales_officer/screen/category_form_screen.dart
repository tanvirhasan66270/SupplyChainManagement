import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/catagory_model.dart';
import 'package:scm_flutter/product/provider/catagory_provider.dart';
import 'package:scm_flutter/product/screen/category_data_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.categoryToEdit});

  final CategoryResponseModel? categoryToEdit;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String name;
  late String description;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    name = widget.categoryToEdit?.categoryName ?? '';
    description = widget.categoryToEdit?.description ?? '';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(categoryRepositoryProvider);
      final req = CategoryRequestModel(categoryName: name.trim(), description: description.trim());

      if (widget.categoryToEdit != null) {
        await repo.update(widget.categoryToEdit!.id, req);
      } else {
        await repo.save(req);
      }

      ref.invalidate(categoryListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.categoryToEdit != null
                ? 'Category updated successfully!'
                : 'Category configuration committed successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving category: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.categoryToEdit != null;
    const primaryGreen = AppTheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Green Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: primaryGreen,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: AppTheme.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isEdit ? 'Modify Category Node' : 'Register New Node Category',
                            style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.white,
                      side: BorderSide(color: AppTheme.white.withValues(alpha: 0.7)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.list_alt, size: 14),
                    label: const Text('View All Categories', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoryDataScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field 1: Category Cluster Name
                      _buildLabel('CATEGORY CLUSTER NAME', Icons.description_outlined, primaryGreen),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: name,
                        decoration: _inputDecoration(primaryGreen).copyWith(
                          hintText: 'e.g., Electronics, Raw Materials',
                          prefixIcon: const Icon(Icons.local_offer_outlined, size: 18, color: AppTheme.secondary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Category name is required!' : null,
                        onChanged: (val) => name = val,
                      ),
                      const SizedBox(height: 24),

                      // Field 2: Descriptive Meta Definition
                      _buildLabel('DESCRIPTIVE META DEFINITION', Icons.description_outlined, primaryGreen),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: description,
                        maxLines: 5,
                        decoration: _inputDecoration(primaryGreen).copyWith(
                          hintText: 'Enter classification metrics or operational criteria parameters...',
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        onChanged: (val) => description = val,
                      ),
                      const SizedBox(height: 40),

                      // Footer Action Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submitForm,
                              icon: _isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.cloud_upload_outlined, size: 18),
                              label: Text(_isLoading ? 'Committing...' : 'Commit Configuration', style: const TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
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
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      _formKey.currentState?.reset();
                                      setState(() {
                                        name = '';
                                        description = '';
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.borderGrey),
                                foregroundColor: primaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark, letterSpacing: 0.5),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(Color focusColor) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: focusColor, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}