import { ChangeDetectorRef, Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { PaymentStatementService } from '../../../service/payment-statement.service';
import { CustomerOrderService } from '../../../service/customer-order.service';
import { PaymentStatementResponse, PaymentStatementRequest } from '../../shared/model/PaymentStatementModel';
import { CustomerOrderResponseModel } from '../../shared/model/customerOrder';
import { StorageService } from '../../../auth/auth_service/storage.service';
import { environment } from '../../../../environment/environment';

@Component({
  selector: 'app-payment-statement',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './payment-statement.component.html',
  styleUrl: './payment-statement.component.css'
})
export class PaymentStatementComponent implements OnInit {
  orders: CustomerOrderResponseModel[] = [];
  selectedOrderId: number | string | null = 'ALL';
  allPayments: PaymentStatementResponse[] = [];
  payments: PaymentStatementResponse[] = [];
  searchText: string = '';
  
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;
  errorMessage: string | null = null;
  userRole: string = '';
  activeRole: string = '';
  isStatusModalOpen = false;
  selectedPaymentForStatus: PaymentStatementResponse | null = null;
  newIssueStatus: string = 'PENDING_VERIFICATION';
  availableStatuses: string[] = ['PENDING_VERIFICATION', 'CONFIRMED_BY_OFFICER', 'FAILED_OR_REJECTED'];
  
  isImageModalOpen = false;
  selectedPaymentForImage: PaymentStatementResponse | null = null;

  @ViewChild('fileInput') fileInput!: ElementRef;
  selectedFile: File | null = null;

  payment: PaymentStatementRequest = {
    customerOrderId: 0,
    paidAmount: 0,
    paymentMethod: 'CASH'
  };

  constructor(
    private service: PaymentStatementService,
    private orderService: CustomerOrderService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (user) {
      this.userRole = user.role;
    }
    this.loadOrders();
  }

  get filteredPayments(): PaymentStatementResponse[] {
    let list = this.payments || [];
    if (this.searchText && this.searchText.trim() !== '') {
      const q = this.searchText.toLowerCase().trim();
      list = list.filter(p => {
        const idStr = p.id ? String(p.id) : '';
        const txnIdStr = p.transactionId ? String(p.transactionId) : '';
        const amountStr = p.paidAmount ? String(p.paidAmount) : '';
        const methodStr = p.paymentMethod ? String(p.paymentMethod) : '';
        const statusStr = p.issueStatus ? String(p.issueStatus) : '';
        const dateStr = p.createdAt ? String(p.createdAt) : '';
        return idStr.toLowerCase().includes(q) ||
               txnIdStr.toLowerCase().includes(q) ||
               amountStr.toLowerCase().includes(q) ||
               methodStr.toLowerCase().includes(q) ||
               statusStr.toLowerCase().includes(q) ||
               dateStr.toLowerCase().includes(q);
      });
    }
    return list;
  }

  loadOrders() {
    this.orderService.findAll().subscribe({
      next: (data) => {
        this.orders = data || [];
        this.loadAllPayments();
      }
    });
  }

  loadAllPayments() {
    if (!this.orders || this.orders.length === 0) {
      this.payments = [];
      this.allPayments = [];
      this.cdr.markForCheck();
      return;
    }
    const requests = this.orders.map(o => 
      this.service.getPaymentsByOrderId(o.id).pipe(
        catchError(() => of([] as PaymentStatementResponse[]))
      )
    );
    forkJoin(requests).subscribe({
      next: (resultsArray: PaymentStatementResponse[][]) => {
        const combined: PaymentStatementResponse[] = resultsArray.reduce(
          (acc: PaymentStatementResponse[], curr: PaymentStatementResponse[]) => acc.concat(curr || []),
          [] as PaymentStatementResponse[]
        );
        combined.sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime());
        this.allPayments = combined;
        if (this.selectedOrderId === 'ALL' || !this.selectedOrderId) {
          this.payments = [...this.allPayments];
        } else {
          this.loadPaymentsByOrder(Number(this.selectedOrderId));
        }
        this.cdr.markForCheck();
      },
      error: () => {
        this.payments = [];
        this.cdr.markForCheck();
      }
    });
  }

  onOrderSelect() {
    if (!this.selectedOrderId || this.selectedOrderId === 'ALL') {
      this.payments = [...this.allPayments];
    } else {
      this.loadPaymentsByOrder(Number(this.selectedOrderId));
    }
  }

  loadPaymentsByOrder(orderId: number) {
    this.service.getPaymentsByOrderId(orderId).subscribe({
      next: (data) => {
        this.payments = data || [];
        this.cdr.markForCheck();
      }
    });
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

  onFileChange(event: any) {
    const fileList: FileList = event.target.files;
    if (fileList.length > 0) {
      this.selectedFile = fileList[0];
    }
  }

  save() {
    this.errorMessage = null;

    if (this.payment.customerOrderId === 0) {
      this.errorMessage = "Please select a Customer Order.";
      return;
    }
    if (this.payment.paidAmount <= 0) {
      this.errorMessage = "Paid amount must be greater than zero.";
      return;
    }

    const formData = new FormData();
    // Converting the object into Blob as required by @RequestPart("payment") in Spring
    formData.append('payment', new Blob([JSON.stringify(this.payment)], { type: 'application/json' }));
    
    if (this.selectedFile) {
      formData.append('image', this.selectedFile);
    } else {
      // Backend expects 'image' part. We provide an empty blob if optional in edit, but for ADD it might be required.
      // The controller says @RequestPart("image") without required=false for ADD, so it might fail if null.
      // We'll append an empty blob if no file to avoid bad request, though user should really select a file.
      formData.append('image', new Blob([], { type: 'application/octet-stream' }), 'empty.png');
    }

    if (this.isEdit && this.currentEditId) {
      this.service.updatePayment(this.currentEditId, formData).subscribe({
        next: () => {
          alert("Payment updated successfully.");
          this.closeDrawer();
          this.loadAllPayments();
        },
        error: (err) => this.handleError(err)
      });
    } else {
      this.service.addPayment(formData).subscribe({
        next: () => {
          alert("Payment created successfully.");
          this.closeDrawer();
          this.loadAllPayments();
        },
        error: (err) => this.handleError(err)
      });
    }
  }

  edit(p: PaymentStatementResponse) {
    this.isEdit = true;
    this.currentEditId = p.id;
    this.payment = {
      customerOrderId: p.customerOrderId,
      paidAmount: p.paidAmount,
      paymentMethod: p.paymentMethod
    };
    this.selectedFile = null;
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Are you sure you want to delete this payment statement?")) {
      this.service.deletePayment(id).subscribe({
        next: () => {
          alert("Payment deleted.");
          this.loadAllPayments();
        },
        error: (err) => this.handleError(err)
      });
    }
  }

  openStatusModal(p: PaymentStatementResponse) {
    this.selectedPaymentForStatus = p;
    this.newIssueStatus = p.issueStatus;
    this.isStatusModalOpen = true;
    this.cdr.markForCheck();
  }

  closeStatusModal() {
    this.isStatusModalOpen = false;
    this.selectedPaymentForStatus = null;
    this.cdr.markForCheck();
  }

  updatePaymentStatus() {
    if (this.selectedPaymentForStatus) {
      this.service.updatePaymentStatus(this.selectedPaymentForStatus.id, this.newIssueStatus).subscribe({
        next: () => {
          alert("Payment status updated successfully.");
          this.closeStatusModal();
          this.loadAllPayments();
        },
        error: (err) => this.handleError(err)
      });
    }
  }

  viewImageCard(p: PaymentStatementResponse) {
    this.selectedPaymentForImage = p;
    this.isImageModalOpen = true;
    this.cdr.markForCheck();
  }

  closeImageModal() {
    this.isImageModalOpen = false;
    this.selectedPaymentForImage = null;
    this.cdr.markForCheck();
  }

  getImageUrl(imagePath: string | undefined): string {
    if (!imagePath) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.includes('payment/')) {
      return `${environment.imgUrl}${imagePath}`;
    }
    return `${environment.imgUrl}payment/${imagePath}`;
  }

  reset() {
    const defaultOrderId = (this.selectedOrderId && this.selectedOrderId !== 'ALL') ? Number(this.selectedOrderId) : 0;
    this.payment = {
      customerOrderId: defaultOrderId,
      paidAmount: 0,
      paymentMethod: 'CASH'
    };
    this.selectedFile = null;
    this.currentEditId = null;
    this.isEdit = false;
    this.errorMessage = null;
    if (this.fileInput && this.fileInput.nativeElement) {
      this.fileInput.nativeElement.value = "";
    }
  }

  handleError(err: any) {
    this.errorMessage = err.error?.message || err.message || "An error occurred.";
    this.cdr.markForCheck();
  }
}
