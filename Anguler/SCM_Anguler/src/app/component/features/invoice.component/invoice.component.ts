import { ChangeDetectorRef, Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { InvoiceRequestModel, InvoiceResponseModel } from '../../shared/model/invoiceModel';
import { InvoiceService } from '../../../service/invoice.service';
import { CustomerOrderService } from '../../../service/customer-order.service';
import { StorageService } from '../../../auth/auth_service/storage.service'; // 🌟 স্টোরেজ সার্ভিস ইমপোর্ট

import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

@Component({
  selector: 'app-invoice',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './invoice.component.html',
  styleUrl: './invoice.component.css'
})
export class InvoiceComponent implements OnInit {

  invoices: InvoiceResponseModel[] = [];
  orders: any[] = []; 
  
  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  userRole: string = ''; 

  isPdfModalOpen = false;
  selectedInvoiceForPdf: InvoiceResponseModel | null = null;
  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;

  formModel: InvoiceRequestModel = {
    customerOrderId: null,
    salesOfficerId: null,
    subtotal: 0,
    taxRate: 0,
    discountAmount: 0,
    discountPercentage: 0,
    shippingFees: 0,
    paidAmount: 0,
    paymentMethod: 'CASH',
    transactionReference: '',
    invoiceStatus: 'DRAFT',
    deliveryDate: '',
    deliveryAddress: '',
    notes: '',
    cancelledReason: ''
  };

  constructor(
    private service: InvoiceService,
    private orderService: CustomerOrderService,
    private storage: StorageService, 
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    const user = this.storage.getUser();
    if (user) {
      this.userRole = user.role;
    }

    this.loadInvoices();
    this.loadCustomerOrders();
  }

  loadInvoices() {
    this.service.findAll().subscribe({
      next: (data) => { this.invoices = data || []; this.cdr.markForCheck(); },
      error: (err) => this.handleErrorLog(err)
    });
  }

  loadCustomerOrders() {
    this.orderService.findAll().subscribe({ next: (data) => this.orders = data || [] });
  }

  onCustomerOrderChange(selectedOrderId: any) {
    if (!selectedOrderId) return;
    const selectedOrder = this.orders.find(o => o.id == selectedOrderId);
    if (selectedOrder) {
      // Auto-fill Financial Subtotal field with order total cost
      this.formModel.subtotal = Number(selectedOrder.totalAmount || selectedOrder.itemSubtotal) || 0;

      // Auto-fill shipping fees if available
      if (selectedOrder.deliveryCharge !== undefined && selectedOrder.deliveryCharge !== null) {
        this.formModel.shippingFees = Number(selectedOrder.deliveryCharge) || 0;
      }

      // Auto-fill delivery address if available
      if (selectedOrder.deliveryAddress && (!this.formModel.deliveryAddress || this.formModel.deliveryAddress.trim() === '')) {
        this.formModel.deliveryAddress = selectedOrder.deliveryAddress;
      }

      // Auto-fill payment method if available
      if (selectedOrder.paymentMethod) {
        this.formModel.paymentMethod = selectedOrder.paymentMethod;
      }

      // Auto-fill paid amount if available
      if (selectedOrder.codAmount !== undefined || selectedOrder.paidAmount !== undefined) {
        this.formModel.paidAmount = Number(selectedOrder.codAmount || selectedOrder.paidAmount) || 0;
      }

      this.onSubtotalChange();
      this.cdr.markForCheck();
    }
  }

  onSubtotalChange() {
    if (this.formModel.discountPercentage && Number(this.formModel.discountPercentage) > 0) {
      this.onDiscountPctChange();
    }
  }

  onDiscountPctChange() {
    const subtotal = Number(this.formModel.subtotal) || 0;
    const pct = Number(this.formModel.discountPercentage) || 0;
    if (subtotal > 0 && pct >= 0) {
      this.formModel.discountAmount = Number(((subtotal * pct) / 100).toFixed(2));
    } else {
      this.formModel.discountAmount = 0;
    }
    this.cdr.markForCheck();
  }

  onDiscountFlatChange() {
    const subtotal = Number(this.formModel.subtotal) || 0;
    const flat = Number(this.formModel.discountAmount) || 0;
    if (subtotal > 0 && flat >= 0) {
      this.formModel.discountPercentage = Number(((flat / subtotal) * 100).toFixed(2));
    } else {
      this.formModel.discountPercentage = 0;
    }
    this.cdr.markForCheck();
  }

  openDrawer() { this.resetForm(); this.isEdit = false; this.isDrawerOpen = true; this.cdr.markForCheck(); }
  closeDrawer() { this.isDrawerOpen = false; this.resetForm(); this.cdr.markForCheck(); }

  submitInvoice() {
    this.errorMessage = null;

    if (!this.formModel.customerOrderId || +this.formModel.customerOrderId === 0) {
      this.errorMessage = "Validation Fault: Customer Order Linkage identifier is required.";
      this.cdr.markForCheck();
      return;
    }

    if (!this.formModel.deliveryAddress || this.formModel.deliveryAddress.trim() === '') {
      this.errorMessage = "Validation Fault: Structural Delivery Address map is required.";
      this.cdr.markForCheck();
      return;
    }

    const payload: InvoiceRequestModel = {
      customerOrderId: +this.formModel.customerOrderId,
      salesOfficerId: this.formModel.salesOfficerId ? +this.formModel.salesOfficerId : null,
      subtotal: +this.formModel.subtotal,
      taxRate: +this.formModel.taxRate,
      discountAmount: +this.formModel.discountAmount,
      discountPercentage: +this.formModel.discountPercentage,
      shippingFees: +this.formModel.shippingFees,
      paidAmount: +this.formModel.paidAmount,
      paymentMethod: this.formModel.paymentMethod || null,
      transactionReference: this.formModel.transactionReference?.trim() || null,
      invoiceStatus: this.formModel.invoiceStatus,
      deliveryDate: this.formModel.deliveryDate || null,
      deliveryAddress: this.formModel.deliveryAddress.trim(),
      notes: this.formModel.notes?.trim() || null,
      cancelledReason: this.formModel.invoiceStatus === 'CANCELLED' ? this.formModel.cancelledReason?.trim() : null
    };

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, payload).subscribe({
        next: () => { alert("Invoice record matrix updated successfully."); this.closeDrawer(); this.loadInvoices(); },
        error: (err) => this.handleErrorLog(err)
      });
    } else {
      this.service.create(payload).subscribe({
        next: () => { alert("New commercial invoice ledger localized inside the datastore."); this.closeDrawer(); this.loadInvoices(); },
        error: (err) => this.handleErrorLog(err)
      });
    }
  }

  edit(i: InvoiceResponseModel) {
    this.errorMessage = null;
    this.currentEditId = i.id;
    this.isEdit = true;
    this.formModel = {
      customerOrderId: i.customerOrderId,
      salesOfficerId: i.salesOfficerId,
      subtotal: i.subtotal,
      taxRate: i.taxRate,
      discountAmount: i.discountAmount,
      discountPercentage: i.discountPercentage,
      shippingFees: i.shippingFees,
      paidAmount: i.paidAmount,
      paymentMethod: i.paymentMethod,
      transactionReference: i.transactionReference,
      invoiceStatus: i.invoiceStatus,
      deliveryDate: i.deliveryDate,
      deliveryAddress: i.deliveryAddress,
      notes: i.notes,
      cancelledReason: i.cancelledReason
    };
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  openPdfModal(inv: InvoiceResponseModel) {
    this.selectedInvoiceForPdf = inv;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedInvoiceForPdf = null;
    this.cdr.markForCheck();
  }

  downloadPdfFromModal() {
    if (!this.selectedInvoiceForPdf) return;

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

      pdf.save(`Invoice-${this.selectedInvoiceForPdf?.invoiceNumber || this.selectedInvoiceForPdf?.id}.pdf`);
      this.closePdfModal();
    });
  }

  deleteInvoice(id: number) {
    if (confirm("Are you sure you want to drop this invoice dataset node? This action is irreversible.")) {
      this.service.delete(id).subscribe({
        next: () => { alert("Invoice lifecycle terminated successfully."); this.loadInvoices(); },
        error: (err) => alert(err.error?.message || err.message)
      });
    }
  }

  private handleErrorLog(err: any) {
    console.error("SCM Invoice Exception Stack:", err);
    this.errorMessage = err.error?.message || err.message || "400 Bad Request: Financial calculation exception.";
    this.cdr.markForCheck();
  }

  resetForm() {
    this.formModel = {
      customerOrderId: null,
      salesOfficerId: null,
      subtotal: 0,
      taxRate: 0,
      discountAmount: 0,
      discountPercentage: 0,
      shippingFees: 0,
      paidAmount: 0,
      paymentMethod: 'CASH',
      transactionReference: '',
      invoiceStatus: 'DRAFT',
      deliveryDate: '',
      deliveryAddress: '',
      notes: '',
      cancelledReason: ''
    };
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }
}