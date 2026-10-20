import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { KEYS, StorageService } from '../../../auth/auth_service/storage.service';
import { QcInspectorService } from '../../../service/qc-inspactor.service';
import { LoginResponse } from '../../../auth/Model/authModel';
import { QcInspectionService } from '../../../service/qc-inspection.service';
import { NotificationService } from '../../../system/service/notification.service';
import { GoodRecivedNoteService } from '../../../service/good-recived-note.service';
import { AddProductService } from '../../../service/add-product.service';
import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';
import { NotificationModel } from '../../../system/NotificationModel';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { QCInspectionRequestModel } from '../../shared/model/qc-inspection';

@Component({
  selector: 'app-qc-inspector-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, DashboardSettingsComponent],
  templateUrl: './qc-inspector-dashboard.component.html',
  styleUrls: ['./qc-inspector-dashboard.component.css'],
})
export class QCInspectorDashboardComponent implements OnInit {
  userName = '';
  userId!: number;
  qcInspector: any = null;
  user: LoginResponse | null = null;
  showSettings = false;
  loading = true;

  // Record Inspection Modal States
  isRecordModalOpen = false;
  grns: any[] = [];
  products: any[] = [];
  inspectors: any[] = [];
  purchaseOrders: any[] = [];
  purchaseRequisitions: any[] = [];
  selectedFile: File | null = null;
  modalErrorMessage: string | null = null;
  modalSuccessMessage: string | null = null;

  inspection: QCInspectionRequestModel = {
    grnId: 0,
    productId: 0,
    inspectionType: 'VISUAL',
    inspectedBy: 0,
    sampleSize: 5,
    defectsFound: 0,
    defectDescription: '',
    result: 'GOOD',
    certificateRef: '',
    labTestReport: '',
    inspectedAt: new Date().toISOString().split('T')[0],
    checklists: [],
  };

  kpis = [
    {
      label: 'Pending Inspection',
      value: '0 Batches',
      trend: 0,
      trendDir: 'up',
      icon: 'bi-clipboard-pulse',
      color: 'purple',
    },
    {
      label: 'Passed Today',
      value: '0 Items',
      trend: 0,
      trendDir: 'up',
      icon: 'bi-check-circle',
      color: 'success',
    },
    {
      label: 'Defects Rate',
      value: '0%',
      trend: 0,
      trendDir: 'down',
      icon: 'bi-x-circle',
      color: 'danger',
    },
    {
      label: "Today's Audit",
      value: '0 Logs',
      trend: 0,
      trendDir: 'up',
      icon: 'bi-journal-check',
      color: 'info',
    },
  ];

  queue: any[] = [];
  defects: any[] = [];
  passRate = 0;
  failRate = 0;
  totalInspections = 0;
  passedCount = 0;
  failedCount = 0;

  notifications: NotificationModel[] = [];

