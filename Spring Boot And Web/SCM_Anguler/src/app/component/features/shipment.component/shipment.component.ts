import { ChangeDetectorRef, Component, OnInit, ViewChild, ElementRef, Input, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ShipmentRequestModel, ShipmentResponseModel } from '../../shared/model/shipmentModel';
import { ShipmentService } from '../../../service/shipment.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { SupplierService } from '../../../service/supplier.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';

import { ActivatedRoute } from '@angular/router';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import { environment } from '../../../../environment/environment';

@Component({
  selector: 'app-shipment',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './shipment.component.html',
  styleUrl: './shipment.component.css',
})
export class ShipmentComponent implements OnInit {
  @Input() isEmbedded: boolean = false;
  @Output() formClosed = new EventEmitter<void>();
  shipments: ShipmentResponseModel[] = [];
  filteredShipments: ShipmentResponseModel[] = [];
  purchaseOrders: any[] = [];
  suppliers: any[] = [];

  searchNo: string = '';
  searchVehicle: string = '';

  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  selectedFile: File | null = null;
  currentUserEmail: string = '';

  userRole: string = '';
  currentSupplierId: number | null = null;
  currentSupplierName: string = ''; 

  isPdfModalOpen = false;
  selectedShipmentForPdf: ShipmentResponseModel | null = null;
  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;

readonly imageBaseUrl = environment.imgUrl + "shipments/";



  shipment: ShipmentRequestModel = {
    poId: 0,
    supplierId: 0,
    vehicleNumber: '',
    captainRegistrationNumber: '',
    assignedByEmail: '',
    origin: '',
    sendByAddress: '',
    estimatedDelivery: '',
    transportCost: 0,
    shipmentQuantity: 0,
    podFileUrl: '',
  };

  constructor(
    private service: ShipmentService,
    private poService: PurchaseOrderService,
    private supplierService: SupplierService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef,
    private route: ActivatedRoute
  ) {}

  ngOnInit() {
    this.userRole = this.storage.getActiveRole()?.toUpperCase() || '';
    const user = this.storage.getUser();
    if (user) {
      this.currentUserEmail = user.email;
      this.shipment.assignedByEmail = user.email;
      if (!this.userRole && user.role) {
        this.userRole = user.role.toUpperCase();
      }
    }

    const cachedSupplier = this.storage.getData(KEYS.SUPPLIER) as any;
    if (cachedSupplier) {
      this.currentSupplierId = cachedSupplier.id;
      this.currentSupplierName = cachedSupplier.name || cachedSupplier.companyName || user?.name || 'Your Supplier Account';
    } else {
      this.currentSupplierName = user?.name || 'Your Supplier Account';
    }

    if (this.userRole === 'SUPPLIER' && !this.currentSupplierId && user?.userId) {
      this.supplierService.getSupplierByUserId(user.userId).subscribe({ next: (supplier) => {
          if (supplier && supplier.id) {
            this.currentSupplierId = supplier.id;
            this.currentSupplierName = supplier.name || this.currentSupplierName;
            this.storage.saveData(KEYS.SUPPLIER, { id: this.currentSupplierId, name: this.currentSupplierName });
          }
          this.loadShipments();
          this.loadPurchaseOrders();
        },
        error: () => {
          this.loadShipments();
          this.loadPurchaseOrders();
        }
      });
    } else {
      this.loadShipments();
      this.loadPurchaseOrders();
      this.loadSuppliers();
    }

    this.route.queryParams.subscribe(params => {
      if (params['openForm'] === 'true') {
        this.openDrawer();
      }
    });
  }

  loadShipments() {
    this.service.findAll().subscribe({ next: (data) => {
        const allShipments = data || [];

        if (this.userRole === 'SUPPLIER') {
          if (this.currentSupplierId) {
            this.shipments = allShipments.filter((s: any) => {
              const sId = s.supplierId || (s.supplier ? s.supplier.id : null);
              return Number(sId) === Number(this.currentSupplierId) });
          } else {
            this.shipments = [];
          }
        } else {
          this.shipments = allShipments;
        }

        this.filteredShipments = [...this.shipments];
        this.applyDoubleSearch();
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error("Shipment Load Error:", err);
      }
    });
  }

