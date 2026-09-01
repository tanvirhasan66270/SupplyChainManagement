import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/commercial_officer/provider/lc_bank_provider.dart';
import 'package:scm_flutter/commercial_officer/screen/lc_bank_form_screen.dart';
import 'package:scm_flutter/entity/lc_bank.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class LCBankDataScreen extends ConsumerStatefulWidget {
  const LCBankDataScreen({super.key});

  @override
  ConsumerState<LCBankDataScreen> createState() => _LCBankDataScreenState();
}

class _LCBankDataScreenState extends ConsumerState<LCBankDataScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteBank(LCBankResponseModel bank) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Definitively wipe "${bank.name}" (${bank.swiftCode}) from enterprise matrix? Active LCs may lose bank references.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Purge Profile', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(lcBankControllerProvider.notifier).deleteBank(bank.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'LC Bank profile pruned from cluster successfully' : 'Failed to delete bank profile'),
            backgroundColor: success ? AppTheme.success : AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lcBankListAsync = ref.watch(lcBankListProvider);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'SWIFT Banking Terminals',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            tooltip: 'Add Banking Terminal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LCBankFormScreen()),
              );
            },
          ),
          const DynamicNotificationButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(lcBankListProvider);
        },
        child: lcBankListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error loading LC Bank directory: $err',
                style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          data: (banks) {
            final totalCount = banks.length;
            final totalSwift = banks.where((b) => b.swiftCode.isNotEmpty).length;

            final filteredBanks = banks.where((b) {
              final query = _searchQuery.toLowerCase();
              return query.isEmpty ||
                  b.name.toLowerCase().contains(query) ||
                  b.swiftCode.toLowerCase().contains(query) ||
                  b.branchName.toLowerCase().contains(query) ||
                  b.contactEmail.toLowerCase().contains(query);
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Metric Pipeline Banner ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.dark, AppTheme.indigoDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_outlined, color: AppTheme.blueLight, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'SWIFT Institutional Directory',
                                  style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: AppTheme.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add, size: 14),
                              label: const Text('Add Terminal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LCBankFormScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBannerMetric('BANKING TERMINALS', '$totalCount', AppTheme.white),
                            _buildBannerMetric('SWIFT INDEXES', '$totalSwift', AppTheme.blueLight),
                            _buildBannerMetric('ACTIVE CLUSTER', '100%', AppTheme.success),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Search Bar ──
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Bank Name, SWIFT Code, Branch...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderGrey),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Bank Cards List ──
                  if (filteredBanks.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.account_balance_outlined, size: 48, color: AppTheme.grey),
                          SizedBox(height: 12),
                          Text(
                            'No SWIFT banking directory entities registered in SCM cloud.',
                            style: TextStyle(color: AppTheme.grey, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final b = filteredBanks[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Institution Title, Node Ref, SWIFT Code Badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.business, color: AppTheme.indigoDark, size: 18),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  b.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.dark),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Node Reference: #${b.id}',
                                            style: const TextStyle(fontSize: 10, color: AppTheme.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.dark,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        b.swiftCode,
                                        style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Grid Details
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.light,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.borderGrey),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('BRANCH SPECIFICATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text(b.branchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.indigoDark)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('GATEWAY EMAIL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text(b.contactEmail.isNotEmpty ? b.contactEmail : 'N/A', style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontFamily: 'monospace')),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('HOTLINE PHONE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text(b.contactPhone.isNotEmpty ? b.contactPhone : 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.success)),
                                        ],
                                      ),
                                      if (b.address.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('ADDRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                b.address,
                                                style: const TextStyle(fontSize: 10, color: AppTheme.indigoDark),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Divider(height: 16),

                                // Actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.warning,
                                        foregroundColor: AppTheme.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.edit, size: 14),
                                      label: const Text('Modify Terminal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LCBankFormScreen(bankToEdit: b),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.danger,
                                        foregroundColor: AppTheme.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.delete_outline, size: 14),
                                      label: const Text('Purge Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () => _deleteBank(b),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Widget _buildBannerMetric(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppTheme.grey, fontSize: 8, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
