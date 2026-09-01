import { ChangeDetectorRef, Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { POLineItemRequestDTO, POLineItemResponseDTO } from '../../shared/model/pOLineItemModel';
import { PoLineItemService } from '../../../service/po-line-item.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { QuotationService } from '../../../service/quatation.service';
import { AddProductService } from '../../../service/add-product.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';
import { SupplierService } from '../../../service/supplier.service';

@Component({
  selector: 'app-poline-item',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './poline-item.component.html',
  styleUrl: './poline-item.component.css',
})
export class POLineItemComponent implements OnInit {
  @Input() isEmbedded: boolean = false;
  @Input() isDashboardMode: boolean = false;
  @Output() formClosed = new EventEmitter<void>();

  lineItems: POLineItemResponseDTO[] = [];
  purchaseOrders: any[] = [];
  products: any[] = [];
  allProducts: any[] = [];

  currentSupplierId: number | null = null;
  activeRole: string = 'CUSTOMER';
  searchSupplier: string = '';
searchProduct: string = '';
searchStatus: string = ''; 
filteredLineItems: POLineItemResponseDTO[] = [];

  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  trackingSearchQuery = '';

  userRole: string = '';

  item: POLineItemRequestDTO = {
    poId: 0,
    productId: 0,
    quantity: 1,
    unitPrice: 0,
    quotationRef: '',
    poNumber: '',
    deliveryDate: '',
    shipmentMethod: '',
    notes: '',
    status: 'PENDING'
  };

  constructor(
    private service: PoLineItemService,
    private poService: PurchaseOrderService,
    private prService: PurchaseRequisitionService,
    private quotationService: QuotationService,
    private productService: AddProductService,
    private supplierService: SupplierService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.activeRole = this.storage.getActiveRole()?.toUpperCase() || '';
    const user = this.storage.getUser();
    
    const cachedSupplier = this.storage.getData(KEYS.SUPPLIER) as any;
    if (cachedSupplier) {
      this.currentSupplierId = cachedSupplier.id;
    }

    if (user && this.activeRole === 'SUPPLIER' && !this.currentSupplierId) {
      this.supplierService.getSupplierByUserId(user.userId).subscribe({ next: (res) => {
          if (res) {
            this.currentSupplierId = res.id;
            this.storage.saveData(KEYS.SUPPLIER, { id: this.currentSupplierId, name: res.name });
            this.loadSecurePipelineData();
          }
        },
        error: (err: any) => {
          console.error('Failed to resolve supplier identity:', err);
          this.loadSecurePipelineData();
        }
      });
    } else {
      this.loadSecurePipelineData();
    }
  }

  loadSecurePipelineData() {
    this.loadLineItems();
    this.loadPurchaseOrders();
  }
  applyFilters() {
  const sName = this.searchSupplier.toLowerCase().trim();
  const pName = this.searchProduct.toLowerCase().trim();
  const status = this.searchStatus.toLowerCase().trim();

  this.filteredLineItems = this.lineItems.filter(i => {
    return (i.supplierName?.toLowerCase().includes(sName) || '') &&
           (i.productName?.toLowerCase().includes(pName) || '') &&
           (i.status?.toLowerCase().includes(status) || '');
  });
  this.cdr.markForCheck();
}

  loadLineItems() {
    this.service.findAll().subscribe({ next: (data) => {
        const allItems = data || [];
        if (this.activeRole === 'SUPPLIER' && this.currentSupplierId) {
          this.lineItems = allItems.filter((i: any) => {
            const sId = i.supplierId || (i.supplier ? i.supplier.id : null);
            return sId === this.currentSupplierId });
        } else {
          this.lineItems = allItems;
        }
        this.cdr.markForCheck();
      }
    });
  }

  loadPurchaseOrders() {
    this.poService.findAll().subscribe({ next: (data) => {
        const allPOs = data || [];
        if (this.activeRole === 'SUPPLIER' && this.currentSupplierId) {
          this.purchaseOrders = allPOs.filter((po: any) => {
            const sId = po.supplierId || (po.supplier ? po.supplier.id : null);
            return sId === this.currentSupplierId;
          });
          
          // this.extractProductsFromSupplierPOs();
          if (this.products.length === 0) {
            this.loadAllGlobalProducts();
          }
        } else {
          this.purchaseOrders = allPOs;
          this.loadAllGlobalProducts();
        }
        this.cdr.markForCheck();
      }
    });
  }

          onPoChange(event?: any) {
    const poId = Number(this.item.poId);
    const targetPo = this.purchaseOrders.find(po => po.id === poId);
    
    if (targetPo) {
      this.item.poNumber = targetPo.poNumber || '';
      
      // Fetch Quotation to auto-fill quotationRef
      if (targetPo.quotationId) {
        this.quotationService.getById(targetPo.quotationId).subscribe({
          next: (q: any) => {
            if (q && q.quotationNumber) {
              this.item.quotationRef = q.quotationNumber;
              this.cdr.markForCheck();
            }
          }
        });
      } else {
        this.item.quotationRef = '';
      }
      
      if (targetPo.purchaseRequisitionId) {
        this.prService.getById(targetPo.purchaseRequisitionId).subscribe({
          next: (pr: any) => {
            if (pr && pr.productIds && Array.isArray(pr.productIds) && pr.productIds.length > 0) {
              this.products = this.allProducts.filter(p => pr.productIds.includes(p.id));
            } else {
              this.products = [...this.allProducts];
            }
            this.cdr.markForCheck();
          },
          error: () => {
            this.products = [...this.allProducts];
            this.cdr.markForCheck();
          }
        });
      } else if (targetPo.productIds && Array.isArray(targetPo.productIds) && targetPo.productIds.length > 0) {
        this.products = this.allProducts.filter(p => targetPo.productIds.includes(p.id));
      } else {
        this.products = [...this.allProducts];
      }
    } else {
      this.item.poNumber = '';
      this.item.quotationRef = '';
      this.products = [...this.allProducts];
    }
    this.cdr.markForCheck(); 
  }

  loadAllGlobalProducts() {
    this.productService.findAll().subscribe({
      next: (data) => {
        this.allProducts = data || [];
        if (!this.item.poId) {
          this.products = [...this.allProducts];
        }
        this.cdr.markForCheck();
      }
    });
  }

  openDrawer() { this.reset(); this.isEdit = false; this.isDrawerOpen = true; this.cdr.markForCheck(); }
  closeDrawer() { 
    this.isDrawerOpen = false; 
    this.reset(); 
    if (this.isEmbedded) {
      this.formClosed.emit();
    }
    this.cdr.markForCheck(); 
  }

  trackShipment() {
    if (!this.trackingSearchQuery.trim()) return;
    this.service.trackByNumber(this.trackingSearchQuery.trim()).subscribe({
      next: (res) => {
        alert(`Shipment Node Found!\nTracking: ${res.trackingNumber}\nStatus: ${res.status}\nMethod: ${res.shipmentMethod}`);
      },
      error: (err: any) => alert(err.error?.message || "Invalid Tracking Vector Number.")
    });
  }

  save() {
    this.errorMessage = null;

    if (!this.item.poId || Number(this.item.poId) === 0) {
      this.errorMessage = "Please select a Parent Purchase Order.";
      this.cdr.markForCheck();
      return;
    }

    if (!this.item.productId || Number(this.item.productId) === 0) {
      this.errorMessage = "Please select a Target Product Module.";
      this.cdr.markForCheck();
      return;
    }

    if (!this.item.quantity || Number(this.item.quantity) <= 0) {
      this.errorMessage = "Allocated Volume (Qty) must be at least 1.";
      this.cdr.markForCheck();
      return;
    }

    if (!this.item.deliveryDate) {
      this.errorMessage = "Target Delivery Date is required.";
      this.cdr.markForCheck();
      return;
    }

    this.item.poId = Number(this.item.poId);
    this.item.productId = Number(this.item.productId);
    this.item.quantity = Number(this.item.quantity);
    this.item.unitPrice = Number(this.item.unitPrice || 0);

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.item).subscribe({
        next: () => {
          alert("PO Line Item properties updated successfully.");
          this.closeDrawer();
          this.loadLineItems();
        },
        error: (err: any) => {
          this.errorMessage = err.error?.message || err.message || "Warehouse stock or state machine validation fault.";
          this.cdr.markForCheck();
        }
      });
    } else {
      this.service.save(this.item).subscribe({
        next: () => {
          alert("New PO Line Item logged. Inventory reserved successfully.");
          this.closeDrawer();
          this.loadLineItems();
        },
        error: (err: any) => {
          this.errorMessage = err.error?.message || err.message || "Insufficient warehouse stock vector or invalid mapping.";
          this.cdr.markForCheck();
        }
      });
    }
  }

  edit(o: POLineItemResponseDTO) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;
    this.item = {
      poId: o.poId,
      productId: o.productId,
      quantity: o.quantity,
      unitPrice: o.unitPrice,
      quotationRef: o.quotationRef || '',
      poNumber: o.poNumber || '',
      deliveryDate: o.deliveryDate,
      shipmentMethod: o.shipmentMethod || '',
      notes: o.notes || '',
      status: o.status
    };
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Wipe this item and release reserved inventory quantity allocations?")) {
      this.service.delete(id).subscribe({
        next: () => { alert("Item pruned. Parent aggregates re-calculated."); this.loadLineItems(); },
        error: (err: any) => alert(err.error?.message || err.message)
      });
    }
  }

  reset() {
    this.item = {
      poId: 0,
      productId: 0,
      quantity: 1,
      unitPrice: 0,
      quotationRef: '',
      poNumber: '',
      deliveryDate: '',
      shipmentMethod: '',
      notes: '',
      status: 'PENDING'
    };
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }

  isStatusModalOpen: boolean = false;
  statusUpdateItem: any = null;
  statusUpdateValue: string = '';

  openStatusModal(item: any) {
    this.statusUpdateItem = item;
    this.statusUpdateValue = item.status || 'PENDING';
    this.isStatusModalOpen = true;
    this.cdr.markForCheck();
  }

  closeStatusModal() {
    this.isStatusModalOpen = false;
    this.statusUpdateItem = null;
    this.cdr.markForCheck();
  }

  saveStatusUpdate() {
    if (!this.statusUpdateItem) return;
    
    // We update the item with the new status
    const updatePayload = {
      ...this.statusUpdateItem,
      status: this.statusUpdateValue
    };

    this.service.update(this.statusUpdateItem.id, updatePayload).subscribe({
      next: () => {
        this.closeStatusModal();
        this.loadLineItems();
      },
      error: (err: any) => {
        this.errorMessage = err.error?.message || err.message || "Failed to update status";
        this.closeStatusModal();
        this.cdr.markForCheck();
      }
    });
  }

  onStatusChangeInline(item: POLineItemResponseDTO, newStatus: string) {
    if (!item || item.status === newStatus) return;
    const oldStatus = item.status;
    item.status = newStatus;

    const updatePayload: POLineItemRequestDTO = {
      poId: item.poId,
      productId: item.productId,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      quotationRef: item.quotationRef || '',
      poNumber: item.poNumber || '',
      deliveryDate: item.deliveryDate || '',
      shipmentMethod: item.shipmentMethod || '',
      notes: item.notes || '',
      status: newStatus
    };

    this.service.update(item.id, updatePayload).subscribe({
      next: () => {
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        item.status = oldStatus;
        this.errorMessage = err.error?.message || err.message || "Failed to update status";
        this.cdr.markForCheck();
      }
    });
  }

  get displayLineItems(): POLineItemResponseDTO[] {
    let list = this.lineItems || [];
    if (this.searchSupplier && this.searchSupplier.trim()) {
      const sName = this.searchSupplier.toLowerCase().trim();
      list = list.filter(i => (i.supplierName || '').toLowerCase().includes(sName));
    }
    if (this.searchProduct && this.searchProduct.trim()) {
      const pName = this.searchProduct.toLowerCase().trim();
      list = list.filter(i => (i.productName || '').toLowerCase().includes(pName));
    }
    if (this.searchStatus && this.searchStatus.trim()) {
      const status = this.searchStatus.toLowerCase().trim();
      list = list.filter(i => (i.status || '').toLowerCase() === status);
    }
    if (this.trackingSearchQuery && this.trackingSearchQuery.trim()) {
      const q = this.trackingSearchQuery.toLowerCase().trim();
      list = list.filter(i => 
        (i.poNumber || '').toLowerCase().includes(q) ||
        (i.productName || '').toLowerCase().includes(q) ||
        (i.supplierName || '').toLowerCase().includes(q) ||
        (i.trackingNumber || '').toLowerCase().includes(q) ||
        String(i.id).includes(q) ||
        String(i.poId).includes(q)
      );
    }
    return list;
  }
}