  applyDoubleSearch() {
    const noTerm = this.searchNo.toLowerCase().trim();
    const vehicleTerm = this.searchVehicle.toLowerCase().trim();

    this.filteredShipments = this.shipments.filter(s => {
      const shipNo = s.shipmentNumber || '';
      const vehicleNo = s.vehicleNumber || '';

      const matchesNo = shipNo.toLowerCase().includes(noTerm);
      const matchesVehicle = vehicleNo.toLowerCase().includes(vehicleTerm);

      return matchesNo && matchesVehicle;
    });
    this.cdr.markForCheck();
  }

  loadPurchaseOrders() {
    this.poService.findAll().subscribe({ next: (data) => {
        const allPOs = data || [];
        if (this.userRole === 'SUPPLIER' && this.currentSupplierId) {
          this.purchaseOrders = allPOs.filter((po: any) => {
            const sId = po.supplierId || (po.supplier ? po.supplier.id : null);
            return Number(sId) === Number(this.currentSupplierId) });
        } else {
          this.purchaseOrders = allPOs;
        }
        this.cdr.markForCheck();
      },
      error: (err: any) => console.error("PO Load Error:", err)
    });
  }

  loadSuppliers() {
    if (this.userRole === 'SUPPLIER') return;
    this.supplierService.findAll().subscribe({ next: (data) => (this.suppliers = data || []) });
  }

  onFileChange(event: any) {
    if (event.target.files && event.target.files.length > 0) {
      this.selectedFile = event.target.files[0];
    }
  }

