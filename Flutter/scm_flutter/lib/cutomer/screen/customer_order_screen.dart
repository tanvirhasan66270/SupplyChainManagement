import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiConstants.dart';
import 'dart:io';

class CustomerOrderItemEntry {
  CustomerOrderItemEntry({
    required this.product,
    required this.quantity,
    required this.remarks,
  });

  final ProductResponseModel product;
  int quantity;
  String remarks;

  OrderLineItemRequest toRequest() => OrderLineItemRequest(
    productId: product.id,
    quantity: quantity,
    remarks: remarks,
  );
}

class CustomerOrderScreen extends ConsumerStatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  ConsumerState<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends ConsumerState<CustomerOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // State Lists & Data
  List<ProductResponseModel> _products = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  // Identity & Role
  String _userRole = '';
  String _loggedInCustomerName = '';
  String _loggedInCustomerEmail = '';
  String _loggedInCustomerPhone = '';
  int _customerId = 0;

  // Item Allocation Inputs
  ProductResponseModel? _selectedProduct;
  int _allocationQuantity = 1;
  final TextEditingController _allocationNotesController = TextEditingController();

  // Selected Allocated Product Items
  final List<CustomerOrderItemEntry> _allocatedItems = [];

  // Order Settings
  String _selectedServiceType = ServiceType.standard;
  String _selectedPriority = Priority.normal;
  String _selectedPaymentMethod = PaymentMethod.cash;
  String _selectedEstimatedDelivery = 'Auto-Fixed by Priority Rule';

  // Text Controllers
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _codController;
  late TextEditingController _remarksController;
  late TextEditingController _accountNumberController;
  late TextEditingController _proofImageController;

  XFile? _paymentProofImage;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _codController = TextEditingController(text: '0');
    _remarksController = TextEditingController();
    _accountNumberController = TextEditingController();
    _proofImageController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _codController.dispose();
    _remarksController.dispose();
    _accountNumberController.dispose();
    _proofImageController.dispose();
    _allocationNotesController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _userRole = currentUser.role.toUpperCase();
      _loggedInCustomerName = currentUser.name;
      _loggedInCustomerEmail = currentUser.email;
      _customerId = currentUser.userId;

      if (_userRole == 'CUSTOMER') {
        _loadCustomerByUserId(currentUser.userId);
      }
    }
    await _loadProducts();
  }

  Future<void> _loadCustomerByUserId(int userId) async {
    try {
      final cust = await ref.read(customerRepositoryProvider).findByUserId(userId);
      if (mounted && cust != null && cust.id > 0) {
        setState(() {
          _customerId = cust.id;
          _loggedInCustomerName = cust.name;
          _loggedInCustomerEmail = cust.email;
          _loggedInCustomerPhone = cust.phone;
          if (cust.phone.isNotEmpty && _phoneController.text.isEmpty) {
            _phoneController.text = cust.phone;
          }
          if (cust.address.isNotEmpty && _addressController.text.isEmpty) {
            _addressController.text = cust.address;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    try {
      final list = await ref.read(productListProvider.future);
      if (mounted) {
        setState(() {
          _products = list;
          if (_products.isNotEmpty && _selectedProduct == null) {
            _selectedProduct = _products.first;
          }
        });
      }
    } catch (_) {}
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
    if (trimmed.startsWith('product/')) {
      return '${ApiConstants.imgUrl}$trimmed';
    }
    return '${ApiConstants.imgUrl}product/$trimmed';
  }

  // Financial Calculations
  double _calculateItemSubtotal() {
    double subtotal = 0.0;
    for (var item in _allocatedItems) {
      subtotal += item.product.sellingPrice * item.quantity;
    }
    return subtotal;
  }

  double _calculateTotalWeight() {
    double totalWeight = 0.0;
    for (var item in _allocatedItems) {
      totalWeight += item.product.weight * item.quantity;
    }
    return totalWeight;
  }

  double _calculateDeliveryCharge() {
    final weight = _calculateTotalWeight();
    double baseCharge = 60.0 + (weight * 15.0);
    if (_selectedServiceType == ServiceType.express) baseCharge *= 1.5;
    if (_selectedServiceType == ServiceType.overnight) baseCharge *= 2.0;
    if (_selectedServiceType == ServiceType.sameDay) baseCharge *= 2.5;
    return baseCharge.roundToDouble();
  }

  double _calculateTotalAmount() {
    return _calculateItemSubtotal() + _calculateDeliveryCharge();
  }

  double _calculateDueAmount() {
    final total = _calculateTotalAmount();
    final paid = double.tryParse(_codController.text) ?? 0.0;
    final due = total - paid;
    return due < 0 ? 0.0 : due;
  }

  String _getEstimatedDeliveryByPriority(String priority) {
    switch (priority) {
      case Priority.low:
        return 'Fixed 120 Days (1% Discount)';
      case Priority.high:
        return 'Fixed 50 Days (+7% Premium)';
      case Priority.urgent:
        return 'Fixed 30 Days (+10% Premium)';
      case Priority.normal:
      default:
        return 'Fixed 90 Days (Standard Timeline)';
    }
  }

  void _addAllocatedItem() {
    if (_selectedProduct == null) {
      _showSnackbar('Please select an operational inventory product!');
      return;
    }
    if (_allocationQuantity <= 0) {
      _showSnackbar('Quantity must be greater than zero!');
      return;
    }

    final notes = _allocationNotesController.text.trim();
    final existingIndex = _allocatedItems.indexWhere((x) => x.product.id == _selectedProduct!.id);

    setState(() {
      if (existingIndex >= 0) {
        _allocatedItems[existingIndex].quantity += _allocationQuantity;
        if (notes.isNotEmpty) {
          _allocatedItems[existingIndex].remarks = notes;
        }
      } else {
        _allocatedItems.add(
          CustomerOrderItemEntry(
            product: _selectedProduct!,
            quantity: _allocationQuantity,
            remarks: notes,
          ),
        );
      }
      _allocationQuantity = 1;
      _allocationNotesController.clear();
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_allocatedItems.isEmpty) {
      _showSnackbar('Target allocation package requires at least one product row.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final codAmount = double.tryParse(_codController.text) ?? 0.0;

    final request = CustomerOrderRequest(
      customerId: _customerId,
      deliveryAddress: _addressController.text.trim(),
      deliveryPhone: _phoneController.text.trim(),
      estimatedDelivery: _getEstimatedDeliveryByPriority(_selectedPriority),
      serviceType: _selectedServiceType,
      priority: _selectedPriority,
      currency: 'BDT',
      codAmount: codAmount,
      paymentMethod: _selectedPaymentMethod,
      customerAccountNumber: _accountNumberController.text.trim(),
      status: OrderStatus.pending,
      remarks: _remarksController.text.trim(),
      items: _allocatedItems.map((e) => e.toRequest()).toList(),
    );

    try {
      final repo = ref.read(customerOrderRepositoryProvider);

      MultipartFile? imageFile;
      if (_paymentProofImage != null) {
        imageFile = await MultipartFile.fromFile(_paymentProofImage!.path, filename: _paymentProofImage!.name);
      }

      final response = await repo.save(request, imageFile: imageFile);

      ref.invalidate(customerOrderSummaryProvider);
      ref.invalidate(myCustomerOrdersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${response.orderNumber} dispatched successfully!'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Dispatch Failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentProofImage = image;
      });
    }
  }

  Widget _buildImagePickerSection(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Choose File', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _paymentProofImage?.name ?? 'No file chosen',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
        if (_paymentProofImage != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? Image.network(_paymentProofImage!.path, height: 180, fit: BoxFit.contain)
                  : Image.file(File(_paymentProofImage!.path), height: 180, fit: BoxFit.contain),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateItemSubtotal();
    final deliveryCharge = _calculateDeliveryCharge();
    final totalAmount = _calculateTotalAmount();
    final codAmount = double.tryParse(_codController.text) ?? 0.0;
    final dueAmount = _calculateDueAmount();

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text('SCM ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0B2545))),
                                Text('PRO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2563EB))),
                              ],
                            ),
                            const Text('Supply Chain Management', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const DynamicNotificationButton(),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.black87, size: 20),
                      onPressed: () => Navigator.pushNamed(context, '/messages'),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF4F46E5),
                          radius: 16,
                          child: Text(
                            _loggedInCustomerName.isNotEmpty ? _loggedInCustomerName[0].toUpperCase() : 'J',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_loggedInCustomerName.isNotEmpty ? _loggedInCustomerName : 'johan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                            Text(_userRole.isNotEmpty ? _userRole : 'CUSTOMER', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Scrollable Form Area ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.shopping_cart, color: Color(0xFF2563EB), size: 22),
                              SizedBox(width: 8),
                              Text('Dispatch New Purchase Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B2545))),
                            ],
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 14, color: Colors.black87),
                            label: const Text('Back to Dashboard', style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Section 1: TARGET CUSTOMER PROFILE ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.person_outline, size: 16, color: Color(0xFF2563EB)),
                                SizedBox(width: 6),
                                Text('TARGET CUSTOMER PROFILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF), letterSpacing: 0.5)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  radius: 20,
                                  child: Text(
                                    _loggedInCustomerName.isNotEmpty ? _loggedInCustomerName[0].toUpperCase() : 'J',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$_loggedInCustomerName (${_loggedInCustomerEmail.isNotEmpty ? _loggedInCustomerEmail : "johan52@gmail.com"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                        child: const Text('Verified Customer', style: TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 13, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(_phoneController.text.isNotEmpty ? _phoneController.text : (_loggedInCustomerPhone.isNotEmpty ? _loggedInCustomerPhone : '01XXXXXXXXX'), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.email_outlined, size: 13, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(_loggedInCustomerEmail.isNotEmpty ? _loggedInCustomerEmail : 'johan52@gmail.com', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Section 2: ESTIMATED DELIVERY ROADMAP & PHONE ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCardBox(
                              icon: Icons.map_outlined,
                              title: 'ESTIMATED DELIVERY ROADMAP',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedEstimatedDelivery,
                                    isExpanded: true,
                                    decoration: _inputDecoration(),
                                    items: const [
                                      DropdownMenuItem(value: 'Auto-Fixed by Priority Rule', child: Text('Auto-Fixed by Priority Rule', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'Fixed 90 Days (Standard Timeline)', child: Text('Fixed 90 Days (Standard Timeline)', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'Express 3-5 Days', child: Text('Express 3-5 Days', style: TextStyle(fontSize: 12))),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedEstimatedDelivery = val);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF16A34A)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _getEstimatedDeliveryByPriority(_selectedPriority),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCardBox(
                              icon: Icons.phone_outlined,
                              title: 'DELIVERY PHONE CHANNEL',
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: _inputDecoration(hint: '01XXXXXXXXX'),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Phone is required' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 3: DELIVERY ADDRESS DESTINATION ──
                      _buildCardBox(
                        icon: Icons.location_on_outlined,
                        title: 'DELIVERY ADDRESS DESTINATION',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextFormField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: _inputDecoration(hint: 'Full physical shipping street layout...'),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Delivery address is required' : null,
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.location_on, size: 14, color: Colors.black87),
                              label: const Text('Select on Map', style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Section 4: SERVICE & PRIORITY MATRIX ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildCardBox(
                              icon: Icons.assignment_turned_in_outlined,
                              title: 'SERVICE STRATEGY MATRIX',
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedServiceType,
                                isExpanded: true,
                                decoration: _inputDecoration(),
                                items: const [
                                  DropdownMenuItem(value: ServiceType.standard, child: Text('STANDARD Logistics Delivery', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: ServiceType.express, child: Text('EXPRESS Bullet Velocity', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: ServiceType.overnight, child: Text('OVERNIGHT Cargo', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: ServiceType.sameDay, child: Text('SAMEDAY Hub Token', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedServiceType = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCardBox(
                              icon: Icons.flag_outlined,
                              title: 'ORDER PRIORITY MATRIX',
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedPriority,
                                isExpanded: true,
                                decoration: _inputDecoration(),
                                items: const [
                                  DropdownMenuItem(value: Priority.low, child: Text('LOW Priority (120 Days / 1% Disc.)', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: Priority.normal, child: Text('NORMAL Priority (90 Days Standard)', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: Priority.high, child: Text('HIGH Priority (50 Days / +7% Cost)', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: Priority.urgent, child: Text('URGENT Priority (30 Days / +10% Cost)', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedPriority = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 5: PAYMENT STRATEGY ROUTER ──
                      _buildCardBox(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'PAYMENT STRATEGY ROUTER',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPaymentMethod,
                              isExpanded: true,
                              decoration: _inputDecoration(),
                              items: const [
                                DropdownMenuItem(value: PaymentMethod.cash, child: Text('CASH On Delivery', style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: PaymentMethod.bank, child: Text('BANK Transfer Swift Service', style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: PaymentMethod.bkash, child: Text('BKASH Mobile Wallet', style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: PaymentMethod.nagad, child: Text('NAGAD Fast Engine', style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: PaymentMethod.rocket, child: Text('ROCKET DBBL Node', style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedPaymentMethod = val);
                              },
                            ),
                            if (_selectedPaymentMethod == PaymentMethod.bank) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.account_balance, size: 16, color: Color(0xFF2563EB)),
                                        SizedBox(width: 6),
                                        Text('SECURE BANK GATEWAY INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade100),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Row(
                                            children: [
                                              Icon(Icons.info_outline, size: 14, color: Color(0xFF2563EB)),
                                              SizedBox(width: 4),
                                              Text('Pay using this company account:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text('Bank Name: City Bank PLC (Corporate Branch)', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                                          Text('Company A/C: 120-3341-98234101', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontFamily: 'monospace')),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('Customer Settlement Bank Account Index', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _accountNumberController,
                                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                      decoration: _inputDecoration(hint: 'e.g. 10214300982341'),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildImagePickerSection('Payment Proof / Bank Check Image (Optional)'),
                                  ],
                                ),
                              ),
                            ],
                            if (['BKASH', 'NAGAD', 'ROCKET'].contains(_selectedPaymentMethod)) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFECDD3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.phonelink_ring_outlined, size: 16, color: Color(0xFFDC2626)),
                                        const SizedBox(width: 6),
                                        Text('$_selectedPaymentMethod MFS WALLET ENGINE VERIFICATION', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.shade100),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.info_outline, size: 14, color: Color(0xFFDC2626)),
                                              SizedBox(width: 4),
                                              Text('Send money to this company number:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text('$_selectedPaymentMethod Merchant/Personal: 01712-345678', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontFamily: 'monospace')),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('Authorized Gateway Wallet Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _accountNumberController,
                                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                      decoration: _inputDecoration(hint: '01XXXXXXXXX'),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildImagePickerSection('Payment Proof / Screenshot (Optional)'),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Section 6: INITIAL PAYMENT CONTEXT & REMARKS ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildCardBox(
                              icon: Icons.payments_outlined,
                              title: 'INITIAL PAYMENT CONTEXT / COD AMOUNT',
                              child: TextFormField(
                                controller: _codController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                decoration: _inputDecoration(hint: '0'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCardBox(
                              icon: Icons.edit_note_outlined,
                              title: 'SPECIAL DELIVERY REMARKS',
                              child: TextFormField(
                                controller: _remarksController,
                                decoration: _inputDecoration(hint: 'Drop parcel at reception, fragile, etc.'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 7: PRODUCT SPECIFICATION ALLOCATIONS ──
                      _buildCardBox(
                        icon: Icons.inventory_2_outlined,
                        title: 'PRODUCT SPECIFICATION ALLOCATIONS',
                        headerAction: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/products'),
                          icon: const Icon(Icons.search, size: 14),
                          label: const Text('Browse Marketplace', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('INVENTORY PRODUCT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      DropdownButtonFormField<ProductResponseModel>(
                                        initialValue: _selectedProduct,
                                        isExpanded: true,
                                        decoration: _inputDecoration(hint: 'Search product...'),
                                        items: _products.map((p) {
                                          return DropdownMenuItem(
                                            value: p,
                                            child: Text('${p.name} (৳${p.sellingPrice.toStringAsFixed(2)})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                          );
                                        }).toList(),
                                        onChanged: (val) => setState(() => _selectedProduct = val),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('QTY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                                              child: Text('$_allocationQuantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              InkWell(
                                                onTap: () => setState(() => _allocationQuantity++),
                                                child: const Icon(Icons.arrow_drop_up, size: 18),
                                              ),
                                              InkWell(
                                                onTap: () => setState(() {
                                                  if (_allocationQuantity > 1) _allocationQuantity--;
                                                }),
                                                child: const Icon(Icons.arrow_drop_down, size: 18),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: _allocationNotesController,
                                        decoration: _inputDecoration(hint: 'Notes'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: _addAllocatedItem,
                                  child: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('ATTACHED PRODUCTS LIST (${_allocatedItems.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),

                            if (_allocatedItems.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                child: const Text('No product items attached to this envelope matrix yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    // Table Header Row
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      color: Colors.grey.shade100,
                                      child: const Row(
                                        children: [
                                          Expanded(flex: 3, child: Text('PRODUCT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                                          Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                                          Expanded(flex: 3, child: Text('NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                                          SizedBox(width: 70, child: Text('ACTION', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),

                                    // Table Item Rows
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _allocatedItems.length,
                                      separatorBuilder: (context, index) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final entry = _allocatedItems[index];
                                        final imageUrl = _resolveImageUrl(entry.product.image);

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          child: Row(
                                            children: [
                                              // Product Name & SKU
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                                      child: imageUrl.isNotEmpty
                                                          ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey))
                                                          : const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(entry.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                          Text('SKU: ${entry.product.productCode}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Quantity Controls [- 1 +]
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              if (entry.quantity > 1) {
                                                                entry.quantity--;
                                                              } else {
                                                                _allocatedItems.removeAt(index);
                                                              }
                                                            });
                                                          },
                                                          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: Text('-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                                          child: Text('${entry.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                        ),
                                                        InkWell(
                                                          onTap: () => setState(() => entry.quantity++),
                                                          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Notes Box
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)),
                                                  child: Text(
                                                    entry.remarks.isNotEmpty ? entry.remarks : 'Standard allocation notes',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                                                  ),
                                                ),
                                              ),

                                              // Remove Button with fixed width to avoid overflow
                                              SizedBox(
                                                width: 70,
                                                child: Center(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: const Color(0xFFEF4444),
                                                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                                    ),
                                                    onPressed: () => setState(() => _allocatedItems.removeAt(index)),
                                                    child: const Text('Remove', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Section 8: ORDER FINANCIAL SUMMARY ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calculate_outlined, size: 16, color: Color(0xFF0284C7)),
                                SizedBox(width: 6),
                                Text('ORDER FINANCIAL SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1), letterSpacing: 0.5)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _financialRow('Item Subtotal', '৳${subtotal.toStringAsFixed(2)}', Colors.black87),
                            _financialRow('Delivery Charge', '৳${deliveryCharge.toStringAsFixed(2)}', const Color(0xFF2563EB)),
                            _financialRow('Paid Amount', '৳${codAmount.toStringAsFixed(2)}', const Color(0xFF16A34A)),
                            _financialRow('Due Amount', '৳${dueAmount.toStringAsFixed(2)}', const Color(0xFFDC2626)),
                            const SizedBox(height: 8),
                            const CustomDottedDivider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                Text('৳${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF059669))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Section 9: Action Buttons ──
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _isSubmitting ? null : _submitOrder,
                              icon: _isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.local_shipping_outlined, size: 18),
                              label: Text(_isSubmitting ? 'Dispatching...' : 'Dispatch Consignment Node', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2, size: 14, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text('SCM PRO  ·  © 2026 All Rights Reserved', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
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

  Widget _buildCardBox({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? headerAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: const Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              ?headerAction,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF2563EB))),
    );
  }

  Widget _financialRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class CustomDottedDivider extends StatelessWidget {
  const CustomDottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey),
              ),
            );
          }),
        );
      },
    );
  }
}