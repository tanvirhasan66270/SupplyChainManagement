import { ChangeDetectorRef, Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import { ProductRequirementService } from '../../../service/product-requirement.service';
import { ProductRequirementRequest, ProductRequirementResponse } from '../../shared/model/productRequirementModel';
import { StorageService } from '../../../auth/auth_service/storage.service';

@Component({
  selector: 'app-product-requirement',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './product-requirement.component.html',
  styleUrls: ['./product-requirement.component.css']
})
export class ProductRequirementComponent implements OnInit {

  requirements: ProductRequirementResponse[] = [];
  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  userRole: string = '';

  // Card View Modal
  isCardViewOpen = false;

  // Status Modal
  isStatusModalOpen = false;
  selectedForStatus: ProductRequirementResponse | null = null;
  newStatus: string = 'PENDING';

  // PDF Modal
  @ViewChild('pdfContainer') pdfContainer!: ElementRef;
  isPdfModalOpen = false;
  selectedForPdf: ProductRequirementResponse | null = null;

  availableStatuses: string[] = ['PENDING', 'APPROVED', 'REJECTED', 'PROCESSING'];
  urgencyLevels: string[] = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
  units: string[] = ['Pcs', 'Kg', 'Box', 'Ltr', 'Meter', 'Set', 'Pack'];

  // 🌟 ফিক্সড: প্রথমে ফাঁকা বা ডিফল্ট মান রাখা হলো যাতে ইন্সট্যান্স ইনিশিয়ালাইজেশনের সময় ক্র্যাশ না করে
  form: ProductRequirementRequest = {
    customerOrderNumber: '',
    productName: '',
    description: '',
    requestedQuantity: 1,
    unit: 'Pcs',
    targetPriceRange: '',
    urgencyLevel: 'MEDIUM',
    status: 'PENDING',
    requestedByOfficerId: null,
    requestedByOfficerName: '',
    procurementRemarks: ''
  };

  constructor(
    private service: ProductRequirementService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    try {
      const user = this.storage.getUser();
      if (user) {
        this.userRole = (this.storage.getActiveRole() || user.role || '').toUpperCase();
      }
    } catch (e) {
      console.warn('Could not retrieve user role from storage', e);
    }

    // 🌟 সার্ভিস সম্পূর্ণ রেডি হওয়ার পর ফর্ম ভ্যালু সেট করা হলো
    this.form = this.emptyForm();
    this.loadAll();
  }

  emptyForm(): ProductRequirementRequest {
    let userId: number | null = null;
    let userName: string = '';

    try {
      const user = this.storage.getUser();
      if (user) {
        userId = user.userId ?? null;
        userName = user.name ?? '';
      }
    } catch (e) {
      console.warn('Storage service not ready yet', e);
    }

    return {
      customerOrderNumber: '',
      productName: '',
      description: '',
      requestedQuantity: 1,
      unit: 'Pcs',
      targetPriceRange: '',
      urgencyLevel: 'MEDIUM',
      status: 'PENDING',
      requestedByOfficerId: userId,
      requestedByOfficerName: userName,
      procurementRemarks: ''
    };
  }

  loadAll(): void {
    this.service.findAll().subscribe({
      next: (data) => { 
        this.requirements = data || []; 
        this.cdr.markForCheck(); 
      },
      error: () => { 
        this.requirements = []; 
        this.cdr.markForCheck(); 
      }
    });
  }

  // ─── Role Checks ──────────────────────────────────────────────────────────

  isAdmin(): boolean { return this.userRole === 'ADMIN'; }

  isLogisticsOfficer(): boolean { return this.userRole === 'LOGISTICS_OFFICER'; }

  isProcurement(): boolean { return this.userRole === 'PROCUREMENT'; }

  isManager(): boolean { return this.userRole === 'MANAGER'; }

  canCreate(): boolean { return this.isAdmin() || this.isLogisticsOfficer(); }

  canEdit(r: ProductRequirementResponse): boolean {
    if (this.isAdmin()) return true;
    if (this.isLogisticsOfficer()) return r.status !== 'APPROVED';
    return false;
  }

  canUpdateStatus(): boolean { return this.isAdmin() || this.isProcurement(); }

  canDelete(): boolean { return this.isAdmin(); }

  // ─── Drawer ───────────────────────────────────────────────────────────────

  openDrawer(): void {
    this.form = this.emptyForm();
    this.isEdit = false;
    this.isDrawerOpen = true;
    this.errorMessage = null;
    this.cdr.markForCheck();
  }

  closeDrawer(): void {
    this.isDrawerOpen = false;
    this.errorMessage = null;
    this.cdr.markForCheck();
  }

  save(): void {
    this.errorMessage = null;
    if (!this.form.productName?.trim()) { this.errorMessage = 'Product name is required.'; return; }
    if (this.form.requestedQuantity <= 0) { this.errorMessage = 'Quantity must be > 0.'; return; }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.form).subscribe({
        next: () => { alert('Product Requirement updated successfully!'); this.closeDrawer(); this.loadAll(); },
        error: (err) => { this.errorMessage = err.error?.message || 'Update failed.'; this.cdr.markForCheck(); }
      });
    } else {
      this.service.save(this.form).subscribe({
        next: () => { alert('Product Requirement created successfully!'); this.closeDrawer(); this.loadAll(); },
        error: (err) => { this.errorMessage = err.error?.message || 'Save failed.'; this.cdr.markForCheck(); }
      });
    }
  }

  edit(r: ProductRequirementResponse): void {
    this.currentEditId = r.id;
    this.isEdit = true;
    this.form = {
      customerOrderNumber: r.customerOrderNumber || '',
      productName: r.productName,
      description: r.description || '',
      requestedQuantity: r.requestedQuantity,
      unit: r.unit || 'Pcs',
      targetPriceRange: r.targetPriceRange || '',
      urgencyLevel: r.urgencyLevel || 'MEDIUM',
      status: r.status,
      requestedByOfficerId: r.requestedByOfficerId || null,
      requestedByOfficerName: r.requestedByOfficerName || '',
      procurementRemarks: r.procurementRemarks || ''
    };
    this.isDrawerOpen = true;
    this.errorMessage = null;
    this.cdr.markForCheck();
  }

  delete(id: number): void {
    if (confirm('Are you sure you want to delete this product requirement?')) {
      this.service.delete(id).subscribe({
        next: () => { alert('Deleted successfully.'); this.loadAll(); },
        error: (err) => { alert(err.error?.message || 'Delete failed.'); }
      });
    }
  }

  // ─── Status Modal ─────────────────────────────────────────────────────────

  openStatusModal(r: ProductRequirementResponse): void {
    this.selectedForStatus = r;
    this.newStatus = r.status;
    this.isStatusModalOpen = true;
    this.cdr.markForCheck();
  }

  closeStatusModal(): void {
    this.isStatusModalOpen = false;
    this.selectedForStatus = null;
    this.cdr.markForCheck();
  }

  updateStatus(): void {
    if (!this.selectedForStatus) return;
    this.service.updateStatus(this.selectedForStatus.id, this.newStatus).subscribe({
      next: () => { alert('Status updated successfully!'); this.closeStatusModal(); this.loadAll(); },
      error: (err) => { alert(err.error?.message || 'Status update failed.'); }
    });
  }

  // ─── PDF Modal ────────────────────────────────────────────────────────────

  openPdfModal(r: ProductRequirementResponse): void {
    this.selectedForPdf = r;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal(): void {
    this.isPdfModalOpen = false;
    this.selectedForPdf = null;
    this.cdr.markForCheck();
  }

  downloadPdf(): void {
    const element = this.pdfContainer.nativeElement;
    html2canvas(element, { scale: 2, useCORS: true, windowHeight: element.scrollHeight }).then((canvas: HTMLCanvasElement) => {
      const imgData = canvas.toDataURL('image/png');
      const pdf = new jsPDF('p', 'mm', 'a4');
      const imgWidth = 210;
      const pageHeight = 295;
      const imgHeight = (canvas.height * imgWidth) / canvas.width;
      let heightLeft = imgHeight;
      let position = 0;

      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;
      while (heightLeft >= 0) {
        position = heightLeft - imgHeight;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
      }
      pdf.save(`Product-Requirement-${this.selectedForPdf?.requestReferenceNo || 'DOC'}.pdf`);
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  getStatusClass(status: string): string {
    switch (status) {
      case 'APPROVED':   return 'bg-success-subtle text-success border border-success';
      case 'REJECTED':   return 'bg-danger-subtle text-danger border border-danger';
      case 'PROCESSING': return 'bg-info-subtle text-info border border-info';
      default:           return 'bg-warning-subtle text-warning border border-warning';
    }
  }

  getUrgencyClass(level: string): string {
    switch (level?.toUpperCase()) {
      case 'URGENT': return 'text-danger fw-bolder';
      case 'HIGH':   return 'text-warning fw-bold';
      case 'LOW':    return 'text-secondary';
      default:       return 'text-success';
    }
  }
}