  openDrawer() {
    this.reset();
    this.isEdit = false;
    
    if (this.userRole === 'SUPPLIER' && this.currentSupplierId) {
      this.shipment.supplierId = Number(this.currentSupplierId);
    }

    if (this.userRole === 'SUPPLIER' && this.purchaseOrders.length > 0 && (!this.shipment.poId || this.shipment.poId === 0)) {
      this.shipment.poId = Number(this.purchaseOrders[0].id);
      this.onPoChange();
    }
    
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  onPoChange() {
    if (this.shipment.poId) {
      const poId = Number(this.shipment.poId);
      const selectedPo = this.purchaseOrders.find(po => po.id === poId);
      if (selectedPo) {
        const sId = selectedPo.supplierId || (selectedPo.supplier ? selectedPo.supplier.id : null);
        if (sId) {
          this.shipment.supplierId = Number(sId);
        }
      }
    }
    this.cdr.markForCheck();
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.errorMessage = null;
    if (this.isEmbedded) {
      this.formClosed.emit();
    }
    this.reset();
    this.cdr.markForCheck();
  }

  getRemainingShipmentQuantity(): number {
    const poId = Number(this.shipment.poId);
    if (!poId) return 0;
    const po = this.purchaseOrders.find((p: any) => p.id === poId);
    if (!po) return 0;
    const poQty = po.quantity || 0;
    const prevShipped = (this.shipments || [])
      .filter((s: any) => s.poId === poId && s.id !== this.currentEditId)
      .reduce((sum: number, s: any) => sum + (s.shipmentQuantity || 0), 0);
    return Math.max(0, poQty - prevShipped);
  }

  isShipmentQtyInvalid(): boolean {
    const qty = Number(this.shipment.shipmentQuantity || 0);
    if (qty <= 0) return false;
    const remaining = this.getRemainingShipmentQuantity();
    return qty > remaining;
  }

  save() {
    this.errorMessage = null;

    if (this.userRole === 'SUPPLIER' && this.currentSupplierId) {
      this.shipment.supplierId = Number(this.currentSupplierId);
    }

    if ((!this.shipment.supplierId || this.shipment.supplierId === 0) && this.shipment.poId) {
      const selectedPo = this.purchaseOrders.find(po => po.id === Number(this.shipment.poId));
      if (selectedPo) {
        const sId = selectedPo.supplierId || (selectedPo.supplier ? selectedPo.supplier.id : null);
        if (sId) {
          this.shipment.supplierId = Number(sId);
        }
      }
    }

    this.shipment.poId = Number(this.shipment.poId);
    this.shipment.supplierId = Number(this.shipment.supplierId);
    this.shipment.transportCost = Number(this.shipment.transportCost);

    if (!this.shipment.poId || this.shipment.poId === 0) {
      this.errorMessage = 'Please select a Purchase Order to link this shipment.';
      this.cdr.markForCheck();
      return;
    }

    if (this.isShipmentQtyInvalid()) {
      const maxAllowed = this.getRemainingShipmentQuantity();
      this.errorMessage = `Shipment quantity cannot exceed remaining PO quantity (Max: ${maxAllowed} Units).`;
      this.cdr.markForCheck();
      return;
    }

    if (!this.shipment.supplierId || this.shipment.supplierId === 0) {
      this.errorMessage = 'Validation Error: Dispatch Supplier Node reference is required.';
      this.cdr.markForCheck();
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.shipment, this.selectedFile).subscribe({
        next: () => {
          alert('Shipment logistics registry updated successfully.');
          this.closeDrawer();
          this.loadShipments();
        },
        error: (err: any) => {
          console.error('Update error:', err);
          this.errorMessage = err.error?.message || err.message || 'Modification matrix deployment failure.';
          this.cdr.markForCheck();
        },
      });
    } else {
      this.service.save(this.shipment, this.selectedFile).subscribe({
        next: () => {
          alert('New Cargo Dispatch Node authorized and registered.');
          this.closeDrawer();
          this.loadShipments();
        },
        error: (err: any) => {
          console.error('Save error:', err);
          this.errorMessage = err.error?.message || err.message || 'Logistics initialization exception.';
          this.cdr.markForCheck();
        },
      });
    }
  }

  edit(o: ShipmentResponseModel) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;
    this.shipment = {
      poId: o.poId,
      supplierId: o.supplierId,
      vehicleNumber: o.vehicleNumber,
      captainRegistrationNumber: o.captainRegistrationNumber,
      assignedByEmail: o.assignedByEmail,
      origin: o.origin,
      sendByAddress: o.sendByAddress,
      estimatedDelivery: o.estimatedDelivery,
      transportCost: o.transportCost,
      shipmentQuantity: o.shipmentQuantity,
      podFileUrl: o.podFileUrl || '',
    };
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm('Definitively remove this cargo shipment track node from core databases?')) {
      this.service.delete(id).subscribe({
        next: () => {
          alert('Shipment record successfully pruned.');
          this.loadShipments();
        },
        error: (err: any) => alert(err.error?.message || err.message),
      });
    }
  }

  openPdfModal(s: ShipmentResponseModel) {
    this.selectedShipmentForPdf = s;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedShipmentForPdf = null;
    this.cdr.markForCheck();
  }

  downloadPdfFromModal() {
    if (!this.selectedShipmentForPdf) return;

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

      pdf.save(`Shipment-${this.selectedShipmentForPdf?.shipmentNumber}.pdf`);
      this.closePdfModal();
    });
  }

  reset() {
    this.shipment = {
      poId: 0,
      supplierId: (this.userRole === 'SUPPLIER' && this.currentSupplierId) ? Number(this.currentSupplierId) : 0,
      vehicleNumber: '',
      captainRegistrationNumber: '',
      assignedByEmail: this.currentUserEmail,
      origin: '',
      sendByAddress: '',
      estimatedDelivery: '',
      transportCost: 0,
      shipmentQuantity: 0,
      podFileUrl: '',
    };
    this.selectedFile = null;
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }
}