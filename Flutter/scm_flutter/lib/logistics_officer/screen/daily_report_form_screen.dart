import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/entity/daily_report_model.dart';
import 'package:scm_flutter/logistics_officer/provider/daily_report_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/warehouse_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class DailyReportFormScreen extends ConsumerStatefulWidget {
  const DailyReportFormScreen({super.key, this.reportToEdit});

  final DailyReportResponseModel? reportToEdit;

  @override
  ConsumerState<DailyReportFormScreen> createState() => _DailyReportFormScreenState();
}

class _DailyReportFormScreenState extends ConsumerState<DailyReportFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String warehouseId = '';
  String reportDate = DateTime.now().toIso8601String().split('T')[0];
  int totalTasksDone = 0;
  int issuesLogged = 0;
  String summary = '';
  XFile? selectedFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.reportToEdit != null) {
      final r = widget.reportToEdit!;
      warehouseId = r.warehouseId;
      reportDate = r.reportDate;
      totalTasksDone = r.totalTasksDone;
      issuesLogged = r.issuesLogged;
      summary = r.summary ?? '';
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reportToEdit != null;
    final warehousesAsync = ref.watch(warehouseListProvider);
    final warehouses = warehousesAsync.value ?? [];

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Mutate Operation Log' : 'Deploy EOD Dispatch',
                            style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Deploy end-of-day dispatch manifest',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
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

            // ২. Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Target Warehouse Node
                      _buildNumberedLabel(1, 'TARGET WAREHOUSE NODE *'),
                      DropdownButtonFormField<String>(
                        initialValue: warehouseId.isEmpty ? null : warehouseId,
                        decoration: _inputDecoration().copyWith(
                          hintText: '-- Select Active Location --',
                          prefixIcon: const Icon(Icons.store_outlined, size: 18, color: AppTheme.primary),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'WH-DHAKA-01', child: Text('WH-DHAKA-01 (Central Hub)', style: TextStyle(fontSize: 12))),
                          const DropdownMenuItem(value: 'WH-CHITTAGONG-02', child: Text('WH-CHITTAGONG-02 (Port Node)', style: TextStyle(fontSize: 12))),
                          ...warehouses.map((w) => DropdownMenuItem<String>(
                            value:  w.id.toString(),
                            child: Text(w.name, style: const TextStyle(fontSize: 12)),
                          )),
                        ],
                        onChanged: isEdit ? null : (val) => setState(() => warehouseId = val ?? ''),
                      ),
                      const SizedBox(height: 16),

                      // Step 2 & 3: Row - Operation Date & Total Tasks Processed
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNumberedLabel(2, 'OPERATION DATE *'),
                                TextFormField(
                                  initialValue: reportDate,
                                  readOnly: isEdit,
                                  decoration: _inputDecoration().copyWith(
                                    hintText: 'YYYY-MM-DD',
                                    prefixIcon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.grey),
                                  ),
                                  onChanged: (val) => reportDate = val,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNumberedLabel(3, 'TOTAL TASKS PROCESSED *'),
                                TextFormField(
                                  initialValue: totalTasksDone.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration().copyWith(
                                    hintText: '0',
                                    prefixIcon: const Icon(Icons.done_all, size: 18, color: AppTheme.grey),
                                  ),
                                  onChanged: (val) => totalTasksDone = int.tryParse(val) ?? 0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Step 4: Damages / Issues Logged Counter
                      _buildNumberedLabel(4, 'DAMAGES / ISSUES LOGGED COUNTER *'),
                      TextFormField(
                        initialValue: issuesLogged.toString(),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(
                          hintText: '0',
                          prefixIcon: const Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.grey),
                        ),
                        onChanged: (val) => issuesLogged = int.tryParse(val) ?? 0,
                      ),
                      const SizedBox(height: 16),

                      // Step 5: Attachment Proof Image
                      _buildNumberedLabel(5, 'ATTACHMENT PROOF IMAGE'),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, size: 18, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              const Text('Choose File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedFile?.name ?? 'No file chosen',
                                  style: TextStyle(fontSize: 12, color: selectedFile != null ? AppTheme.dark : AppTheme.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedFile != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(selectedFile!.path),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Step 6: Operational Summary Notes
                      _buildNumberedLabel(6, 'OPERATIONAL SUMMARY NOTES *'),
                      TextFormField(
                        initialValue: summary,
                        maxLines: 4,
                        maxLength: 300,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'Log details profile metrics...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.note_alt_outlined, size: 18, color: AppTheme.grey),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          counterText: '',
                        ),
                        onChanged: (val) => summary = val,
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text('0/300', style: TextStyle(fontSize: 9, color: AppTheme.grey)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer Action Buttons (Dispatch Manifest & Cancel)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (warehouseId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Validation Error: Target Warehouse Node is mandatory.')),
                                  );
                                  return;
                                }

                                final request = DailyReportRequestModel(
                                  warehouseId: warehouseId,
                                  reportDate: reportDate,
                                  totalTasksDone: totalTasksDone,
                                  issuesLogged: issuesLogged,
                                  summary: summary.trim(),
                                );

                                bool success = false;
                                if (isEdit && widget.reportToEdit != null) {
                                  success = await ref
                                      .read(dailyReportControllerProvider.notifier)
                                      .updateReport(widget.reportToEdit!.id, request, selectedFile);
                                } else {
                                  success = await ref
                                      .read(dailyReportControllerProvider.notifier)
                                      .createReport(request, selectedFile);
                                }

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('EOD Report dispatched successfully!'), backgroundColor: AppTheme.success),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.cloud_upload, size: 18),
                              label: Text(isEdit ? 'UPDATE REPORT' : 'DISPATCH MANIFEST'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: AppTheme.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.borderGrey),
                                foregroundColor: AppTheme.dark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
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

  Widget _buildNumberedLabel(int stepNum, String label) {
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
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
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