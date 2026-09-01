import { ChangeDetectorRef, Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

import { CustomerService } from '../../../service/customer.service';
import { CustomerOrderRequestModel, CustomerOrderResponseModel, OrderLineItemRequestModel } from '../../shared/model/customerOrder';
import { CustomerOrderService } from '../../../service/customer-order.service';
import { AddProductService } from '../../../service/add-product.service';
import { StorageService } from '../../../auth/auth_service/storage.service';
import { environment } from '../../../../environment/environment';


@Component({
  selector: 'app-customer-order',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './customer-order.component.html',
  styleUrl: './customer-order.component.css',
})
export class CustomerOrderComponent implements OnInit {

  readonly imageBaseUrl = environment.imgUrl + 'customer_orders/';

  orders: CustomerOrderResponseModel[] = [];
  customers: any[] = [];
  products: any[] = [];

  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  userRole: string = '';
  loggedInCustomerName: string = '';

  @ViewChild('orderPdfContainer') orderPdfContainer!: ElementRef;
  isPdfModalOpen = false;
  selectedOrderForPdf: CustomerOrderResponseModel | null = null;

  // Status Update Modal States
  isStatusModalOpen = false;
  selectedOrderForStatus: CustomerOrderResponseModel | null = null;
  newOrderStatus: string = 'PENDING';
  availableStatuses: string[] = [
    'PENDING',
    'CONFIRMED',
    'PROCESSING',
    'SHIPPED',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
    'CANCELLED',
    'RETURNED',
    'REFUNDED'
  ];

  currentProduct: any = null;
  currentQuantity: number = 1;
  currentRemarks: string = '';
  selectedImage: File | null = null;
  imagePreview: string | null = null;

  order: CustomerOrderRequestModel = {
    customerId: 0,
    deliveryAddress: '',
    deliveryPhone: '',
    estimatedDelivery: '',
    serviceType: 'STANDARD',
    priority: 'NORMAL',
    currency: 'BDT',
    codAmount: 0,
    paymentMethod: 'CASH',
    customerAccountNumber: '',
    status: 'PENDING',
    remarks: '',
    items: []
  };

  constructor(
    private service: CustomerOrderService,
    private customerService: CustomerService,
    private productService: AddProductService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    const user = this.storage.getUser();
    if (user) {
      this.userRole = (this.storage.getActiveRole() || user.role || '').toUpperCase();
      if (this.userRole === 'CUSTOMER') {
        this.loggedInCustomerName = user.name;
        this.loadCustomerByUserId(user.userId);
      }
    }

    this.loadOrders();
    // this.loadCustomers();
    this.loadProducts();

    setTimeout(() => {
      const savedItem = localStorage.getItem('pending_order_item');
      if (savedItem) {
        try {
          const itemData = JSON.parse(savedItem);
          const exists = this.order.items.find(x => x.productId === itemData.productId);
          if (!exists) {
            this.order.items.push({
              productId: itemData.productId,
              quantity: itemData.quantity,
              remarks: itemData.remarks
            });
          }
          this.isDrawerOpen = true;
          this.cdr.markForCheck();
          localStorage.removeItem('pending_order_item');
        } catch (e) {
          console.error("Error parsing pending order item", e);
        }
      }
    }, 500);
  }

  loadCustomerByUserId(userId: number) {
    this.customerService.getCustomerByUserId(userId).subscribe({
      next: (cust) => {
        if (cust && cust.id) {
          this.order.customerId = cust.id;
          this.loggedInCustomerName = `${cust.name} (${cust.email || ''})`;
          this.cdr.markForCheck();
        }
      },
      error: () => {
        this.order.customerId = userId;
        this.cdr.markForCheck();
      }
    });
  }

  // Live Calculation Helpers
  calculateItemSubtotal(): number {
    let subtotal = 0;
    for (let item of this.order.items) {
      const p = this.products.find(prod => prod.id == item.productId);
      if (p && p.sellingPrice) {
        subtotal += p.sellingPrice * item.quantity;
      }
    }
    return subtotal;
  }

  calculateTotalWeight(): number {
    let totalWeight = 0;
    for (let item of this.order.items) {
      const p = this.products.find(prod => prod.id == item.productId);
      if (p && p.weight) {
        totalWeight += p.weight * item.quantity;
      }
    }
    return totalWeight;
  }

  calculateDeliveryCharge(): number {
    const weight = this.calculateTotalWeight();
    let baseCharge = 60 + (weight * 15);
    if (this.order.serviceType === 'EXPRESS') baseCharge *= 1.5;
    if (this.order.serviceType === 'OVERNIGHT') baseCharge *= 2.0;
    if (this.order.serviceType === 'SAME_DAY') baseCharge *= 2.5;
    return Math.round(baseCharge);
  }

  calculateTotalAmount(): number {
    return this.calculateItemSubtotal() + this.calculateDeliveryCharge();
  }

  calculateDueAmount(): number {
    const total = this.calculateTotalAmount();
    const paid = Number(this.order.codAmount) || 0;
    const due = total - paid;
    return due < 0 ? 0 : due;
  }

  openStatusModal(o: CustomerOrderResponseModel) {
    this.selectedOrderForStatus = o;
    this.newOrderStatus = o.status || 'PENDING';
    this.isStatusModalOpen = true;
    this.cdr.markForCheck();
  }

  closeStatusModal() {
    this.isStatusModalOpen = false;
    this.selectedOrderForStatus = null;
    this.cdr.markForCheck();
  }

  updateOrderStatus() {
    if (!this.selectedOrderForStatus) return;

    this.service.updateStatus(this.selectedOrderForStatus.id, this.newOrderStatus).subscribe({
      next: () => {
        alert("🚀 Order lifecycle status updated successfully!");
        this.closeStatusModal();
        this.loadOrders();
      },
      error: (err: any) => {
        alert(err.error?.message || "Failed to update status.");
      }
    });
  }

  openPdfModal(o: CustomerOrderResponseModel) {
    this.selectedOrderForPdf = o;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedOrderForPdf = null;
    this.cdr.markForCheck();
  }

  downloadOrderPdf() {
    const element = this.orderPdfContainer.nativeElement;
    html2canvas(element, {
      scale: 2,
      useCORS: true,
      windowHeight: element.scrollHeight
    }).then((canvas: HTMLCanvasElement) => {
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

      pdf.save(`Customer-Order-${this.selectedOrderForPdf?.orderNumber || 'Invoice'}.pdf`);
    });
  }

  openDrawer() {
    this.reset();
    this.isEdit = false;
    this.isDrawerOpen = true;

    if (this.userRole === 'CUSTOMER') {
      const user = this.storage.getUser();
      if (user) {
        this.loadCustomerByUserId(user.userId);
      }
    }

    this.cdr.markForCheck();
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.reset();
    this.cdr.markForCheck();
  }

  // Role-based filtered orders:
  // MANAGER এবং LOGISTICS_OFFICER PENDING orders দেখতে পাবে না
  get filteredOrders(): CustomerOrderResponseModel[] {
    const restrictedRoles = ['MANAGER', 'LOGISTICS_OFFICER'];
    if (restrictedRoles.includes(this.userRole)) {
      return this.orders.filter(o => o.status !== 'PENDING');
    }
    return this.orders;
  }

  loadOrders() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.orders = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  // loadCustomers() {
  //   this.customerService.getAll().subscribe({
  //     next: (data) => {
  //       this.customers = data || [];
  //       this.cdr.markForCheck();
  //     }
  //   });
  // }

  loadProducts() {
    this.productService.findAll().subscribe({
      next: (data) => {
        this.products = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  addItem() {
    if (!this.currentProduct) {
      alert("Please select an operational product template node!");
      return;
    }
    if (this.currentQuantity <= 0) {
      alert("Quantity configuration metrics must be positive!");
      return;
    }

    let selectedProd = this.currentProduct;
    if (typeof this.currentProduct === 'string') {
      selectedProd = this.products.find(p => `${p.name} (৳${p.sellingPrice})` === this.currentProduct);
    }

    if (!selectedProd || !selectedProd.id) {
      alert("Please select a valid product from the list!");
      return;
    }

    const existingItem = this.order.items.find(x => x.productId == selectedProd.id);
    if (existingItem) {
      existingItem.quantity += +this.currentQuantity;
    } else {
      const newItem: OrderLineItemRequestModel = {
        productId: selectedProd.id,
        quantity: +this.currentQuantity,
        remarks: this.currentRemarks
      };
      this.order.items.push(newItem);
    }

    this.currentProduct = null;
    this.currentQuantity = 1;
    this.currentRemarks = '';
    this.cdr.markForCheck();
  }

  removeItem(index: number) {
    this.order.items.splice(index, 1);
    this.cdr.markForCheck();
  }

  getProductName(productId: number): string {
    return this.products.find(p => p.id == productId)?.name || 'Unknown Item';
  }

  private handleBackendError(err: any) {
    this.errorMessage = err.error?.message || err.message || 'An unmapped transactional mutation dropped.';
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null;

    if (this.order.customerId === 0) {
      this.errorMessage = 'Validation Fault: Associate a target customer profile token context.';
      return;
    }

    if (!this.order.deliveryPhone || this.order.deliveryPhone.trim() === '') {
      this.errorMessage = 'Validation Fault: Delivery contact number is required.';
      return;
    }

    if (this.order.items.length === 0) {
      this.errorMessage = 'Validation Fault: Target allocation package requires at least one product row.';
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.order, this.selectedImage || undefined).subscribe({
        next: () => {
          alert("Customer purchase ledger instance mutated successfully!");
          this.closeDrawer();
          this.loadOrders();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.order, this.selectedImage || undefined).subscribe({
        next: () => {
          alert("New customer purchase order dispatched and authorized!");
          this.closeDrawer();
          this.loadOrders();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  edit(o: CustomerOrderResponseModel) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;

    this.order = {
      customerId: o.customerId,
      deliveryAddress: o.deliveryAddress,
      deliveryPhone: o.deliveryPhone || '',
      estimatedDelivery: o.estimatedDelivery,
      serviceType: o.serviceType,
      priority: o.priority || 'NORMAL',
      currency: o.currency || 'BDT',
      codAmount: Number(o.codAmount) || 0,
      paymentMethod: o.paymentMethod || 'CASH',
      customerAccountNumber: o.customerAccountNumber || '',
      status: o.status,
      remarks: o.remarks || '',
      items: o.lineItems.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        remarks: item.remarks || ''
      }))
    };
    
    if (o.paymentCheckImage) {
      this.imagePreview = this.imageBaseUrl + o.paymentCheckImage;
    } else {
      this.imagePreview = null;
    }
    this.selectedImage = null;

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Definitively remove this purchase order sequence from active cluster tables?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Order instance completely wiped.");
          this.loadOrders();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  reset() {
    this.order = {
      customerId: 0,
      deliveryAddress: '',
      deliveryPhone: '',
      estimatedDelivery: '',
      serviceType: 'STANDARD',
      priority: 'NORMAL',
      currency: 'BDT',
      codAmount: 0,
      paymentMethod: 'CASH',
      customerAccountNumber: '',
      status: 'PENDING',
      remarks: '',
      items: []
    };

    if (this.userRole === 'CUSTOMER') {
      const user = this.storage.getUser();
      if (user) {
        this.loadCustomerByUserId(user.userId);
      }
    }

    this.selectedImage = null;
    this.imagePreview = null;
    this.currentProduct = null;
    this.currentQuantity = 1;
    this.currentRemarks = '';
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }

  onImageSelected(event: any): void {
    const fileList: FileList = event.target.files;
    if (fileList.length > 0) {
      this.selectedImage = fileList[0];
      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.imagePreview = e.target.result;
      };
      reader.readAsDataURL(this.selectedImage);
    } else {
      this.selectedImage = null;
      this.imagePreview = null;
    }
  }
}