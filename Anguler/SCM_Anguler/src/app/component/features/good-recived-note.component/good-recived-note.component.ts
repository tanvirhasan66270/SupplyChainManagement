import { ChangeDetectorRef, Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import {
  GoodsReceivedNoteRequestModel,
  GoodsReceivedNoteResponseModel,
  GRNLineItemRequestModel,
  GRNLineItemResponseModel,
} from '../../shared/model/goodRecivedNoteModel';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { GoodRecivedNoteService } from '../../../service/good-recived-note.service';
import { WarehouseService } from '../../../service/warehouse.service';
import { AddProductService } from '../../../service/add-product.service';
import { ManagerService } from '../../../service/manager.service';
import { QcInspectorService } from '../../../service/qc-inspactor.service';
import { StorageService } from '../../../auth/auth_service/storage.service';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';

@Component({
  selector: 'app-good-recived-note',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './good-recived-note.component.html',
  styleUrl: './good-recived-note.component.css',
})
export class GoodRecivedNoteComponent implements OnInit {
  grns: GoodsReceivedNoteResponseModel[] = [];
  purchaseOrders: any[] = [];
  warehouses: any[] = [];
  products: any[] = [];
  filteredProducts: any[] = [];
  purchaseRequisitions: any[] = [];
  users: any[] = [];

  errorMessage: string | null = null;
  receivedQuantityError: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  currentUserId: number = 0;

  // যুক্ত করা হয়েছে: ইউজার রোল যা এইচটিএমএল-এ *ngIf এর জন্য ব্যবহৃত হবে
  userRole: string = 'CUSTOMER';

  statusEditId: number | null = null;
  statusEditValue: string = '';
  statusSaving = false;

  // PDF Preview States
  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;
  isPdfModalOpen = false;
  selectedGrnForPdf: GoodsReceivedNoteResponseModel | null = null;

  grn: GoodsReceivedNoteRequestModel = {
    poId: 0,
    productId: null,
    receivedQuantity: 0,
    receivedBy: 0,
    warehouseId: 0,
    receivedAt: '',
    status: 'PENDING',
    remarks: '',
    inspectedBy: null,
    inspectionDate: null,
    lineItems: [],
  };

  constructor(
    private service: GoodRecivedNoteService,
    private poService: PurchaseOrderService,
    private warehouseService: WarehouseService,
    private productService: AddProductService,
    private managerService: ManagerService,
    private qcInspectorService: QcInspectorService,
    private prService: PurchaseRequisitionService,
    public storage: StorageService,
    private cdr: ChangeDetectorRef,
  ) { }

  ngOnInit() {
    // রোল এবং ইউজার আইডি ইনিশিয়ালাইজ করা হচ্ছে
    this.userRole = this.storage.getActiveRole()?.toUpperCase() || 'CUSTOMER';

    const user = this.storage.getUser();
    if (user) {
      this.currentUserId = user.userId;
      this.grn.receivedBy = user.userId;
    }
    this.loadGRNs();
    this.loadPurchaseOrders();
    this.loadWarehouses();
    this.loadProducts();
    this.loadUsers();
    this.loadPurchaseRequisitions();
  }

  loadGRNs() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.grns = data || [];
        this.cdr.markForCheck();
      },
    });
  }

  loadPurchaseOrders() {
    this.poService.findAll().subscribe({ next: (data) => (this.purchaseOrders = data || []) });
  }

  loadPurchaseRequisitions() {
    this.prService.findAll().subscribe({ next: (data) => (this.purchaseRequisitions = data || []) });
  }

  loadWarehouses() {
    this.warehouseService.getAll().subscribe({ next: (data) => (this.warehouses = data || []) });
  }

  loadProducts() {
    this.productService.findAll().subscribe({ next: (data) => {
      this.products = data || [];
      this.filteredProducts = [...this.products];
    }});
  }

  onPoChange() {
    const selectedPo = this.purchaseOrders.find((po: any) => Number(po.id) === Number(this.grn.poId));
    if (selectedPo && selectedPo.purchaseRequisitionId) {
      const pr = this.purchaseRequisitions.find((r: any) => Number(r.id) === Number(selectedPo.purchaseRequisitionId));
      if (pr && pr.productIds && pr.productIds.length > 0) {
        this.filteredProducts = this.products.filter(p => pr.productIds.includes(Number(p.id)));
      } else {
        this.filteredProducts = [];
      }
    } else {
      if (Number(this.grn.poId) !== 0) {
        this.filteredProducts = [];
      } else {
        this.filteredProducts = [...this.products];
      }
    }
    
    // Reset invalid line items
    this.grn.lineItems.forEach(item => {
      if (!this.filteredProducts.find(p => p.id === Number(item.productId))) {
        item.productId = 0;
      }
    });
    this.cdr.markForCheck();
  }

  loadUsers() {
    const managers$ = this.managerService.findAll();
    const inspectors$ = this.qcInspectorService.findAll();

    managers$.subscribe({ next: (managers) => {
        const managerUsers = (managers || []).map((m: any) => ({
          id: m.userId || m.id,
          name: m.name || m.managerName,
          role: 'WAREHOUSE_MANAGER' }));
        inspectors$.subscribe({ next: (inspectors) => {
            const inspectorUsers = (inspectors || []).map((i: any) => ({
              id: i.userId || i.id,
              name: i.name || i.inspectorName,
              role: 'QUALITY_INSPECTOR' }));
            this.users = [...managerUsers, ...inspectorUsers];
            this.cdr.markForCheck();
          },
          error: () => {
            this.users = managerUsers;
            this.cdr.markForCheck();
          },
        });
      },
      error: () => {
        inspectors$.subscribe({ next: (inspectors) => {
            this.users = (inspectors || []).map((i: any) => ({
              id: i.userId || i.id,
              name: i.name || i.inspectorName,
              role: 'QUALITY_INSPECTOR' }));
            this.cdr.markForCheck();
          },
          error: () => {
            this.users = [];
          },
        });
      },
    });
  }

  addLineItem() {
    const newItem: GRNLineItemRequestModel = {
      productId: 0,
      quantityOrdered: 0,
      quantityReceived: 0,
    };
    this.grn.lineItems.push(newItem);
    this.cdr.markForCheck();
  }

  removeLineItem(index: number) {
    this.grn.lineItems.splice(index, 1);
    this.cdr.markForCheck();
  }

  openDrawer() {
    this.reset();
    this.isEdit = false;
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.reset();
    this.cdr.markForCheck();
  }

  openPdfModal(grn: GoodsReceivedNoteResponseModel) {
    this.selectedGrnForPdf = grn;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedGrnForPdf = null;
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

      pdf.save(`GRN-Manifest-${this.selectedGrnForPdf?.grnNumber || 'Node'}.pdf`);
    });
  }

  save() {
    this.errorMessage = null;
    this.receivedQuantityError = null;

    if (!this.grn.poId || !this.grn.warehouseId || !this.grn.receivedBy) {
      this.errorMessage =
        'Validation Fault: Linked PO Node, Destination Warehouse, and Receiver Context are mandatory.';
      this.cdr.markForCheck();
      return;
    }

    const selectedPo = this.purchaseOrders.find((po: any) => Number(po.id) === Number(this.grn.poId));
    if (selectedPo) {
      const maxAllowed = Number(selectedPo.quantity || selectedPo.totalQuantity || selectedPo.orderedQuantity || 0);
      if (maxAllowed > 0 && Number(this.grn.receivedQuantity) > maxAllowed) {
        this.receivedQuantityError = `Received volume (${this.grn.receivedQuantity}) cannot exceed PO ordered quantity (${maxAllowed} Units).`;
        this.cdr.markForCheck();
        return;
      }
    }

    const payload: GoodsReceivedNoteRequestModel = {
      ...this.grn,
      poId: +this.grn.poId,
      warehouseId: +this.grn.warehouseId,
      productId: this.grn.productId ? +this.grn.productId : null,
      receivedBy: +this.grn.receivedBy,
      inspectedBy: this.grn.inspectedBy ? +this.grn.inspectedBy : null,
      status: this.grn.status || 'PENDING',
      lineItems: this.grn.lineItems.map((item) => ({
        ...item,
        productId: +item.productId,
      })),
    };

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, payload).subscribe({
        next: () => {
          alert('Goods Received Note modified cleanly.');
          this.closeDrawer();
          this.loadGRNs();
        },
        error: (err: any) => {
          this.errorMessage = err.error?.message || 'Operational layout modification failure.';
          this.cdr.markForCheck();
        },
      });
    } else {
      this.service.save(payload).subscribe({
        next: () => {
          alert('New GRN Ledger generated and approved inside inventory matrix.');
          this.closeDrawer();
          this.loadGRNs();
        },
        error: (err: any) => {
          this.errorMessage = err.error?.message || 'Inventory integration exception.';
          this.cdr.markForCheck();
        },
      });
    }
  }

  edit(o: GoodsReceivedNoteResponseModel) {
    this.errorMessage = null;
    this.receivedQuantityError = null;
    this.currentEditId = o.id;
    this.isEdit = true;
    this.grn = {
      poId: o.poId,
      productId: o.productId || null,
      receivedQuantity: o.receivedQuantity,
      receivedBy: o.receivedBy,
      warehouseId: o.warehouseId,
      receivedAt: o.receivedAt,
      status: o.status,
      remarks: o.remarks,
      inspectedBy: o.inspectedBy,
      inspectionDate: o.inspectionDate,
      lineItems: [],
    };
    this.onPoChange();
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (
      confirm(
        'Definitively remove this Goods Received Note record? Warning: Inventory balances will remain unaffected.',
      )
    ) {
      this.service.delete(id).subscribe({
        next: () => {
          alert('GRN ledger node cleanly removed.');
          this.loadGRNs();
        },
        error: (err: any) => alert(err.error?.message || err.message),
      });
    }
  }

  reset() {
    this.grn = {
      poId: 0,
      productId: null,
      receivedQuantity: 0,
      receivedBy: this.currentUserId,
      warehouseId: 0,
      receivedAt: '',
      status: 'PENDING',
      remarks: '',
      inspectedBy: null,
      inspectionDate: null,
      lineItems: [],
    };
    this.receivedQuantityError = null;
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
    this.filteredProducts = [...this.products];
  }

  openStatusEdit(grn: GoodsReceivedNoteResponseModel) {
    this.statusEditId = grn.id;
    this.statusEditValue = grn.status;
    this.cdr.markForCheck();
  }

  closeStatusEdit() {
    this.statusEditId = null;
    this.statusEditValue = '';
    this.cdr.markForCheck();
  }

  changeStatus(grn: GoodsReceivedNoteResponseModel) {
    if (!this.statusEditValue || this.statusEditValue === grn.status) {
      this.closeStatusEdit();
      return;
    }
    this.statusSaving = true;
    const payload: GoodsReceivedNoteRequestModel = {
      poId: grn.poId,
      productId: grn.productId || null,
      receivedQuantity: grn.receivedQuantity,
      receivedBy: grn.receivedBy,
      warehouseId: grn.warehouseId,
      receivedAt: grn.receivedAt,
      status: this.statusEditValue,
      remarks: grn.remarks,
      inspectedBy: grn.inspectedBy,
      inspectionDate: grn.inspectionDate,
      lineItems: [],
    };
    this.service.update(grn.id, payload).subscribe({
      next: () => {
        this.statusSaving = false;
        this.closeStatusEdit();
        this.loadGRNs();
      },
      error: (err: any) => {
        this.statusSaving = false;
        this.errorMessage = err.error?.message || 'Status update failed.';
        this.closeStatusEdit();
        this.cdr.markForCheck();
      },
    });
  }
}