import { Component, OnInit, ChangeDetectorRef, ElementRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PurchaseOrderRequestModel, PurchaseOrderResponseModel } from '../../shared/model/purchaseOrderModel';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { QuotationService } from '../../../service/quatation.service';
import { SupplierService } from '../../../service/supplier.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';

// jsPDF এবং html2canvas ইমপোর্ট
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

@Component({
  selector: 'app-purchase-order',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './purchase-order.component.html',
  styleUrl: './purchase-order.component.css',
})
export class PurchaseOrderComponent implements OnInit {

  orders: PurchaseOrderResponseModel[] = [];
  filteredOrders: PurchaseOrderResponseModel[] = [];
  quotations: any[] = [];
  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  
  activeRole: string = 'SUPPLIER';
  currentSupplierId: number | null = null;

  searchQuery: string = '';        
  searchSupplier: string = '';    
  searchDate: string = '';        

  // PDF প্রিভিউ মডালের জন্য ভেরিয়েবল
  isPdfModalOpen = false;
  selectedOrderForPdf: PurchaseOrderResponseModel | null = null;
  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;

  order: PurchaseOrderRequestModel = {
    quotationId: 0,
    issuedBy: 0,
    issuedByName: '', 
    totalAmount: 0,
    quantity: 1,      
    currency: 'USD',
    expectedDeliveryDate: '',
    status: 'DRAFT',
    createdAt: ''    
  };

  constructor(
    private service: PurchaseOrderService,
    private quotationService: QuotationService,
    private supplierService: SupplierService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.activeRole = this.storage.getActiveRole()?.toUpperCase() || 'SUPPLIER';
    const currentUser = this.storage.getUser();
    if (currentUser) {
      this.order.issuedBy = currentUser.userId;
    }

    const cachedSupplier = this.storage.getData(KEYS.SUPPLIER) as { id: number; [key: string]: any };
    if (cachedSupplier && cachedSupplier.id) {
      this.currentSupplierId = cachedSupplier.id;
    }

    if (this.activeRole === 'SUPPLIER' && !this.currentSupplierId && currentUser?.userId) {
      this.supplierService.getSupplierByUserId(currentUser.userId).subscribe({ next: (supplier: any) => {
          if (supplier && supplier.id) {
            this.currentSupplierId = supplier.id;
            this.storage.saveData(KEYS.SUPPLIER, { id: this.currentSupplierId, name: supplier.name });
          }
          this.loadOrders();
          this.loadQuotations();
        },
        error: () => {
          this.loadOrders();
          this.loadQuotations();
        }
      });
    } else {
      this.loadOrders();
      this.loadQuotations();
    }
  }

  canAddPurchaseOrder(): boolean {
    return this.activeRole === 'ADMIN' || 
           this.activeRole === 'MANAGER' || 
           this.activeRole === 'PROCUREMENT';
  }

  isManagementUser(): boolean {
    return this.activeRole === 'ADMIN' || 
           this.activeRole === 'MANAGER' || 
           this.activeRole === 'PROCUREMENT' ||
           this.activeRole === 'COMMERCIAL_OFFICER'
          //   ||
          //  this.activeRole === 'LOGISTICS_OFFICER';
  }

  shouldShowCardSearchBar(): boolean {
    if (this.activeRole === 'PROCUREMENT' || this.activeRole === 'MANAGER' || this.activeRole === 'LOGISTICS_OFFICER') {
      return false;
    }
    return true; 
  }

  loadOrders() {
    this.service.findAll().subscribe({
      next: (data) => { 
        this.orders = data || [];
        this.applyDataIsolationAndFilters();
      },
      error: (err: any) => console.error('PO Load Error:', err)
    });
  }

  applyDataIsolationAndFilters(): void {
    let ordersPipe = [...this.orders];

    if (this.activeRole === 'SUPPLIER') {
      if (this.currentSupplierId) {
        ordersPipe = ordersPipe.filter((po: any) => {
        const poSupId = Number(po.supplierId || po.supplier?.id || 0);
          const currentId = Number(this.currentSupplierId);
          return poSupId === currentId;
        });
      } else {
        ordersPipe = [];
      }
    } 
    else if (this.activeRole === 'LOGISTICS_OFFICER') {
      // লজিস্টিকস অফিসারদের জন্য ফিল্টার লজিক
    }
    else if (!this.isManagementUser()) {
      ordersPipe = []; 
    }

    if (this.isManagementUser() || this.activeRole === 'SUPPLIER') {
      if (this.searchQuery && this.searchQuery.trim() !== '') {
        const query = this.searchQuery.toLowerCase();
        ordersPipe = ordersPipe.filter((o: any) => 
          (o.poNumber && o.poNumber.toLowerCase().includes(query)) || 
          (o.status && o.status.toLowerCase().includes(query))
        );
      }

      if (this.searchSupplier && this.searchSupplier.trim() !== '') {
        const supplierQuery = this.searchSupplier.toLowerCase();
        ordersPipe = ordersPipe.filter((o: any) => 
          (o.supplierName && o.supplierName.toLowerCase().includes(supplierQuery)) || 
          (o.supplierId && o.supplierId.toString() === supplierQuery) ||
          (o.supplier?.name && o.supplier.name.toLowerCase().includes(supplierQuery))
        );
      }

      if (this.searchDate && this.searchDate !== '') {
        ordersPipe = ordersPipe.filter((o: any) => 
          (o.createdAt && o.createdAt.includes(this.searchDate)) ||
          (o.expectedDeliveryDate && o.expectedDeliveryDate.includes(this.searchDate))
        );
      }
    }

    this.filteredOrders = ordersPipe;
    this.cdr.markForCheck();
  }
  
