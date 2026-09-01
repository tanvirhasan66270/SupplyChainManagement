import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/supplier_model.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/suppplier/screen/supplier_form_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class SupplierDataScreen extends ConsumerStatefulWidget {
  const SupplierDataScreen({super.key});

  @override
  ConsumerState<SupplierDataScreen> createState() => _SupplierDataScreenState();
}

class _SupplierDataScreenState extends ConsumerState<SupplierDataScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDeleteSupplier(SupplierResponseDTO supplier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier Node', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to delete supplier "${supplier.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(supplierControllerProvider.notifier).deleteSupplier(supplier.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Supplier "${supplier.name}" deleted successfully.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete supplier: $e'), backgroundColor: AppTheme.danger),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supplierListAsync = ref.watch(supplierListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: DynamicScmTopNavBar(
        title: 'Supplier Matrix Directory',
        showBackButton: true,
        onRefresh: () => ref.invalidate(supplierListProvider),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(supplierListProvider),
          child: supplierListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load supplier directory: $err', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(supplierListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (suppliers) {
              final filtered = suppliers.where((sup) {
                final q = _searchQuery.toLowerCase().trim();
                if (q.isEmpty) return true;
                final nameMatch = sup.name.toLowerCase().contains(q);
                final contactMatch = sup.contactPerson.toLowerCase().contains(q);
                final emailMatch = sup.email.toLowerCase().contains(q);
                final phoneMatch = sup.phone.contains(q);
                final addressMatch = sup.address.toLowerCase().contains(q) ||
                    sup.districtName.toLowerCase().contains(q) ||
                    sup.divisionName.toLowerCase().contains(q);
                final idMatch = sup.id.toString() == q;
                return nameMatch || contactMatch || emailMatch || phoneMatch || addressMatch || idMatch;
              }).toList();

              final totalSuppliers = suppliers.length;
              final avgRating = suppliers.isNotEmpty
                  ? (suppliers.map((s) => s.rating).reduce((a, b) => a + b) / suppliers.length).toStringAsFixed(1)
                  : '5.0';

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Header Metrics Banner (Android Responsive) ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.store_mall_directory_outlined, color: Colors.blueAccent, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'SUPPLIER NETWORK DIRECTORY',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.white30)),
                                ),
                                icon: const Icon(Icons.person_add, size: 14),
                                label: const Text('Add Supplier', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SupplierFormScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 500;
                              if (isMobile) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _buildBannerMetric('Registered Suppliers', '$totalSuppliers', Colors.white)),
                                        Expanded(child: _buildBannerMetric('Network Avg Rating', '$avgRating ⭐', const Color(0xFFFBBF24))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(child: _buildBannerMetric('Active Cluster Nodes', '${suppliers.length}', const Color(0xFF60A5FA))),
                                        Expanded(child: _buildBannerMetric('Verified Status', '100% OK', const Color(0xFF4ADE80))),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: _buildBannerMetric('Registered Suppliers', '$totalSuppliers', Colors.white)),
                                  Expanded(child: _buildBannerMetric('Network Avg Rating', '$avgRating ⭐', const Color(0xFFFBBF24))),
                                  Expanded(child: _buildBannerMetric('Active Cluster Nodes', '${suppliers.length}', const Color(0xFF60A5FA))),
                                  Expanded(child: _buildBannerMetric('Verified Status', '100% OK', const Color(0xFF4ADE80))),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 2. Search Input ──
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Supplier by Name, Contact, Email, Phone or Address...',
                        hintStyle: const TextStyle(fontSize: 12, color: AppTheme.secondary),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.secondary, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),

                    const SizedBox(height: 14),

                    // ── 3. Supplier Cards List ──
                    if (filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.light)),
                        child: const Column(
                          children: [
                            Icon(Icons.people_outline, size: 48, color: AppTheme.secondary),
                            SizedBox(height: 8),
                            Text('No suppliers match your search criteria.', style: TextStyle(color: AppTheme.secondary, fontSize: 12)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final sup = filtered[index];
                          final locStr = [
                            if (sup.policeStationName.isNotEmpty) sup.policeStationName,
                            if (sup.districtName.isNotEmpty) sup.districtName,
                            if (sup.divisionName.isNotEmpty) sup.divisionName,
                          ].join(', ');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.light),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Supplier Name & ID Badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              sup.name.isNotEmpty ? sup.name[0].toUpperCase() : 'S',
                                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sup.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.dark),
                                                ),
                                                Text(
                                                  'Contact: ${sup.contactPerson.isNotEmpty ? sup.contactPerson : "N/A"}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.dark,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '#SUP-${sup.id}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 18),

                                // Contact Info & Rating Matrix
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.email_outlined, size: 12, color: AppTheme.primary),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  sup.email,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 11, color: AppTheme.dark, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone_outlined, size: 12, color: AppTheme.success),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  sup.phone,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 11, color: AppTheme.dark, fontFamily: 'monospace'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFF59E0B)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star, size: 11, color: Color(0xFFD97706)),
                                              const SizedBox(width: 2),
                                              Text('${sup.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFFB45309))),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('Lead Time: ${sup.averageLeadTimeDays}d', style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Address line
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.secondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          sup.address.isNotEmpty
                                              ? '${sup.address}${locStr.isNotEmpty ? " - $locStr" : ""}'
                                              : (locStr.isNotEmpty ? locStr : 'Location N/A'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Bottom Action Buttons Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 24)),
                                          icon: const Icon(Icons.shopping_cart_outlined, size: 14, color: AppTheme.primary),
                                          label: const Text('View Orders', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/purchase-orders');
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: 'Edit Supplier',
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => SupplierFormScreen(supplierToEdit: sup)),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          tooltip: 'Delete Supplier',
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                                          onPressed: () => _confirmDeleteSupplier(sup),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupplierFormScreen()),
          );
        },
      ),
    );
  }

  Widget _buildBannerMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}
