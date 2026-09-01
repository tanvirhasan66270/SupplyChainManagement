import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/commercial_officer/provider/letter_of_credit_provider.dart';
import 'package:scm_flutter/commercial_officer/screen/letter_of_credit_form_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/letter_of_credit_pdf_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/lc_bank_data_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class LetterOfCreditDataScreen extends ConsumerStatefulWidget {
  const LetterOfCreditDataScreen({super.key});

  @override
  ConsumerState<LetterOfCreditDataScreen> createState() => _LetterOfCreditDataScreenState();
}

class _LetterOfCreditDataScreenState extends ConsumerState<LetterOfCreditDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPENED':
        return AppTheme.success;
      case 'AMENDED':
        return AppTheme.primary;
      case 'DRAFT':
        return AppTheme.warning;
      case 'EXPIRED':
      case 'CANCELLED':
        return AppTheme.danger;
      default:
        return AppTheme.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lcAsync = ref.watch(letterOfCreditListProvider);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Letter of Credit (LC) Directory',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(letterOfCreditListProvider);
        },
        child: lcAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load LC records: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(letterOfCreditListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (lcs) {
            // Apply filtering & searching
            final filteredLCs = lcs.where((lc) {
              final matchesSearch = _searchQuery.isEmpty ||
                  lc.lcNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  lc.issuingBankName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  lc.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  lc.poNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  lc.lcStatus.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  lc.lcStatus.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesStatus;
            }).toList();

            // Calculate metrics totals
            double totalValuation = 0;
            int activeOpened = 0;
            int amendedCount = 0;

            for (var l in lcs) {
              totalValuation += l.amount;
              if (l.lcStatus.toUpperCase() == 'OPENED') activeOpened++;
              if (l.lcStatus.toUpperCase() == 'AMENDED' || l.amendmentCount > 0) amendedCount++;
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Metrics Summary Banner ──
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
                                  'TRADE FINANCE PIPELINE SUMMARY',
                                  style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LCBankDataScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.account_balance, size: 14),
                                  label: const Text('SWIFT Banks', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.indigoDark,
                                    foregroundColor: AppTheme.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LetterOfCreditFormScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 14),
                                  label: const Text('Initiate LC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: AppTheme.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBannerMetric('Total LCs', '${lcs.length}', AppTheme.white),
                            ),
                            Expanded(
                              child: _buildBannerMetric('Total Valuation', '\$${totalValuation.toStringAsFixed(0)}', AppTheme.blueLight),
                            ),
                            Expanded(
                              child: _buildBannerMetric('Opened LCs', '$activeOpened', AppTheme.success),
                            ),
                            Expanded(
                              child: _buildBannerMetric('Amendments', '$amendedCount', AppTheme.danger),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Search Control ───────────────────
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by LC #, bank, supplier, or PO reference...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Status Filter Chips ─────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['ALL', 'OPENED', 'AMENDED', 'DRAFT', 'EXPIRED', 'CANCELLED'].map((status) {
                        final isSelected = _selectedStatusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(
                              status == 'ALL' ? 'All LCs (${lcs.length})' : status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.white : AppTheme.dark,
                              ),
                            ),
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.white,
                            checkmarkColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderGrey),
                            ),
                            onSelected: (_) => setState(() => _selectedStatusFilter = status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── LC Data Cards List ───────────────────
                  if (filteredLCs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: AppTheme.grey),
                          SizedBox(height: 12),
                          Text('No letters of credit found.', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.grey, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or status filter.', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredLCs.length,
                      itemBuilder: (context, index) {
                        final lc = filteredLCs[index];
                        final statusColor = _getStatusColor(lc.lcStatus);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderGrey),
                            boxShadow: [
                              BoxShadow(color: AppTheme.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: const BoxDecoration(
                                  color: AppTheme.light,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  border: Border(bottom: BorderSide(color: AppTheme.borderGrey)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(color: AppTheme.dark, borderRadius: BorderRadius.circular(6)),
                                          child: Text(
                                            lc.lcNumber.isNotEmpty ? lc.lcNumber : 'NOT-OPENED',
                                            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                                          ),
                                        ),
                                        if (lc.documentVaultUrl.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppTheme.blueLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.file_present, size: 10, color: AppTheme.primary),
                                                SizedBox(width: 2),
                                                Text('SWIFT COPY', style: TextStyle(fontSize: 8, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        lc.lcStatus,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Card Details Grid
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildDetailLabel('PARENT ORDER'),
                                              Text(
                                                'PO #${lc.poNumber.isNotEmpty ? lc.poNumber : lc.purchaseOrderId}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark),
                                              ),
                                              const SizedBox(height: 8),
                                              _buildDetailLabel('ISSUING BANK'),
                                              Text(
                                                lc.issuingBankName.isNotEmpty ? lc.issuingBankName : 'Central Commercial Bank',
                                                style: const TextStyle(fontSize: 11, color: AppTheme.dark),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildDetailLabel('SUPPLIER BENEFICIARY'),
                                              Text(
                                                lc.supplierName,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              _buildDetailLabel('INCOTERMS & PORTS'),
                                              Text(
                                                '${lc.shipmentIncoTerms} | ${lc.portOfLoading.isNotEmpty ? lc.portOfLoading : "Port"} ➔ ${lc.portOfDischarge.isNotEmpty ? lc.portOfDischarge : "Port"}',
                                                style: const TextStyle(fontSize: 11, color: AppTheme.dark),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.grey),
                                        const SizedBox(width: 4),
                                        Text('Shipment: ${lc.latestShipmentDate}', style: const TextStyle(fontSize: 10, color: AppTheme.grey)),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.event_busy_outlined, size: 12, color: AppTheme.danger),
                                        const SizedBox(width: 4),
                                        Text('Expiry: ${lc.expiryDate}', style: const TextStyle(fontSize: 10, color: AppTheme.danger, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(height: 1, thickness: 1),

                              // Card Footer Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${lc.currency == "BDT" ? "৳" : "\$"}${lc.amount.toStringAsFixed(2)} ${lc.currency}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.success),
                                        ),
                                        Text('Amendments: ${lc.amendmentCount}', style: const TextStyle(fontSize: 9, color: AppTheme.grey)),
                                      ],
                                    ),

                                    // Action Buttons Row
                                    Row(
                                      children: [
                                        // PDF View Button
                                        IconButton(
                                          tooltip: 'View Document / PDF',
                                          icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primary, size: 20),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => LetterOfCreditPDFScreen(lc: lc)),
                                            );
                                          },
                                        ),

                                        // Apply Amendment (Patch) Button
                                        IconButton(
                                          tooltip: 'Apply Amendment (PATCH)',
                                          icon: const Icon(Icons.tune, color: AppTheme.warning, size: 20),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => LetterOfCreditFormScreen(lcToEdit: lc, isAmendMode: true)),
                                            );
                                          },
                                        ),

                                        // Edit Metadata Button
                                        IconButton(
                                          tooltip: 'Edit LC Configuration',
                                          icon: const Icon(Icons.edit_square, color: AppTheme.blue, size: 20),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => LetterOfCreditFormScreen(lcToEdit: lc, isAmendMode: false)),
                                            );
                                          },
                                        ),

                                        // Purge / Delete Button
                                        IconButton(
                                          tooltip: 'Purge LC Mapping',
                                          icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Purge Letter of Credit'),
                                                content: Text('Definitively purge Letter of Credit #${lc.lcNumber} from database?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: AppTheme.white),
                                                    child: const Text('Purge'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              final ok = await ref.read(letterOfCreditControllerProvider.notifier).deleteLC(lc.id);
                                              if (context.mounted && ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('LC record purged from database.'), backgroundColor: AppTheme.danger),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
    );
  }

  Widget _buildBannerMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.grey, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetailLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey, letterSpacing: 0.5),
    );
  }
}
