import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/cutomer/provider/payment_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/widget/commonWidget.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  const AddPaymentScreen({super.key, this.initialOrderNumber});
  final String? initialOrderNumber;

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  
  String _selectedMethod = PaymentMethod.cash;
  CustomerOrderResponse? _foundOrder;
  bool _isSearching = false;
  bool _isSubmitting = false;
  String? _error;
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderNumber != null) {
      _searchController.text = widget.initialOrderNumber!;
      _searchOrder();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _searchOrder() async {
    final term = _searchController.text.trim();
    if (term.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
      _foundOrder = null;
    });

    try {
      final order = await ref.read(customerOrderRepositoryProvider).trackOrderByNumber(term);
      setState(() {
        _foundOrder = order;
        _amountController.text = order.dueAmount.toString();
      });
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedFile = image;
      });
    }
  }

  Widget _buildStepLabel(int stepNum, String label) {
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerSection(int stepNum, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepLabel(stepNum, label),
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
                  _pickedFile?.name ?? 'No file chosen',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
        if (_pickedFile != null) ...[
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
                  ? Image.network(
                _pickedFile!.path,
                height: 180,
                fit: BoxFit.contain,
              )
                  : Image.file(
                File(_pickedFile!.path),
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _submitPayment() async {
    if (_foundOrder == null) return;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final request = PaymentStatementRequest(
        customerOrderId: _foundOrder!.id,
        paidAmount: amount,
        paymentMethod: _selectedMethod,
        customerAccountNumber: _accountController.text.trim(),
      );

      MultipartFile? multipartImage;
      if (_pickedFile != null) {
        multipartImage = await MultipartFile.fromFile(_pickedFile!.path, filename: _pickedFile!.name);
      }

      await ref.read(paymentRepositoryProvider).addPayment(request, imageFile: multipartImage);
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Payment Submitted'),
          content: const Text('Your payment has been logged and is pending verification.'),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            }, child: const Text('OK'))
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text('Add Payment', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBanner(),
            const SizedBox(height: 20),
            
            if (_isSearching) const Center(child: CircularProgressIndicator())
            else if (_error != null) ErrorBanner(message: _error!)
            else if (_foundOrder != null) _buildForm()
            else _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF198754), Color(0xFF157347)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Center(
                  child: Text('1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Settle Your Dues *', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Search your order to submit a payment record', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Order ID (ORD-...)', border: InputBorder.none, hintStyle: TextStyle(fontSize: 12)),
                    onSubmitted: (_) => _searchOrder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _searchOrder,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF198754), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('Find'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('৳${_foundOrder!.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Paid', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('৳${_foundOrder!.paidAmount}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ]),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Due Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('৳${_foundOrder!.dueAmount}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildStepLabel(2, 'AMOUNT TO PAY *'),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 5000', prefixText: '৳ '),
        ),
        const SizedBox(height: 16),
        _buildStepLabel(3, 'PAYMENT METHOD *'),
        DropdownButtonFormField<String>(
          initialValue: _selectedMethod,
          decoration: const InputDecoration(hintText: 'Select Payment Method'),
          items: PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() => _selectedMethod = v!),
        ),
        const SizedBox(height: 16),
        if (_selectedMethod != PaymentMethod.cash) ...[
          _buildMethodAlert(),
          const SizedBox(height: 16),
          _buildStepLabel(4, _selectedMethod == PaymentMethod.bank ? 'YOUR BANK ACCOUNT NO *' : 'YOUR WALLET NUMBER *'),
          TextFormField(
            controller: _accountController,
            decoration: InputDecoration(hintText: _selectedMethod == PaymentMethod.bank ? 'Enter Bank A/C No' : 'Enter MFS Wallet No'),
          ),
          const SizedBox(height: 16),
          _buildImagePickerSection(5, 'PAYMENT PROOF / CHECK IMAGE (OPTIONAL)'),
        ],
        const SizedBox(height: 32),
        LoadingButton(
          label: 'Submit Payment Record',
          loading: _isSubmitting,
          onPressed: _submitPayment,
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildMethodAlert() {
    final isBank = _selectedMethod == PaymentMethod.bank;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBank ? Colors.blue.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isBank ? Colors.blue.shade200 : Colors.red.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isBank ? 'Secure Bank Gateway' : 'MFS Wallet Engine', style: TextStyle(fontWeight: FontWeight.bold, color: isBank ? Colors.blue : Colors.red, fontSize: 12)),
        const SizedBox(height: 4),
        Text(isBank ? 'Pay to: City Bank PLC\nA/C: 120-3341-98234101' : 'Send to: 01712-345678', style: const TextStyle(fontSize: 11)),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(children: [
        Icon(Icons.account_balance_wallet_outlined, size: 60, color: Colors.grey),
        SizedBox(height: 12),
        Text('No order selected', style: TextStyle(color: Colors.grey, fontSize: 13)),
      ]),
    );
  }
}