  constructor(
    private storage: StorageService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private qcInspectorService: QcInspectorService,
    private inspectionService: QcInspectionService,
    private notificationService: NotificationService,
    private grnService: GoodRecivedNoteService,
    private productService: AddProductService,
    private purchaseOrderService: PurchaseOrderService,
    private purchaseRequisitionService: PurchaseRequisitionService,
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) {
      return;
    }
    this.userName = user.name || 'QC Inspector';
    this.userId = user.userId;
    this.inspection.inspectedBy = user.userId;
    this.loadQcInspector();
    this.loadDashboardData();
    this.loadNotifications();
    this.loadPendingGRNs();
    this.loadPurchaseOrders();
    this.loadPurchaseRequisitions();
  }

  // Modal Handler Methods
  openRecordModal() {
    this.resetInspectionForm();
    this.isRecordModalOpen = true;
    this.loadModalOptions();
    this.cdr.markForCheck();
  }

  closeRecordModal() {
    this.isRecordModalOpen = false;
    this.modalErrorMessage = null;
    this.modalSuccessMessage = null;
    this.cdr.markForCheck();
  }

  loadModalOptions() {
    this.grnService.findAll().subscribe({ next: (data) => { this.grns = data || []; this.cdr.markForCheck(); } });
    this.productService.findAll().subscribe({ next: (data) => { this.products = data || []; this.cdr.markForCheck(); } });
    this.qcInspectorService.findAll().subscribe({
      next: (data) => {
        this.inspectors = (data || []).map((i: any) => ({
          id: i.userId || i.id,
          name: i.name || i.inspectorName,
          designation: i.designation || 'QC Inspector'
        }));
        this.cdr.markForCheck();
      }
    });
  }

  onFileChange(event: any) {
    if (event.target.files && event.target.files.length > 0) {
      this.selectedFile = event.target.files[0];
    }
  }

  resetInspectionForm() {
    this.inspection = {
      grnId: 0,
      productId: 0,
      inspectionType: 'VISUAL',
      inspectedBy: this.userId || 0,
      sampleSize: 5,
      defectsFound: 0,
      defectDescription: '',
      result: 'GOOD',
      certificateRef: '',
      labTestReport: '',
      inspectedAt: new Date().toISOString().split('T')[0],
      checklists: [],
    };
    this.selectedFile = null;
    this.modalErrorMessage = null;
    this.modalSuccessMessage = null;
  }

  loadPurchaseOrders() {
    this.purchaseOrderService.findAll().subscribe({
      next: (data) => {
        this.purchaseOrders = data || [];
        this.cdr.markForCheck();
      },
      error: () => {
        this.purchaseOrders = [];
      }
    });
  }

  loadPurchaseRequisitions() {
    this.purchaseRequisitionService.findAll().subscribe({
      next: (data) => {
        this.purchaseRequisitions = data || [];
        this.cdr.markForCheck();
      },
      error: () => {
        this.purchaseRequisitions = [];
      }
    });
  }

  getFilteredProducts(): any[] {
    if (!this.inspection.grnId || +this.inspection.grnId === 0) {
      return this.products;
    }
    const selectedGrn = this.grns.find(g => Number(g.id) === Number(this.inspection.grnId));
    if (!selectedGrn) {
      return this.products;
    }

    const selectedPo = this.purchaseOrders.find(
      (po) =>
        Number(po.id) === Number(selectedGrn.poId) ||
        (selectedGrn.poNumber && po.poNumber === selectedGrn.poNumber)
    );

    if (!selectedPo) {
      return this.fallbackGrnFilter(selectedGrn);
    }

    const selectedPr = this.purchaseRequisitions.find(
      (pr) => Number(pr.id) === Number(selectedPo.purchaseRequisitionId)
    );

    if (!selectedPr || !selectedPr.productIds || selectedPr.productIds.length === 0) {
      return this.fallbackGrnFilter(selectedGrn);
    }

    const prProductIds = new Set<number>(selectedPr.productIds.map((id: any) => Number(id)));
    return this.products.filter(p => prProductIds.has(Number(p.id)));
  }

  fallbackGrnFilter(selectedGrn: any): any[] {
    const grnProductIds = new Set<number>();
    if (selectedGrn.productId) {
      grnProductIds.add(Number(selectedGrn.productId));
    }
    if (selectedGrn.lineItems && selectedGrn.lineItems.length > 0) {
      selectedGrn.lineItems.forEach((item: any) => {
        if (item.productId) {
          grnProductIds.add(Number(item.productId));
        }
      });
    }
    if (grnProductIds.size === 0) {
      return this.products;
    }
    return this.products.filter(p => grnProductIds.has(Number(p.id)));
  }

  onGrnChange() {
    const filtered = this.getFilteredProducts();
    const stillValid = filtered.some(p => Number(p.id) === Number(this.inspection.productId));
    if (!stillValid) {
      this.inspection.productId = 0;
    }
    this.cdr.markForCheck();
  }

  addChecklistRow() {
    if (!this.inspection.checklists) {
      this.inspection.checklists = [];
    }
    this.inspection.checklists.push({
      checkpointName: '',
      isPassed: true,
      remarks: ''
    });
    this.cdr.markForCheck();
  }

  removeChecklistRow(idx: number) {
    if (this.inspection.checklists) {
      this.inspection.checklists.splice(idx, 1);
    }
    this.cdr.markForCheck();
  }

  submitInspection() {
    this.modalErrorMessage = null;
    this.modalSuccessMessage = null;

    if (!this.inspection.grnId || +this.inspection.grnId === 0 || !this.inspection.productId || +this.inspection.productId === 0) {
      this.modalErrorMessage = 'Validation Error: Please select both a Linked GRN and Target Product.';
      this.cdr.markForCheck();
      return;
    }

    if (!this.inspection.inspectedAt) {
      this.modalErrorMessage = 'Validation Error: Please specify the Inspection Execution Date.';
      this.cdr.markForCheck();
      return;
    }

    const payload: QCInspectionRequestModel = {
      ...this.inspection,
      grnId: +this.inspection.grnId,
      productId: +this.inspection.productId,
      inspectedBy: this.userId || +this.inspection.inspectedBy,
      sampleSize: +this.inspection.sampleSize,
      defectsFound: +this.inspection.defectsFound,
      result: (this.inspection.result || 'GOOD').toUpperCase(),
      checklists: (this.inspection.checklists || []).map((c) => ({
        checkpointName: c.checkpointName || 'General Checkpoint',
        isPassed: String(c.isPassed) === 'true',
        remarks: c.remarks || '',
      }))
    };

    this.inspectionService.save(payload, this.selectedFile).subscribe({
      next: () => {
        this.modalSuccessMessage = 'QC Audit Log Authorized & Successfully Recorded!';
        this.loadDashboardData();
        this.cdr.markForCheck();
        setTimeout(() => {
          this.closeRecordModal();
        }, 1300);
      },
      error: (err: any) => {
        this.modalErrorMessage = err.error?.message || 'Failed to record QC inspection.';
        this.cdr.markForCheck();
      }
    });
  }

  loadDashboardData() {
    this.inspectionService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.totalInspections = all.length;
        const pending = all.filter((i: any) => i.result === 'PENDING' || i.status === 'PENDING');
        const passed = all.filter((i: any) => i.result === 'GOOD' || i.result === 'VERY_GOOD');
        const failed = all.filter((i: any) => i.result === 'BAD');
        const totalDefects = all.reduce((sum: number, i: any) => sum + (i.defectsFound || 0), 0);
        const totalSamples = all.reduce((sum: number, i: any) => sum + (i.sampleSize || 1), 0);

        this.passedCount = passed.length;
        this.failedCount = failed.length;

        if (this.totalInspections > 0) {
          this.passRate = parseFloat(((passed.length / this.totalInspections) * 100).toFixed(1));
          this.failRate = parseFloat(((failed.length / this.totalInspections) * 100).toFixed(1));
        }

        this.kpis[0] = {
          ...this.kpis[0],
          value: `${pending.length} Batches`,
          trend: pending.length,
          trendDir: pending.length > 0 ? 'up' : 'down',
        };
        this.kpis[1] = {
          ...this.kpis[1],
          value: `${passed.length} Items`,
          trend: passed.length,
          trendDir: 'up',
        };
        this.kpis[2] = {
          ...this.kpis[2],
          value: totalSamples > 0 ? `${((totalDefects / totalSamples) * 100).toFixed(1)}%` : '0%',
          trend: totalDefects,
          trendDir: totalDefects > 0 ? 'down' : 'up',
        };
        this.kpis[3] = {
          ...this.kpis[3],
          value: `${all.length} Logs`,
          trend: all.length,
          trendDir: 'up',
        };

        this.queue = all.slice(0, 5).map((i: any) => ({
          batchId: `B-${i.id}`,
          product: i.productName || `Product #${i.productId}`,
          sampleSize: i.sampleSize || 0,
          defectsFound: i.defectsFound || 0,
          status: i.result || 'PENDING',
        }));

        this.defects = failed.slice(0, 3).map((i: any, idx: number) => ({
          code: `DF-${String(idx + 1).padStart(2, '0')}`,
          description: i.defectDescription || 'No description',
          count: i.defectsFound || 0,
          severity: (i.defectsFound || 0) > 3 ? 'CRITICAL' : 'HIGH',
        }));

        this.loading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.loading = false;
        this.cdr.markForCheck();
      },
    });
  }

  loadPendingGRNs(): void {
    this.grnService.findAll().subscribe({
      next: (data) => {
        const grns = data || [];
        const pendingGRNs = grns.filter(
          (g: any) => g.status === 'PENDING' || g.qcStatus === 'PENDING' || g.qcStatus === null,
        );
        this.kpis[0] = {
          ...this.kpis[0],
          value: `${pendingGRNs.length} Batches`,
          trend: pendingGRNs.length,
          trendDir: pendingGRNs.length > 0 ? 'up' : 'down',
        };
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  loadNotifications(): void {
    this.notificationService.findAll().subscribe({
      next: (data) => {
        this.notifications = (data || []).slice(0, 5);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }


  pass(batchId: string): void {
    const batch = this.queue.find((b) => b.batchId === batchId);
    if (batch) {
      batch.status = 'GOOD';
      batch.defectsFound = 0;
      this.passedCount++;
      this.recomputeRates();
      this.cdr.markForCheck();
    }
  }

  fail(batchId: string): void {
    const batch = this.queue.find((b) => b.batchId === batchId);
    if (batch) {
      batch.status = 'BAD';
      batch.defectsFound = 4;
      this.failedCount++;
      this.recomputeRates();
      this.cdr.markForCheck();
    }
  }

  private recomputeRates(): void {
    if (this.totalInspections > 0) {
      this.passRate = parseFloat(((this.passedCount / this.totalInspections) * 100).toFixed(1));
      this.failRate = parseFloat(((this.failedCount / this.totalInspections) * 100).toFixed(1));
    }
  }

  toggleSettings(): void {
    this.showSettings = !this.showSettings;
  }

  closeSettings(): void {
    this.showSettings = false;
  }

  getNotificationIcon(type: string): string {
    const icons: Record<string, string> = {
      SHIPMENT: 'bi-truck',
      TRIP_ALERT: 'bi-exclamation-triangle',
      REPORT_APPROVED: 'bi-check-circle',
      QC: 'bi-shield-check',
      GRN: 'bi-clipboard-check',
    };
    return icons[type] || 'bi-bell';
  }

  getNotificationColor(type: string): string {
    const colors: Record<string, string> = {
      SHIPMENT: 'text-primary',
      TRIP_ALERT: 'text-warning',
      REPORT_APPROVED: 'text-success',
      QC: 'text-purple',
      GRN: 'text-info',
    };
    return colors[type] || 'text-secondary';
  }

  getActionIcon(action: string): string {
    const icons: Record<string, string> = {
      CREATE: 'bi-plus-circle',
      UPDATE: 'bi-pencil',
      DELETE: 'bi-trash',
      LOGIN: 'bi-box-arrow-in-right',
    };
    return icons[action] || 'bi-circle';
  }

  getActionColor(action: string): string {
    const colors: Record<string, string> = {
      CREATE: 'text-success',
      UPDATE: 'text-primary',
      DELETE: 'text-danger',
      LOGIN: 'text-info',
    };
    return colors[action] || 'text-secondary';
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  loadQcInspector(): void {
    if (this.storage.getRole() === 'ADMIN') return;
    this.qcInspectorService.getQcInspectorByUserId(this.userId).subscribe({
      next: (res) => {
        this.qcInspector = res;
        this.storage.saveData(KEYS.QC_INSPECTOR, res);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
  }
}