  loadQuotations() {
    if (this.activeRole === 'SUPPLIER') return;

    this.quotationService.findAll().subscribe({
      next: (data) => {
        this.quotations = data ? data.filter((q: any) => q.status === 'APPROVED') : [];
        this.cdr.markForCheck();
      }
    });
  }

  onQuotationChange(event: any) {
    const qId = +event.target.value;
    const selectedQ = this.quotations.find(q => q.id === qId);
    
    if (selectedQ) {
      this.order.totalAmount = selectedQ.totalPrice;
      this.order.supplierName = selectedQ.supplierName;
      this.order.supplierEmail = selectedQ.supplierEmail || selectedQ.email || (selectedQ.supplier ? selectedQ.supplier.email : 'N/A');
      this.order.purchaseRequisitionId = selectedQ.purchaseRequisitionId;
    }
  }

  openDrawer() { this.reset(); this.isEdit = false; this.isDrawerOpen = true; this.cdr.markForCheck(); }
  closeDrawer() { this.isDrawerOpen = false; this.reset(); this.cdr.markForCheck(); }

  save() {
    this.errorMessage = null;

    if (this.order.quotationId === 0) {
      this.errorMessage = 'Validation Fault: Mapping an active Approved Quotation node is required.';
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.order).subscribe({
        next: () => { alert("Purchase Order updated successfully."); this.closeDrawer(); this.loadOrders(); },
        error: (err: any) => this.errorMessage = err.error?.message || "Modification matrix locked."
      });
    } else {
      this.service.save(this.order).subscribe({
        next: () => { alert("New Purchase Order created as DRAFT. Approval mail dispatched to manager."); this.closeDrawer(); this.loadOrders(); },
        error: (err: any) => this.errorMessage = err.error?.message || "Deployment pipeline fault."
      });
    }
  }

  edit(o: PurchaseOrderResponseModel) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;

    this.order = {
      quotationId: o.quotationId,
      issuedBy: o.issuedBy,
      issuedByName: (this.storage.getUser()?.name) || 'Unknown', 
      totalAmount: o.totalAmount,
      quantity: o.quantity,
      currency: o.currency,
      expectedDeliveryDate: o.expectedDeliveryDate,
      status: o.status,
      poNumber: o.poNumber,
      supplierName: o.supplierName,
      supplierEmail: o.supplierEmail, 
      purchaseRequisitionId: o.purchaseRequisitionId,
      createdAt: o.createdAt
    };

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Definitively purge this Purchase Order record from active directories?")) {
      this.service.delete(id).subscribe({
        next: () => { alert("PO instance wiped successfully."); this.loadOrders(); },
        error: (err: any) => alert(err.error?.message || err.message)
      });
    }
  }

  // PDF প্রিভিউ মডাল ওপেন করার ফাংশন
  openPdfModal(o: PurchaseOrderResponseModel) {
    this.selectedOrderForPdf = o;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  // PDF প্রিভিউ মডাল বন্ধ করার ফাংশন
  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedOrderForPdf = null;
    this.cdr.markForCheck();
  }

  // প্রিভিউ মডাল থেকে ওয়ার্ড পেজ আকারে পিডিএফ ডাউনলোড করার ফাংশন
  downloadPdfFromModal() {
    if (!this.selectedOrderForPdf) return;

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

      pdf.save(`PO-${this.selectedOrderForPdf?.poNumber}.pdf`);
      this.closePdfModal();
    });
  }

  reset() {
    const currentUser = this.storage.getUser();
    const systemDate = new Date().toISOString();

    this.order = {
      quotationId: 0,
      issuedBy: currentUser?.userId || 0,
      issuedByName: currentUser?.name || 'Unknown User',
      totalAmount: 0,
      quantity: 1,
      currency: 'USD',
      expectedDeliveryDate: '',
      status: 'DRAFT',
      createdAt: systemDate,
      supplierName: '',
      supplierEmail: '',
      purchaseRequisitionId: 0
    };
    
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }
}