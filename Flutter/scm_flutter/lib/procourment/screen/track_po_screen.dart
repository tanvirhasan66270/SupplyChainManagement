import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/po_line_item_model.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/suppplier/provider/po_line_item_provider.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class PurchaseOrderTrackingScreen extends ConsumerStatefulWidget {
  final String? initialPoNumber;

  const PurchaseOrderTrackingScreen({
    super.key,
    this.initialPoNumber,
  });

  @override
  ConsumerState<PurchaseOrderTrackingScreen> createState() => _PurchaseOrderTrackingScreenState();
}

class _PurchaseOrderTrackingScreenState extends ConsumerState<PurchaseOrderTrackingScreen> {
  final TextEditingController _searchController = TextEditingController();
  PurchaseOrderResponse? trackedPo;
  String _searchQuery = '';
  String? _errorMessage;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPoNumber != null && widget.initialPoNumber!.isNotEmpty) {
      _searchController.text = widget.initialPoNumber!;
      _searchQuery = widget.initialPoNumber!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _trackPo(List<PurchaseOrderResponse> allPOs) {
    setState(() {
      _errorMessage = null;
      _showSuggestions = false;
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) {
        _errorMessage = 'Please enter a valid Purchase Order number.';
        trackedPo = null;
        return;
      }

      final found = allPOs.where((po) {
        final numMatch = po.poNumber.toLowerCase().trim() == query;
        final idMatch = po.id.toString() == query;
        return numMatch || idMatch;
      }).firstOrNull;

      if (found != null) {
        trackedPo = found;
      } else {
        trackedPo = null;
        _errorMessage = 'No Purchase Order found matching "${_searchController.text}".';
      }
    });
  }

  void _selectPo(PurchaseOrderResponse po) {
    setState(() {
      trackedPo = po;
      _searchController.text = po.poNumber;
      _searchQuery = po.poNumber;
      _errorMessage = null;
      _showSuggestions = false;
    });
  }

  List<POLineItemResponseDTO> _getTrackedLineItems(List<POLineItemResponseDTO> allLineItems) {
    if (trackedPo == null) return [];
    return allLineItems.where((item) {
      final poIdMatch = item.poId == trackedPo!.id;
      final poNumMatch = item.poNumber.isNotEmpty &&
          item.poNumber.trim().toLowerCase() == trackedPo!.poNumber.trim().toLowerCase();
      return poIdMatch || poNumMatch;
    }).toList();
  }

  List<ShipmentResponseModel> _getTrackedShipments(List<ShipmentResponseModel> allShipments) {
    if (trackedPo == null) return [];
    return allShipments.where((s) {
      final poIdMatch = s.poId == trackedPo!.id;
      final poNumMatch = (s as dynamic).poNumber != null &&
          (s as dynamic).poNumber.toString().trim().toLowerCase() == trackedPo!.poNumber.trim().toLowerCase();
      return poIdMatch || poNumMatch;
    }).toList();
  }

  int _getAllocatedVolume(List<POLineItemResponseDTO> lineItems) {
    int total = 0;
    for (final item in lineItems) {
      total += item.quantity;
    }
    return total;
  }

  int _getShippedUnitsCount(List<ShipmentResponseModel> shipments, List<POLineItemResponseDTO> lineItems) {
    if (trackedPo == null) return 0;

    int totalFromShipments = 0;
    bool hasExplicitShipmentQty = false;

    for (final s in shipments) {
      if (s.shipmentQuantity > 0) {
        totalFromShipments += s.shipmentQuantity;
        hasExplicitShipmentQty = true;
      }
    }

    if (hasExplicitShipmentQty && totalFromShipments > 0) {
      return totalFromShipments;
    }

    final shippedLineItems = lineItems.where((item) =>
      ['SHIPPED', 'DELIVERED', 'RECEIVED'].contains(item.status.toUpperCase())
    );

    if (shippedLineItems.isNotEmpty) {
      int total = 0;
      for (final item in shippedLineItems) {
        total += item.quantity;
      }
      return total;
    }

    final poStatus = trackedPo!.status.toUpperCase();
    if (shipments.isNotEmpty || ['SHIPPED', 'RECEIVED', 'COMPLETE', 'APPROVED'].contains(poStatus)) {
      final allocated = _getAllocatedVolume(lineItems);
      return allocated > 0 ? allocated : trackedPo!.quantity;
    }

    return 0;
  }

  double _getPoProgressPercentage(int allocatedQty) {
    if (trackedPo == null || trackedPo!.quantity <= 0) return 0;
    final pct = (allocatedQty / trackedPo!.quantity) * 100;
    return pct > 100 ? 100 : pct;
  }

  double _getShippedProgressPercentage(int shippedQty) {
    if (trackedPo == null || trackedPo!.quantity <= 0) return 0;
    final pct = (shippedQty / trackedPo!.quantity) * 100;
    return pct > 100 ? 100 : pct;
  }

  int _getActiveStepsCount(List<POLineItemResponseDTO> lineItems, List<ShipmentResponseModel> shipments) {
    if (trackedPo == null) return 0;
    int activeCount = 1; // DRAFT is always active

    final status = trackedPo!.status.toUpperCase();
    if (['ISSUED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'COMPLETE', 'APPROVED'].contains(status)) {
      activeCount++;
    }
    if (['PARTIALLY_RECEIVED', 'RECEIVED', 'COMPLETE'].contains(status)) {
      activeCount++;
    }
    if (['RECEIVED', 'COMPLETE'].contains(status)) {
      activeCount++;
    }
    if (lineItems.isNotEmpty) {
      activeCount++;
    }
    if (shipments.isNotEmpty) {
      activeCount++;
    }
    if (['COMPLETE', 'RECEIVED'].contains(status) && shipments.isNotEmpty) {
      activeCount++;
    }
    return activeCount > 7 ? 7 : activeCount;
  }

  int _getOverallTrackingPercentage(int activeSteps, double allocationPct) {
    if (trackedPo == null) return 0;
    final stepProgress = (activeSteps / 7.0) * 100;
    final overall = (stepProgress + allocationPct) / 2.0;
    return overall.round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);
    final lineItemsAsync = ref.watch(poLineItemListProvider);
    final shipmentsAsync = ref.watch(shipmentListProvider);

    final allPOs = purchaseOrdersAsync.value ?? [];
    final allLineItems = lineItemsAsync.value ?? [];
    final allShipments = shipmentsAsync.value ?? [];

    // Auto select first match if trackedPo is null and search query was provided
    if (trackedPo == null && _searchQuery.isNotEmpty && allPOs.isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      trackedPo = allPOs.where((po) => po.poNumber.toLowerCase().contains(query) || po.id.toString() == query).firstOrNull;
    }

    final suggestions = _searchQuery.trim().isEmpty
        ? allPOs.take(8).toList()
        : allPOs.where((po) => po.poNumber.toLowerCase().contains(_searchQuery.toLowerCase()) || po.id.toString() == _searchQuery.trim()).toList();

    final trackedLineItems = _getTrackedLineItems(allLineItems);
    final trackedShipments = _getTrackedShipments(allShipments);
    final allocatedVolume = _getAllocatedVolume(trackedLineItems);
    final shippedUnits = _getShippedUnitsCount(trackedShipments, trackedLineItems);

    final allocationPct = _getPoProgressPercentage(allocatedVolume);
    final shippedPct = _getShippedProgressPercentage(shippedUnits);
    final activeSteps = _getActiveStepsCount(trackedLineItems, trackedShipments);
    final overallPct = _getOverallTrackingPercentage(activeSteps, allocationPct);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: DynamicScmTopNavBar(
        title: 'Track Purchase Order',
        showBackButton: true,
        onRefresh: () {
          ref.invalidate(purchaseOrderListProvider);
          ref.invalidate(poLineItemListProvider);
          ref.invalidate(shipmentListProvider);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Search Vector Card ───────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGrey),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search, color: AppTheme.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'PURCHASE ORDER TRACKING VECTOR',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Enter PO Number (e.g. #PO-1002)...',
                              hintStyle: const TextStyle(fontSize: 12, color: AppTheme.secondary),
                              prefixIcon: const Icon(Icons.numbers, color: AppTheme.secondary, size: 18),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          trackedPo = null;
                                          _errorMessage = null;
                                        });
                                      },
                                    )
                                  : null,
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                                _showSuggestions = true;
                              });
                            },
                            onTap: () => setState(() => _showSuggestions = true),
                            onSubmitted: (_) => _trackPo(allPOs),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.radar, size: 18),
                          label: const Text('Find', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () => _trackPo(allPOs),
                        ),
                      ],
                    ),

                    // Auto-complete suggestion chips / panel
                    if (_showSuggestions && suggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderGrey),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: suggestions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final po = suggestions[idx];
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              leading: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primary, size: 18),
                              title: Text(
                                po.poNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark, fontFamily: 'monospace'),
                              ),
                              subtitle: Text(
                                po.supplierName.isNotEmpty ? po.supplierName : 'Supplier #${po.supplierId}',
                                style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusColor(po.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  po.status,
                                  style: TextStyle(color: AppTheme.statusColor(po.status), fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              onTap: () => _selectPo(po),
                            );
                          },
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.danger, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 2. Placeholder if no PO selected ──────────
              if (trackedPo == null && _errorMessage == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.light),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.explore_outlined, size: 48, color: AppTheme.secondary),
                      SizedBox(height: 12),
                      Text(
                        'Select or search a Purchase Order number above to launch full dynamic tracking metrics.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.secondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              // ── 3. Dynamic Tracking Results (when trackedPo != null) ──
              if (trackedPo != null) ...[
                // Overall Tracking Progress Card
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
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'OVERALL TRACKING FULFILLMENT',
                                style: TextStyle(color: AppTheme.primaryLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trackedPo!.poNumber,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$overallPct% COMPLETED',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: overallPct / 100.0,
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$activeSteps of 7 Workflow Milestones Completed',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                          Text(
                            'Status: ${trackedPo!.status}',
                            style: const TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Milestone Stepper & Details Grid ─────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 750;
                    return isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildMilestoneStepper(trackedLineItems, trackedShipments, allocationPct, shippedPct)),
                              const SizedBox(width: 14),
                              Expanded(flex: 4, child: _buildPoSummaryVector(allocatedVolume, shippedUnits, trackedLineItems)),
                            ],
                          )
                        : Column(
                            children: [
                              _buildMilestoneStepper(trackedLineItems, trackedShipments, allocationPct, shippedPct),
                              const SizedBox(height: 14),
                              _buildPoSummaryVector(allocatedVolume, shippedUnits, trackedLineItems),
                            ],
                          );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Milestone Stepper (Vertical Timeline) ──
  Widget _buildMilestoneStepper(
    List<POLineItemResponseDTO> lineItems,
    List<ShipmentResponseModel> shipments,
    double allocationPct,
    double shippedPct,
  ) {
    final status = trackedPo?.status.toUpperCase() ?? '';

    final isDraftDone = true;
    final isIssuedDone = ['ISSUED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'COMPLETE', 'APPROVED'].contains(status);
    final isPartiallyDone = ['PARTIALLY_RECEIVED', 'RECEIVED', 'COMPLETE'].contains(status);
    final isReceivedDone = ['RECEIVED', 'COMPLETE'].contains(status);
    final isProcessDone = lineItems.isNotEmpty;
    final isShipmentDone = shipments.isNotEmpty || status == 'SHIPPED';
    final isCompleteDone = ['COMPLETE', 'RECEIVED'].contains(status) && shipments.isNotEmpty;
    final isCancelled = status == 'CANCELLED';

    int processedUnits = 0;
    for (final item in lineItems) {
      processedUnits += item.quantity;
    }

    int shippedUnits = 0;
    if (shipments.isNotEmpty) {
      shippedUnits = shipments.first.shipmentQuantity;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.light),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PURCHASE ORDER MILESTONE TIMELINE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.secondary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 14),
          _buildStepItem(1, 'DRAFT', 'Purchase order created and prepared for review.', isDraftDone, isLast: false),
          _buildStepItem(2, 'ISSUED', 'Purchase order dispatched to supplier.', isIssuedDone, isLast: false),
          _buildStepItem(3, 'PARTIALLY RECEIVED', 'Items partially received and logged at warehouse.', isPartiallyDone, isLast: false),
          _buildStepItem(4, 'RECEIVED', 'All items received at destination warehouse.', isReceivedDone, isLast: false),
          _buildStepItem(5, 'PROCESS', '$processedUnits Units processed (${allocationPct.round()}%).', isProcessDone, isLast: false, progressPct: allocationPct),
          _buildStepItem(6, 'SHIPMENT', '$shippedUnits Units shipped (${shippedPct.round()}%).', isShipmentDone, isLast: false, progressPct: shippedPct),
          if (isCancelled)
            _buildStepItem(7, 'CANCELLED', 'Purchase order has been voided/cancelled.', true, isLast: true, isCancelled: true)
          else
            _buildStepItem(7, 'COMPLETE', 'Order completed, verified, and closed.', isCompleteDone, isLast: true),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    int stepNum,
    String title,
    String description,
    bool isCompleted, {
    required bool isLast,
    double? progressPct,
    bool isCancelled = false,
  }) {
    final stepColor = isCancelled
        ? AppTheme.danger
        : (isCompleted ? AppTheme.success : AppTheme.secondary.withValues(alpha: 0.4));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stepper Indicator Column
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? stepColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 2),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(isCancelled ? Icons.close : Icons.check, size: 14, color: Colors.white)
                    : Text('$stepNum', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stepColor)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? AppTheme.success : AppTheme.borderGrey,
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Stepper Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isCancelled ? AppTheme.danger : (isCompleted ? AppTheme.dark : AppTheme.secondary),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
              ),
              if (progressPct != null && isCompleted) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPct / 100.0,
                    minHeight: 4,
                    backgroundColor: AppTheme.light,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // ── PO Summary & Line Items Table ──────────
  Widget _buildPoSummaryVector(
    int allocatedVolume,
    int shippedUnits,
    List<POLineItemResponseDTO> lineItems,
  ) {
    if (trackedPo == null) return const SizedBox.shrink();

    final formattedDate = trackedPo!.expectedDeliveryDate.contains('T')
        ? trackedPo!.expectedDeliveryDate.split('T').first
        : trackedPo!.expectedDeliveryDate;

    return Column(
      children: [
        // Meta Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.light),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PURCHASE ORDER METADATA VECTOR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.secondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              _buildMetaRow('PO Reference ID', trackedPo!.poNumber),
              _buildMetaRow('Target Supplier', trackedPo!.supplierName.isNotEmpty ? trackedPo!.supplierName : 'Supplier #${trackedPo!.supplierId}'),
              _buildMetaRow('Contract Valuation', '\$${trackedPo!.totalAmount.toStringAsFixed(2)} ${trackedPo!.currency}'),
              _buildMetaRow('Order Total Volume', '${trackedPo!.quantity} Units'),
              _buildMetaRow('Allocated Production Qty', '$allocatedVolume Units'),
              _buildMetaRow('Shipped Volume', '$shippedUnits Units'),
              _buildMetaRow('Expected Target Date', formattedDate),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Line Items Table
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.light),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PRODUCT SPECIFICATION LINE ITEMS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.secondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              if (lineItems.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('No line items allocated to this PO yet.', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                  ),
                ),
              ] else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    horizontalMargin: 8,
                    headingRowHeight: 32,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 44,
                    headingRowColor: WidgetStateProperty.all(AppTheme.light),
                    columns: const [
                      DataColumn(label: Text('Product Specification', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Qty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Unit Price', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Subtotal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                    ],
                    rows: lineItems.map((item) {
                      final subtotal = item.quantity * item.unitPrice;
                      final prodName = item.productName.isNotEmpty
                          ? item.productName
                          : 'Product #${item.productId}';
                      final status = item.status;
                      return DataRow(
                        cells: [
                          DataCell(Text(prodName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                          DataCell(Text('${item.quantity}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                          DataCell(Text('\$${item.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                          DataCell(Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success, fontFamily: 'monospace'))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.statusColor(status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(status, style: TextStyle(color: AppTheme.statusColor(status), fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.secondary)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
