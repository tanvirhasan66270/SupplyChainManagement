import { Component, OnInit, ChangeDetectorRef, ElementRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';
import { purchaseRequisitionRequestModel, purchaseRequisitionResponseModel } from '../../shared/model/purchase-requisionModel';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { AddProductService } from '../../../service/add-product.service';
import { SupplierService } from '../../../service/supplier.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';
import { ProductRequirementService } from '../../../service/product-requirement.service';
import { ProductRequirementResponse } from '../../shared/model/productRequirementModel';

@Component({
  selector: 'app-purchase-requisition',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './purchase-requisition.component.html',
  styleUrls: ['./purchase-requisition.component.css']
})
export class PurchaseRequisitionComponent implements OnInit {

  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;
  isPdfModalOpen = false;
  selectedReqForPdf: purchaseRequisitionResponseModel | null = null;

  requisitions: purchaseRequisitionResponseModel[] = [];
  filteredRequisitions: purchaseRequisitionResponseModel[] = []; 
  products: any[] = [];
  suppliers: any[] = [];
  requirements: ProductRequirementResponse[] = [];
  selectedRequirementIds: number[] = [];
  userRole: string = '';
  currentSupplierId: number | null = null;

  searchId: string = '';
  searchUrgency: string = '';

  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;

  selectedProductInput: any = null;
  selectedSupplierInput: any = null;

  requisition: purchaseRequisitionRequestModel = {
    requestedBy: 0,
    productIds: [],
    supplierIds: [],
    currency: 'USD',
    quantityRequired: 1,
    urgencyLevel: 'LOW',
    requiredByDate: '',
    remarks: ''
  };

  constructor(
    private service: PurchaseRequisitionService,
    private productService: AddProductService,
    private reqService: ProductRequirementService,
    private supplierService: SupplierService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.userRole = this.storage.getActiveRole()?.toUpperCase() || '';
    const currentUser = this.storage.getUser();
    if (currentUser) {
      this.requisition.requestedBy = currentUser.userId;
      if (!this.userRole && currentUser.role) {
        this.userRole = currentUser.role.toUpperCase();
      }
    }

    const cachedSupplier = this.storage.getData(KEYS.SUPPLIER) as any;
    if (cachedSupplier) {
      this.currentSupplierId = cachedSupplier.id;
    }

    if (this.userRole === 'SUPPLIER' && !this.currentSupplierId && currentUser?.userId) {
      this.supplierService.getSupplierByUserId(currentUser.userId).subscribe({ next: (supplier) => {
          if (supplier && supplier.id) {
            this.currentSupplierId = supplier.id;
            this.storage.saveData(KEYS.SUPPLIER, { id: this.currentSupplierId, name: supplier.name });
          }
          this.loadRequisitions();
          this.loadProducts();
          this.loadRequirements();
          this.loadSuppliers();
        },
        error: () => {
          this.loadRequisitions();
          this.loadProducts();
          this.loadRequirements();
          this.loadSuppliers();
        }
      });
    } else {
      this.loadRequisitions();
      this.loadProducts();
      this.loadRequirements();
      this.loadSuppliers();
    }
  }
  loadRequisitions() { 
    this.service.findAll().subscribe({ next: (data) => {
        let allRequisitions = data || [];

        // ENHANCE: Parse Remarks to extract Product Requirements and push to productNames for UI display
        allRequisitions = allRequisitions.map((pr: any) => {
          if (pr.remarks && pr.remarks.includes('[Fulfilling Requirements: ')) {
            const match = pr.remarks.match(/\[Fulfilling Requirements:\s*(.*?)\]/);
            if (match && match[1]) {
              pr.productNames = [...(pr.productNames || []), ...match[1].split(',').map((s: string) => '[Req] ' + s.trim())];
            }
          }
          return pr;
        });

        if (this.userRole === 'SUPPLIER' && this.currentSupplierId) {
          this.requisitions = allRequisitions.filter((pr: any) => {
            const hasSupplier = pr.supplierIds?.includes(this.currentSupplierId) || 
                                (pr.suppliers && pr.suppliers.some((s: any) => s.id === this.currentSupplierId));
            return hasSupplier && pr.approvalStatus === 'APPROVED' });
        } else {
          // ADMIN/MANAGER/PROCUREMENT 
          this.requisitions = allRequisitions;
        }

        this.filteredRequisitions = [...this.requisitions];
        this.applyDoubleSearch(); 
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        this.errorMessage = err.error?.message || "Failed to sync cluster directories.";
        this.cdr.markForCheck();
      }
    }); 
  }

  applyDoubleSearch() {
    const idTerm = this.searchId.toLowerCase().trim();
    const urgencyTerm = this.searchUrgency.toLowerCase().trim();

    this.filteredRequisitions = this.requisitions.filter(pr => {
      const prIdStr = pr.id ? `#PRQ-${pr.id}` : '';
      const urgency = pr.urgencyLevel || 'LOW';

      const matchesId = prIdStr.toLowerCase().includes(idTerm) || pr.id?.toString().includes(idTerm);
      const matchesUrgency = urgency.toLowerCase().includes(urgencyTerm);

      return matchesId && matchesUrgency;
    });

    this.cdr.markForCheck();
  }

  loadProducts() { this.productService.findAll().subscribe(data => { this.products = data || []; this.cdr.markForCheck(); }); }
  
  loadRequirements() {
    this.reqService.findAll().subscribe(data => {
      this.requirements = data || [];
      this.cdr.markForCheck();
    });
  }

  loadSuppliers() { 
    if (this.userRole === 'SUPPLIER') return; 
    this.supplierService.findAll().subscribe(data => { this.suppliers = data || []; this.cdr.markForCheck(); }); 
  }

  onProductSelect(event: any) {
    const val = event.target.value;
    if (!val) return;
    
    if (val.startsWith('PROD_')) {
      const id = parseInt(val.replace('PROD_', ''), 10);
      if (id && !this.requisition.productIds.includes(id)) {
        this.requisition.productIds.push(id);
      }
    } else if (val.startsWith('REQ_')) {
      const id = parseInt(val.replace('REQ_', ''), 10);
      if (id && !this.selectedRequirementIds.includes(id)) {
        this.selectedRequirementIds.push(id);
      }
    }
    
    this.selectedProductInput = null; 
    this.cdr.markForCheck();
  }

  removeProduct(id: number) {
    this.requisition.productIds = this.requisition.productIds.filter(pId => pId !== id);
    this.cdr.markForCheck();
  }

  removeRequirement(id: number) {
    this.selectedRequirementIds = this.selectedRequirementIds.filter(rId => rId !== id);
    this.cdr.markForCheck();
  }

  getProductById(id: number) {
    return this.products.find(p => p.id === id);
  }

  getRequirementById(id: number) {
    return this.requirements.find(r => r.id === id);
  }

  isRequirementSelected(id: number): boolean {
    return this.selectedRequirementIds.includes(id);
  }

  onSupplierSelect(event: any) {
    const id = +event.target.value;
    if (id && !this.requisition.supplierIds.includes(id)) {
      this.requisition.supplierIds.push(id);
    }
    this.selectedSupplierInput = null; 
    this.cdr.markForCheck();
  }

  removeSupplier(id: number) {
    this.requisition.supplierIds = this.requisition.supplierIds.filter(sId => sId !== id);
    this.cdr.markForCheck();
  }

  getSupplierById(id: number) {
    return this.suppliers.find(s => s.id === id);
  }

  autoGrowTextarea(event: any) {
    const element = event.target;
    element.style.height = 'auto';
    element.style.height = (element.scrollHeight + 2) + 'px';
  }

  openDrawer() { this.reset(); this.isEdit = false; this.isDrawerOpen = true; this.cdr.markForCheck(); }
  closeDrawer() { this.isDrawerOpen = false; this.reset(); this.cdr.markForCheck(); }

  authorizeApproval(id: number) {
    if (confirm("Verify and AUTHORIZE this procurement requisition vector?")) {
      this.service.approve(id).subscribe({
        next: () => { alert("Requisition APPROVED successfully."); this.loadRequisitions(); },
        error: (err: any) => alert(err.error?.message || "Authorization exception.")
      });
    }
  }

  authorizeRejection(id: number, action: 'REJECT' | 'CANCEL') {
    if (confirm(`Definitively register ${action} state on this requisition sheet?`)) {
      this.service.rejectOrCancel(id, action).subscribe({
        next: () => { alert(`Requisition state set to ${action} successfully.`); this.loadRequisitions(); },
        error: (err: any) => alert(err.error?.message || "Status mutation failure.")
      });
    }
  }

  save() {
    this.errorMessage = null;
    if ((this.requisition.productIds.length === 0 && this.selectedRequirementIds.length === 0) || this.requisition.supplierIds.length === 0) {
      this.errorMessage = "Validation Fault: Please select at least one product and supplier node.";
      return;
    }

    if (this.selectedRequirementIds.length > 0) {
      const reqNames = this.selectedRequirementIds
        .map(rid => this.getRequirementById(rid)?.productName)
        .filter(Boolean)
        .join(', ');
      const prefix = this.requisition.remarks ? this.requisition.remarks + '\n' : '';
      this.requisition.remarks = prefix + `[Fulfilling Requirements: ${reqNames}]`;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.requisition).subscribe({
        next: () => { alert("Requisition updated successfully!"); this.closeDrawer(); this.loadRequisitions(); },
        error: (err: any) => this.errorMessage = err.error?.message || "Update failed."
      });
    } else {
      this.service.save(this.requisition).subscribe({
        next: () => { alert("Requisition logged successfully!"); this.closeDrawer(); this.loadRequisitions(); },
        error: (err: any) => this.errorMessage = err.error?.message || "Creation error."
      });
    }
  }

  edit(o: purchaseRequisitionResponseModel) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;
    this.requisition = {
      requestedBy: o.requestedBy,
      productIds: [...o.productIds],
      supplierIds: [...o.supplierIds],
      currency: 'USD', 
      quantityRequired: o.quantityRequired,
      urgencyLevel: o.urgencyLevel,
      requiredByDate: o.requiredByDate,
      remarks: o.remarks || ''
    };
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Are you sure you want to permanently delete this procurement requisition record?")) {
      this.service.delete(id).subscribe({
        next: () => { alert("Purged successfully."); this.loadRequisitions(); },
        error: (err: any) => alert(err.error?.message || err.message)
      });
    }
  }

  reset() {
    const currentUser = this.storage.getUser();
    this.requisition = {
      requestedBy: currentUser?.userId || 0,
      productIds: [],
      supplierIds: [],
      currency: 'USD',
      quantityRequired: 1,
      urgencyLevel: 'LOW',
      requiredByDate: '',
      remarks: ''
    };
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }

  isProductSelected(productId: number): boolean {
    return this.requisition.productIds.includes(productId);
  }

  isSupplierSelected(supplierId: number): boolean {
    return this.requisition.supplierIds.includes(supplierId);
  }

  openPdfModal(r: purchaseRequisitionResponseModel) {
    this.selectedReqForPdf = r;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedReqForPdf = null;
    this.cdr.markForCheck();
  }

  downloadPdfFromModal() {
    const element = this.pdfPreviewContainer.nativeElement;
    html2canvas(element, { scale: 2, useCORS: true, windowHeight: element.scrollHeight, height: element.scrollHeight }).then((canvas: HTMLCanvasElement) => {
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

      pdf.save(`Requisition-Details-PRQ-${this.selectedReqForPdf?.id || 'Doc'}.pdf`);
    });
  }
}


