import { ChangeDetectorRef, Component, OnInit, ViewChild, ElementRef, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { QuotationRequestModel, QuotationResponseModel } from '../../shared/model/quatationModel';
import { QuotationService } from '../../../service/quatation.service';
import { AddProductService } from '../../../service/add-product.service';
import { SupplierService } from '../../../service/supplier.service';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';
import { environment } from '../../../../environment/environment';

// jsPDF এবং html2canvas ইমপোর্ট
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

@Component({
  selector: 'app-quatation',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './quatation.component.html',
  styleUrl: './quatation.component.css',
})
export class QuatationComponent implements OnInit {

  readonly imageBaseUrl = environment.imgUrl + "quotation/";

  quotations: QuotationResponseModel[] = [];
  filteredQuotations: QuotationResponseModel[] = []; 
  
  searchQtn: string = '';
  searchSupplierName: string = '';
  searchState: string = '';

  products: any[] = [];
  suppliers: any[] = [];
  requisitions: any[] = [];

  errorMessage: string | null = null;
  isDrawerOpen = false;
  @Input() isEmbedded = false;
  @Output() formClosed = new EventEmitter<void>();
  isEdit = false;
  currentEditId: number | null = null;
  selectedFile: File | null = null;
  
  activeRole: string = 'SUPPLIER';
  currentSupplierId: number | null = null;
  currentSupplierName: string = ''; 

  isPdfModalOpen = false;
  selectedQuotationForPdf: QuotationResponseModel | null = null;
  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;

  quotation: QuotationRequestModel = {
    supplierId: 0,
    purchaseRequisitionId: 0,
    leadTimeDays: 1,
    receivedAt: '',
    status: 'PENDING',
    productDescription: '',
    unitPrice: 0,
    quantity: 1,
    deliveryTime: '',
    warranty: '',
    notes: '',
    attachmentUrl: ''
  };

  constructor(
    private service: QuotationService,
    private productService: AddProductService,
    private supplierService: SupplierService,
    private requisitionService: PurchaseRequisitionService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.activeRole = this.storage.getActiveRole()?.toUpperCase() || 'SUPPLIER';
    const user = this.storage.getUser();
    
    const cachedSupplier = this.storage.getData(KEYS.SUPPLIER) as any;
    if (cachedSupplier) {
      this.currentSupplierId = cachedSupplier.id;
      if (this.activeRole === 'SUPPLIER') {
        this.quotation.supplierId = this.currentSupplierId!;
      }
      console.log(this.currentSupplierId);
      this.currentSupplierName = cachedSupplier.name || user?.name || 'Your Supplier Account';
      console.log(this.currentSupplierName)
    } else {
      this.currentSupplierName = user?.name || 'Your Supplier Account';
    }

    if (this.activeRole === 'SUPPLIER' && !this.currentSupplierId && user?.userId) {
      this.supplierService.getSupplierByUserId(user.userId).subscribe({ next: (supplier) => {
          if (supplier && supplier.id) {
            this.currentSupplierId = supplier.id;
            this.currentSupplierName = supplier.name || this.currentSupplierName;
            if (this.activeRole === 'SUPPLIER') {
              this.quotation.supplierId = this.currentSupplierId!;
            }
            this.storage.saveData(KEYS.SUPPLIER, { id: this.currentSupplierId, name: this.currentSupplierName });
          }
          this.loadQuotations();
          this.loadProducts();
          this.loadRequisitions();
        },
        error: () => {
          this.loadQuotations();
          this.loadProducts();
          this.loadRequisitions();
        }
      });
    } else {
      this.loadQuotations();
      this.loadProducts();
      this.loadSuppliers();
      this.loadRequisitions();
    }
  }

  getSupplierNameById(supplierId: number): string {
    if (!supplierId || !this.suppliers || this.suppliers.length === 0) {
      return 'Loading...';
    }
    const supplier = this.suppliers.find(s => s.id === supplierId);
    return supplier ? supplier.name : 'Unknown Supplier';
  }

  getLinkedRequisitionQty(): number {
    if (!this.quotation.purchaseRequisitionId || !this.requisitions) {
      return 0;
    }
    const pr = this.requisitions.find(r => r.id === Number(this.quotation.purchaseRequisitionId));
    if (!pr) return 0;
    
    const productCount = (pr.productIds && Array.isArray(pr.productIds) && pr.productIds.length > 0) ? pr.productIds.length : 1;
    return pr.quantityRequired * productCount;
  }

  isQuantityValid(): boolean {
    if (!this.quotation.purchaseRequisitionId) {
      return true;
    }
    const prQty = this.getLinkedRequisitionQty();
    if (prQty === 0) {
      return true;
    }
    if (this.quotation.quantity === null || this.quotation.quantity === undefined) {
      return true;
    }
    return this.quotation.quantity <= prQty;
  }

  getImageUrl(fileName: string | null | undefined): string {
    if (!fileName) {
      return 'assets/no-image.png';
    }
    return this.imageBaseUrl + fileName;
  }

  loadQuotations(): void {
    this.service.findAll().subscribe({ next: (data) => {
        const allRfqs = data || [];

        console.log(allRfqs);
        
        if (this.activeRole === 'SUPPLIER') {
          if (this.currentSupplierId) {
            this.quotations = allRfqs.filter((q: any) => {
              const sId = q.supplierId || (q.supplier ? q.supplier.id : null);
              return Number(sId) === Number(this.currentSupplierId) });
          } else {
            this.quotations = [];
          }
        } else {
          this.quotations = allRfqs;
        }

        this.filteredQuotations = [...this.quotations];
        this.applyFilters(); 
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleError(err)
    });
  }

  applyFilters(): void {
    const qtnTerm = this.searchQtn.toLowerCase().trim();
    const supTerm = this.searchSupplierName.toLowerCase().trim();
    const stateTerm = this.searchState.toLowerCase().trim();

    this.filteredQuotations = this.quotations.filter(q => {
      const qtnNo = (q.quotationNumber || `QTN-${q.id}`).toLowerCase();
      const supName = (q.supplierName || this.getSupplierNameById(q.supplierId)).toLowerCase();
      const status = (q.status || 'PENDING').toLowerCase();

      return qtnNo.includes(qtnTerm) && 
             supName.includes(supTerm) && 
             status.includes(stateTerm);
    });
    this.cdr.markForCheck();
  }

  loadProducts(): void {
    this.productService.findAll().subscribe({ next: (data) => { this.products = data || []; this.cdr.markForCheck(); } });
  }

  loadSuppliers(): void {
    if (this.activeRole === 'SUPPLIER') return;
    this.supplierService.findAll().subscribe({ next: (data) => { this.suppliers = data || []; this.cdr.markForCheck(); } });
  }

  loadRequisitions(): void {
    this.requisitionService.findAll().subscribe({ next: (data) => { this.requisitions = data || []; this.cdr.markForCheck(); } });
  }

  onRequisitionSelect(reqId: any): void {
    if (reqId && Number(reqId) > 0) {
      const selectedReq = this.requisitions.find(r => r.id === Number(reqId));
      if (selectedReq && selectedReq.createdAt) {
        this.quotation.receivedAt = selectedReq.createdAt.split('T')[0];
      } else {
        this.quotation.receivedAt = new Date().toISOString().split('T')[0];
      }
      this.cdr.markForCheck();
    }
  }

  onFileChange(event: any): void {
    if (event.target.files && event.target.files.length > 0) {
      this.selectedFile = event.target.files[0];
    }
  }

  openDrawer(): void {
    if (this.activeRole !== 'ADMIN' && (this.activeRole === 'PROCUREMENT' || this.activeRole === 'MANAGER')) {
      console.warn("Access Denied: Action restricted for this role.");
      return; 
    }

    this.reset();
    this.isEdit = false;
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  closeDrawer(): void { 
    this.isDrawerOpen = false; 
    this.formClosed.emit();
    this.reset(); 
    this.cdr.markForCheck(); 
  }

  isProcurement(): boolean {
    const role = this.storage.getActiveRole()?.toUpperCase();
    return role === 'PROCUREMENT' || role === 'MANAGER';
  }

  canUpdateStatus(): boolean {
    const role = this.storage.getActiveRole()?.toUpperCase();
    return role === 'ADMIN' || role === 'PROCUREMENT';
  }

  updateStatus(q: QuotationResponseModel): void {
    if (!this.canUpdateStatus()) {
      alert("Access Denied: Only Admin and Procurement can update status.");
      this.loadQuotations();
      return;
    }

    this.service.updateStatus(q.id, q.status).subscribe({
      next: () => {
        alert("Status updated successfully.");
        this.loadQuotations();
      },
      error: (err: any) => {
        console.error("Update failed", err);
        alert("Failed to update status. Please try again.");
        this.loadQuotations();
      }
    });
  }

  get userRole(): string {
    return this.activeRole;
  }

  save(): void {
    this.errorMessage = null;

    if (this.quotation.supplierId === 0 && this.activeRole !== 'ADMIN') {
      this.errorMessage = "Validation Fault: Target Supplier mapping is mandatory.";
      return;
    }
    
    if (this.quotation.purchaseRequisitionId === 0) {
      this.errorMessage = "Validation Fault: Purchase Requisition node mapping is mandatory.";
      return;
    }

    if (!this.isQuantityValid()) {
      this.errorMessage = "Validation Fault: Quantity limit exceeded.";
      return;
    }

    if (this.activeRole === 'SUPPLIER' && this.currentSupplierId != null) {
      this.quotation.supplierId = this.currentSupplierId;
    }

    if (this.isEdit && this.currentEditId) {
      const original = this.quotations.find(q => q.id === this.currentEditId);
      if (original && (original.status === 'APPROVED' || original.status === 'UNDER_REVIEW')) {
        this.errorMessage = "Access Denied: Cannot modify a quotation that is APPROVED or UNDER_REVIEW.";
        return;
      }
      this.service.update(this.currentEditId, this.quotation).subscribe({
        next: () => {
          alert("Quotation document node updated successfully.");
          this.closeDrawer();
          this.loadQuotations();
        },
        error: (err: any) => this.handleError(err)
      });
    } else {
      this.service.save(this.quotation, this.selectedFile).subscribe({
        next: () => {
          alert("Quotation document node synchronized successfully.");
          this.closeDrawer();
          this.loadQuotations();
        },
        error: (err: any) => this.handleError(err)
      });
    }
  }

  edit(o: QuotationResponseModel): void {
    if (o.status === 'APPROVED' || o.status === 'UNDER_REVIEW') {
      alert("Cannot edit or update a quotation that is APPROVED or UNDER_REVIEW.");
      return;
    }
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;

    this.quotation = {
      supplierId: o.supplierId,
      purchaseRequisitionId: o.purchaseRequisitionId,
      leadTimeDays: o.leadTimeDays,
      receivedAt: o.receivedAt,
      status: o.status,
      productDescription: o.productDescription || '',
      unitPrice: o.unitPrice,
      quantity: o.quantity,
      deliveryTime: o.deliveryTime,
      warranty: o.warranty || '',
      notes: o.notes || '',
      attachmentUrl: o.attachmentUrl || ''
    };

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number): void {
    if (!confirm("Are you sure you want to permanently delete this quotation bid profile?")) return;

    this.service.delete(id).subscribe({
      next: () => {
        alert("Quotation envelope successfully purged.");
        this.loadQuotations();
      },
      error: (err: any) => alert(err.error?.message || "Deletion failure.")
    });
  }

  canUploadQuotation(): boolean {
    return !this.isProcurement();
  }

  openPdfModal(q: QuotationResponseModel) {
    this.selectedQuotationForPdf = q;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedQuotationForPdf = null;
    this.cdr.markForCheck();
  }

  downloadPdfFromModal() {
    if (!this.selectedQuotationForPdf) return;

    const element = this.pdfPreviewContainer.nativeElement;
    
    html2canvas(element, { scale: 2, useCORS: true, windowHeight: element.scrollHeight, height: element.scrollHeight }).then((canvas) => {
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

      const qtnNumber = this.selectedQuotationForPdf?.quotationNumber || `QTN-${this.selectedQuotationForPdf?.id}`;
      pdf.save(`Quotation-${qtnNumber}.pdf`);
      
      this.closePdfModal();
    });
  }

  reset(): void {
    this.quotation = {
      supplierId: this.activeRole === 'SUPPLIER' && this.currentSupplierId ? this.currentSupplierId : 0,
      purchaseRequisitionId: 0,
      leadTimeDays: 1,
      receivedAt: '',
      status: 'PENDING',
      productDescription: '',
      unitPrice: 0,
      quantity: 1,
      deliveryTime: '',
      warranty: '',
      notes: '',
      attachmentUrl: ''
    };
    this.selectedFile = null;
    this.currentEditId = null;
    this.isEdit = false;
    this.errorMessage = null;
  }

  private handleError(err: any): void {
    this.errorMessage = err.error?.message || err.message || "Quotation Pipeline Error.";
    this.cdr.markForCheck();
  }
}