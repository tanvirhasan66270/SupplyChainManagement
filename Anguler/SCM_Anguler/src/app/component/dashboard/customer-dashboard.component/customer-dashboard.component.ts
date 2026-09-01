import { ChangeDetectorRef, Component, OnInit, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { KEYS, StorageService } from '../../../auth/auth_service/storage.service';
import { CustomerOrderService } from '../../../service/customer-order.service';
import { CustomerOrderResponseModel, CustomerOrderRequestModel, OrderLineItemRequestModel } from '../../shared/model/customerOrder';
import { LoginResponse } from '../../../auth/Model/authModel';
import { CustomerService } from '../../../service/customer.service';
import { CustomerResponseModel } from '../../shared/model/customerModel';
import { AddProductService } from '../../../service/add-product.service';
import { ProductResponseModel } from '../../shared/model/addProduct';
import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';
import { NotificationService } from '../../../system/service/notification.service';
import { NotificationModel } from '../../../system/NotificationModel';
import { InvoiceService } from '../../../service/invoice.service';
import { InvoiceResponseModel } from '../../shared/model/invoiceModel';
import { PaymentStatementService } from '../../../service/payment-statement.service';
import { PaymentStatementResponse } from '../../shared/model/PaymentStatementModel';
import { environment } from '../../../../environment/environment';

@Component({
  selector: 'app-customer-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, DashboardSettingsComponent, FormsModule],
  templateUrl: './customer-dashboard.component.html',
  styleUrls: ['./customer-dashboard.component.css'],
})
export class CustomerDashboardComponent implements OnInit, OnDestroy {
  user: LoginResponse | null = null;
  userId!: number;
  customer: CustomerResponseModel | null = null;
  customerOrders: CustomerOrderResponseModel[] = [];
  userName = '';

  stats = { total: 0, active: 0, completed: 0, pending: 0, cancelled: 0, duePayments: 0 };
  recentOrders: CustomerOrderResponseModel[] = [];
  walletBalance = 0;
  dueAmountTotal = 0;
  monthlyExpenses: number[] = [];
  monthLabels: string[] = [];
  recommendations: any[] = [];
  readonly imageBaseUrl = environment.imgUrl + "product/";
  readonly imgUrl = environment.imgUrl;

  notifications: NotificationModel[] = [];

  showSettings = false;
  loading = true;

  // Track Product Modal States
  isTrackModalOpen = false;
  searchTrackingCode = '';
  trackedResult: CustomerOrderResponseModel | null = null;
  trackSearched = false;

  // Quick Invoice Search Modal States
  isInvoiceModalOpen: boolean = false;
  searchInvoiceOrderNumber: string = '';
  invoiceSearchResult: InvoiceResponseModel | null = null;
  invoiceSearchOrder: CustomerOrderResponseModel | null = null;
  invoiceSearched: boolean = false;
  invoiceSearchLoading: boolean = false;
  invoiceSearchError: string | null = null;

  // Invoice History & Statement States
  isStatementCardOpen: boolean = false;
  searchStatementOrderId: string = ''; 
  statementData: any = null;
  statementPayments: PaymentStatementResponse[] = [];
  statementError: string | null = null;
  
  isImageModalOpen = false;
  selectedPaymentForImage: PaymentStatementResponse | null = null;

  // Add Payment Modal States
  isPaymentModalOpen = false;
  paymentSearchOrderNumber = '';
  paymentOrderDetails: CustomerOrderResponseModel | null = null;
  paymentAmount = 0;
  paymentMethod = 'CASH';
  paymentFile: File | null = null;
  paymentErrorMessage: string | null = null;

  // Place New Order Inline Form States
  showOrderFormOnly = false;
  products: any[] = [];
  currentProduct: any = null;
  currentQuantity: number = 1;
  currentRemarks: string = '';
  orderImageFile: File | null = null;
  orderImagePreview: string | null = null;

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
    status: 'PENDING',
    remarks: '',                
    items: []
  };

  deliveredPercent = 0;
  processingPercent = 0;
  cancelledPercent = 0;

  donutDelivered = '0 282';
  donutProcessing = '0 282';
  donutCancelled = '0 282';
  donutOffsetProcessing = 0;
  donutOffsetCancelled = 0;

  chartPath = '';
  chartDots: { x: number; y: number }[] = [];
  chartMaxY = 1;

  statusHierarchy: string[] = [
    'PENDING', 
    'CONFIRMED', 
    'PROCESSING', 
    'SHIPPED', 
    'OUT_FOR_DELIVERY', 
    'DELIVERED'
  ];

  constructor(
    private storage: StorageService,
    private orderService: CustomerOrderService,
    private cutomerService: CustomerService,
    private productService: AddProductService,
    private notificationService: NotificationService,
    private cdr: ChangeDetectorRef,
    private router: Router,
    private route: ActivatedRoute,
    private invoiceService: InvoiceService,
    private paymentService: PaymentStatementService
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) {
      return;
    }
    this.userName = user.name;
    this.userId = user.userId;
    this.loadCustomer();
    this.loadDashboardData();
    this.loadRecommendations();
    this.loadNotifications();

    this.route.queryParams.subscribe(params => {
      if (params['track'] === 'true') {
        setTimeout(() => {
          const btn = document.getElementById('track-product-btn');
          if (btn) {
            btn.click();
          } else {
            this.openTrackModal();
          }
        }, 150);
      }
      if (params['billing'] === 'true') {
        setTimeout(() => {
          const btn = document.getElementById('billing-ledger-btn');
          if (btn) {
            btn.click();
          } else {
            this.openBillingModal();
          }
        }, 150);
      }
    });
  }

  // Track Product Modal Methods
  openTrackModal(): void {
    this.isTrackModalOpen = true;
    this.searchTrackingCode = '';
    this.trackedResult = null;
    this.trackSearched = false;
    this.cdr.markForCheck();
  }

  closeTrackModal(): void {
    this.isTrackModalOpen = false;
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { track: null },
      queryParamsHandling: 'merge'
    });
    this.cdr.markForCheck();
  }

  isBillingModalOpen = false;
  searchBillingCode = '';
  billingSearchResult: any = null;
  billingSearched = false;

  // Billing Ledger Modal Methods
  openBillingModal(): void {
    this.isBillingModalOpen = true;
    this.searchBillingCode = '';
    this.billingSearchResult = null;
    this.billingSearched = false;
    this.cdr.markForCheck();
  }

  closeBillingModal(): void {
    this.isBillingModalOpen = false;
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { billing: null },
      queryParamsHandling: 'merge'
    });
    this.cdr.markForCheck();
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

  getPaymentImageUrl(imagePath: string | undefined): string {
    if (!imagePath) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.includes('payment/')) {
      return `${this.imgUrl}${imagePath}`;
    }
    return `${this.imgUrl}payment/${imagePath}`;
  }

  formatIssueStatus(status: string | null | undefined): string {
    if (!status) return 'Pending Verification';
    switch (status.toUpperCase()) {
      case 'CONFIRMED_BY_OFFICER':
      case 'CONFIRMED':
        return 'Confirmed by Officer';
      case 'PENDING_VERIFICATION':
      case 'PENDING':
        return 'Pending Verification';
      case 'FAILED_OR_REJECTED':
      case 'FAILED':
      case 'REJECTED':
        return 'Rejected / Failed';
      default:
        return status.replace(/_/g, ' ');
    }
  }

  getIssueStatusClass(status: string | null | undefined): string {
    if (!status) return 'bg-warning-subtle text-warning border border-warning-subtle';
    const s = status.toUpperCase();
    if (s.includes('CONFIRMED')) return 'bg-success-subtle text-success border border-success-subtle';
    if (s.includes('PENDING')) return 'bg-warning-subtle text-warning border border-warning-subtle';
    if (s.includes('FAILED') || s.includes('REJECTED')) return 'bg-danger-subtle text-danger border border-danger-subtle';
    return 'bg-secondary-subtle text-secondary border border-secondary-subtle';
  }

  openInvoiceModal(): void {
    this.isInvoiceModalOpen = true;
    this.searchInvoiceOrderNumber = '';
    this.invoiceSearchResult = null;
    this.invoiceSearchOrder = null;
    this.invoiceSearched = false;
    this.invoiceSearchLoading = false;
    this.invoiceSearchError = null;
    this.cdr.markForCheck();
  }

  closeInvoiceModal(): void {
    this.isInvoiceModalOpen = false;
    this.searchInvoiceOrderNumber = '';
    this.invoiceSearchResult = null;
    this.invoiceSearchOrder = null;
    this.invoiceSearched = false;
    this.invoiceSearchLoading = false;
    this.invoiceSearchError = null;
    this.cdr.markForCheck();
  }

  searchInvoice(): void {
    if (!this.searchInvoiceOrderNumber || this.searchInvoiceOrderNumber.trim() === '') {
      this.invoiceSearchError = 'Please enter a valid Customer Order Number or Invoice Reference Code.';
      this.invoiceSearchResult = null;
      this.invoiceSearchOrder = null;
      this.invoiceSearched = true;
      return;
    }

    const queryTerm = this.searchInvoiceOrderNumber.trim();
    this.invoiceSearched = true;
    this.invoiceSearchLoading = true;
    this.invoiceSearchError = null;
    this.invoiceSearchResult = null;
    this.invoiceSearchOrder = null;

    // First try tracking the order by orderNumber
    this.orderService.trackOrder(queryTerm).subscribe({
      next: (order) => {
        this.invoiceSearchOrder = order;
        // Fetch all invoices to match exact backend invoice entity
        this.invoiceService.findAll().subscribe({
          next: (invoices) => {
            const foundInvoice = (invoices || []).find(
              inv => (inv.invoiceNumber && inv.invoiceNumber.toLowerCase() === queryTerm.toLowerCase()) ||
                     (inv.customerOrderId && inv.customerOrderId === order.id) ||
                     (inv.invoiceNumber && inv.invoiceNumber.toLowerCase().includes(order.orderNumber.toLowerCase()))
            );

            if (foundInvoice) {
              this.invoiceSearchResult = foundInvoice;
            } else {
              // Construct dynamic invoice object from tracked order
              this.invoiceSearchResult = {
                id: order.id,
                invoiceNumber: 'INV-' + order.orderNumber,
                customerOrderId: order.id,
                customerEmail: this.customer?.email || 'customer@scm.com',
                issuedToName: order.customerName || this.userName || 'Valued Customer',
                currency: order.currency || 'BDT',
                subtotal: order.itemSubtotal || order.totalAmount,
                taxRate: 0,
                taxAmount: 0,
                discountAmount: 0,
                discountPercentage: 0,
                shippingFees: order.deliveryCharge || 0,
                totalAmount: order.totalAmount,
                paidAmount: order.paymentStatus === 'PAID' ? order.totalAmount : (order.codAmount || 0),
                dueAmount: Number(order.dueAmount || 0),
                paymentStatus: order.paymentStatus || 'UNPAID',
                paymentMethod: order.paymentMethod || 'CASH',
                invoiceStatus: 'ISSUED',
                deliveryDate: order.estimatedDelivery || null,
                deliveryAddress: order.deliveryAddress || 'Standard Shipping Address',
                createdAt: order.createdAt || new Date().toISOString(),
                updatedAt: order.createdAt || new Date().toISOString()
              };
            }
            this.invoiceSearchLoading = false;
            this.cdr.markForCheck();
          },
          error: () => {
            this.invoiceSearchResult = {
              id: order.id,
              invoiceNumber: 'INV-' + order.orderNumber,
              customerOrderId: order.id,
              customerEmail: this.customer?.email || 'customer@scm.com',
              issuedToName: order.customerName || this.userName || 'Valued Customer',
              currency: order.currency || 'BDT',
              subtotal: order.itemSubtotal || order.totalAmount,
              taxRate: 0,
              taxAmount: 0,
              discountAmount: 0,
              discountPercentage: 0,
              shippingFees: order.deliveryCharge || 0,
              totalAmount: order.totalAmount,
              paidAmount: order.paymentStatus === 'PAID' ? order.totalAmount : (order.codAmount || 0),
              dueAmount: Number(order.dueAmount || 0),
              paymentStatus: order.paymentStatus || 'UNPAID',
              paymentMethod: order.paymentMethod || 'CASH',
              invoiceStatus: 'ISSUED',
              deliveryDate: order.estimatedDelivery || null,
              deliveryAddress: order.deliveryAddress || 'Standard Shipping Address',
              createdAt: order.createdAt || new Date().toISOString(),
              updatedAt: order.createdAt || new Date().toISOString()
            };
            this.invoiceSearchLoading = false;
            this.cdr.markForCheck();
          }
        });
      },
      error: () => {
        // Fallback: search invoices directly by queryTerm
        this.invoiceService.findAll().subscribe({
          next: (invoices) => {
            const foundInvoice = (invoices || []).find(
              inv => (inv.invoiceNumber && inv.invoiceNumber.toLowerCase().includes(queryTerm.toLowerCase()))
            );
            if (foundInvoice) {
              this.invoiceSearchResult = foundInvoice;
            } else {
              this.invoiceSearchError = 'No invoice records found matching Order Number #' + queryTerm;
            }
            this.invoiceSearchLoading = false;
            this.cdr.markForCheck();
          },
          error: () => {
            this.invoiceSearchError = 'No invoice records found matching Order Number #' + queryTerm;
            this.invoiceSearchLoading = false;
            this.cdr.markForCheck();
          }
        });
      }
    });
  }

  downloadInvoiceWord(): void {
    if (!this.invoiceSearchResult) return;
    const inv = this.invoiceSearchResult;
    const orderNo = this.invoiceSearchOrder?.orderNumber || (inv.invoiceNumber ? inv.invoiceNumber.replace('INV-', '') : 'ORDER');
    const invoiceNo = inv.invoiceNumber || ('INV-' + orderNo);
    const customerName = inv.issuedToName || this.userName || 'Customer';
    const currency = inv.currency || 'BDT';
    const totalAmount = inv.totalAmount || 0;
    const paidAmount = Number(inv.paidAmount || 0);
    const dueAmount = Number(inv.dueAmount || 0);

    let itemRows = '';
    if (this.invoiceSearchOrder && this.invoiceSearchOrder.lineItems && this.invoiceSearchOrder.lineItems.length > 0) {
      this.invoiceSearchOrder.lineItems.forEach((item: any, index: number) => {
        const prodName = item.productName || this.getProductName(item.productId);
        const qty = item.quantity || 1;
        const price = item.unitPrice || 0;
        const lineTotal = item.lineTotal || (qty * price);
        const bgRow = index % 2 === 1 ? 'background-color: #f8fafc;' : 'background-color: #ffffff;';
        itemRows += `
          <tr style="${bgRow}">
            <td style="text-align: center; border: 1px solid #cbd5e1; padding: 7px;">${index + 1}</td>
            <td style="border: 1px solid #cbd5e1; padding: 7px; font-weight: bold;">${prodName}</td>
            <td style="text-align: center; border: 1px solid #cbd5e1; padding: 7px;">${qty}</td>
            <td style="text-align: right; border: 1px solid #cbd5e1; padding: 7px; font-family: monospace;">৳${price.toFixed(2)}</td>
            <td style="text-align: right; border: 1px solid #cbd5e1; padding: 7px; font-weight: bold; color: #1e3a8a; font-family: monospace;">৳${lineTotal.toFixed(2)}</td>
          </tr>
        `;
      });
    } else {
      itemRows = `
        <tr>
          <td colspan="5" style="text-align: center; border: 1px solid #cbd5e1; padding: 10px; color: #64748b;">Consignment Package Items</td>
        </tr>
      `;
    }

    const wordTemplate = `
      <html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
      <head>
        <meta charset='utf-8'>
        <title>Official Invoice - ${invoiceNo}</title>
        <!--[if gte mso 9]>
        <xml>
          <w:WordDocument>
            <w:View>Print</w:View>
            <w:Zoom>100</w:Zoom>
            <w:DoNotOptimizeForBrowser/>
          </w:WordDocument>
        </xml>
        <![endif]-->
        <style>
          @page { size: A4 portrait; margin: 0.5in 0.5in 0.5in 0.5in; }
          body { font-family: 'Segoe UI', Arial, sans-serif; color: #0f172a; margin: 0; padding: 0; background-color: #ffffff; }
          table { border-collapse: collapse; width: 100%; }
          .title-banner { background-color: #2563eb; color: #ffffff; padding: 14px 18px; font-size: 18pt; font-weight: bold; text-align: left; }
          .subtitle { color: #bfdbfe; font-size: 9.5pt; font-weight: normal; margin-top: 3px; }
          .section-bar { background-color: #1e3a8a; color: #ffffff; font-size: 10.5pt; font-weight: bold; padding: 6px 12px; letter-spacing: 0.5px; }
          .meta-td { padding: 7px 10px; border: 1px solid #cbd5e1; font-size: 9.5pt; }
          .meta-label { background-color: #f1f5f9; font-weight: bold; color: #475569; width: 22%; }
          .data-th { background-color: #0f172a; color: #ffffff; font-weight: bold; font-size: 9.5pt; padding: 8px 10px; border: 1px solid #0f172a; text-align: left; }
          .data-td { padding: 7px 10px; font-size: 9.5pt; border: 1px solid #e2e8f0; vertical-align: middle; }
          .summary-td { padding: 7px 10px; font-size: 9.5pt; border: 1px solid #e2e8f0; }
        </style>
      </head>
      <body>
        <table width="100%" style="margin-bottom: 12px;">
          <tr>
            <td class="title-banner">
              OFFICIAL INVOICE
              <div class="subtitle">Supply Chain Management Sales &amp; Billing Settlement</div>
            </td>
          </tr>
        </table>

        <table width="100%" style="margin-bottom: 16px;">
          <tr>
            <td class="meta-td meta-label">Invoice Number:</td>
            <td class="meta-td" style="font-weight: bold; color: #2563eb; font-family: monospace;">${invoiceNo}</td>
            <td class="meta-td meta-label">Customer Order No:</td>
            <td class="meta-td" style="font-weight: bold; font-family: monospace;">${orderNo}</td>
          </tr>
          <tr>
            <td class="meta-td meta-label">Billed To Customer:</td>
            <td class="meta-td" style="font-weight: bold;">${customerName}</td>
            <td class="meta-td meta-label">Customer Email:</td>
            <td class="meta-td">${inv.customerEmail || 'N/A'}</td>
          </tr>
          <tr>
            <td class="meta-td meta-label">Invoice Issued Date:</td>
            <td class="meta-td">${inv.issuedAt ? new Date(inv.issuedAt).toLocaleString() : new Date(inv.createdAt).toLocaleString()}</td>
            <td class="meta-td meta-label">Payment Status:</td>
            <td class="meta-td" style="font-weight: bold; color: #16a34a;">${inv.paymentStatus || 'UNPAID'}</td>
          </tr>
          <tr>
            <td class="meta-td meta-label">Delivery Address:</td>
            <td class="meta-td" colspan="3">${inv.deliveryAddress || 'N/A'}</td>
          </tr>
        </table>

        <table width="100%" style="margin-bottom: 4px;">
          <tr>
            <td class="section-bar">ITEMIZED PRODUCTS BREAKDOWN</td>
          </tr>
        </table>

        <table width="100%" class="data-table" style="margin-bottom: 16px;">
          <thead>
            <tr>
              <th class="data-th" style="text-align: center; width: 6%;">SL</th>
              <th class="data-th" style="width: 44%;">Product Description</th>
              <th class="data-th" style="width: 12%; text-align: center;">Qty</th>
              <th class="data-th" style="width: 18%; text-align: right;">Unit Price</th>
              <th class="data-th" style="width: 20%; text-align: right;">Line Total</th>
            </tr>
          </thead>
          <tbody>
            ${itemRows}
          </tbody>
        </table>

        <table width="100%" style="margin-bottom: 4px;">
          <tr>
            <td class="section-bar">FINANCIAL BILLING SUMMARY</td>
          </tr>
        </table>

        <table width="100%" style="margin-bottom: 16px;">
          <tr>
            <td class="summary-td meta-label">Subtotal Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; font-family: monospace;">৳${Number(inv.subtotal || totalAmount).toFixed(2)}</td>
          </tr>
          <tr>
            <td class="summary-td meta-label">Shipping &amp; Delivery Fees:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; font-family: monospace;">৳${Number(inv.shippingFees || 0).toFixed(2)}</td>
          </tr>
          <tr style="background-color: #eff6ff;">
            <td class="summary-td" style="font-weight: bold; color: #1d4ed8;">Grand Total Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; color: #1d4ed8; font-family: monospace; font-size: 11pt;">৳${Number(totalAmount).toFixed(2)}</td>
          </tr>
          <tr style="background-color: #f0fdf4;">
            <td class="summary-td" style="font-weight: bold; color: #15803d;">Paid Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; color: #15803d; font-family: monospace; font-size: 11pt;">৳${Number(paidAmount).toFixed(2)}</td>
          </tr>
          <tr style="background-color: #fef2f2;">
            <td class="summary-td" style="font-weight: bold; color: #b91c1c;">Due Balance:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; color: #b91c1c; font-family: monospace; font-size: 11pt;">৳${Number(dueAmount).toFixed(2)}</td>
          </tr>
        </table>

        <!-- Dual Signature Block (MSO Word Formatted Table) -->
        <table width="100%" style="margin-top: 30px; margin-bottom: 20px; border-top: 1px solid #cbd5e1; border-bottom: 1px solid #cbd5e1;">
          <tr>
            <td style="width: 45%; text-align: center; vertical-align: top; padding-top: 15px; padding-bottom: 15px;">
              <div style="font-family: monospace; color: #475569; letter-spacing: -1px; font-size: 11pt; margin-bottom: 6px;">-----------------------------------</div>
              <div style="font-weight: bold; font-size: 10pt; color: #0f172a; margin-bottom: 3px;">Commercial Officer Signature</div>
              <div style="font-size: 8.5pt; color: #64748b;">Commercial Accounts &amp; Verification</div>
            </td>
            <td style="width: 10%;"></td>
            <td style="width: 45%; text-align: center; vertical-align: top; padding-top: 15px; padding-bottom: 15px;">
              <div style="font-family: monospace; color: #475569; letter-spacing: -1px; font-size: 11pt; margin-bottom: 6px;">-----------------------------------</div>
              <div style="font-weight: bold; font-size: 10pt; color: #0f172a; margin-bottom: 3px;">Manager Signature</div>
              <div style="font-size: 8.5pt; color: #64748b;">General Manager / Operations</div>
            </td>
          </tr>
        </table>

        <table width="100%" style="margin-top: 15px; border-top: 1px solid #cbd5e1;">
          <tr>
            <td style="padding-top: 8px; font-size: 8.5pt; color: #64748b; text-align: center;">
              Official System Generated Invoice — Supply Chain Management Engine
            </td>
          </tr>
        </table>
      </body>
      </html>
    `;

    const blob = new Blob(['\ufeff' + wordTemplate], { type: 'application/msword;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `Invoice_${invoiceNo}.doc`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  }

  searchBilling(): void {
    this.billingSearched = true;
    if (!this.searchBillingCode || this.searchBillingCode.trim() === '') {
      this.billingSearchResult = null;
      this.statementPayments = [];
      return;
    }

    const orderNumber = this.searchBillingCode.trim();

    // Fetch Payment Statements for this order number
    this.paymentService.getPaymentsByOrderNumber(orderNumber).subscribe({
      next: (payments) => {
        this.statementPayments = payments || [];
        this.cdr.markForCheck();
      },
      error: () => {
        this.statementPayments = [];
        this.cdr.markForCheck();
      }
    });

    // Fetch Invoice & Order details
    this.invoiceService.findAll().subscribe({
      next: (invoices) => {
        this.orderService.findAll().subscribe({
          next: (orders) => {
            const order = (orders || []).find(
              o => o.orderNumber?.toLowerCase() === orderNumber.toLowerCase()
            );
            const foundInvoice = (invoices || []).find(inv => 
              inv.invoiceNumber?.toLowerCase() === orderNumber.toLowerCase() ||
              (order && inv.customerOrderId === order.id)
            );

            if (foundInvoice) {
              this.billingSearchResult = foundInvoice;
            } else if (order) {
              this.billingSearchResult = {
                invoiceNumber: 'INV-' + order.orderNumber,
                customerOrderId: order.id,
                issuedToName: order.customerName || this.userName,
                customerEmail: order.deliveryPhone || '',
                paymentStatus: order.paymentStatus || 'UNPAID',
                totalAmount: order.totalAmount || 0,
                paidAmount: order.paidAmount || 0,
                dueAmount: order.dueAmount || 0,
                subtotal: order.totalAmount || 0,
                taxRate: 0,
                taxAmount: 0,
                discountPercentage: 0,
                discountAmount: 0,
                shippingFees: 0,
                currency: 'BDT'
              };
            } else {
              this.billingSearchResult = null;
            }
            this.cdr.markForCheck();
          },
          error: () => {
            const foundInvoice = (invoices || []).find(inv => 
              inv.invoiceNumber?.toLowerCase() === orderNumber.toLowerCase()
            );
            this.billingSearchResult = foundInvoice || null;
            this.cdr.markForCheck();
          }
        });
      },
      error: () => {
        this.billingSearchResult = null;
        this.cdr.markForCheck();
      }
    });
  }

  trackOrder(): void {
    this.trackSearched = true;
    if (!this.searchTrackingCode || this.searchTrackingCode.trim() === '') {
      this.trackedResult = null;
      return;
    }

    this.orderService.findAll().subscribe({
      next: (orders) => {
        const found = (orders || []).find(
          (o) => o.orderNumber?.toLowerCase() === this.searchTrackingCode.trim().toLowerCase()
        );
        this.trackedResult = found || null;
        this.cdr.markForCheck();
      },
      error: () => {
        this.trackedResult = null;
        this.cdr.markForCheck();
      },
    });
  }

  openOrderFormView(): void {
    this.resetOrderForm();
    if (this.customer && this.customer.id) {
      this.order.customerId = this.customer.id;
    } else {
      this.loadCustomerForOrder();
    }
    this.loadProductsForForm();
    this.showOrderFormOnly = true;
    this.cdr.markForCheck();
  }

  closeOrderFormView(): void {
    this.showOrderFormOnly = false;
    this.resetOrderForm();
    this.cdr.markForCheck();
  }

  resetOrderForm(): void {
    this.order = {
      customerId: this.customer?.id || 0,
      deliveryAddress: '',
      deliveryPhone: '',
      estimatedDelivery: '',
      serviceType: 'STANDARD',
      priority: 'NORMAL',
      currency: 'BDT',
      codAmount: 0,
      paymentMethod: 'CASH',
      status: 'PENDING',
      remarks: '',
      items: []
    };
    this.currentProduct = null;
    this.currentQuantity = 1;
    this.currentRemarks = '';
    this.orderImageFile = null;
    this.orderImagePreview = null;
  }

  loadCustomerForOrder(): void {
    this.cutomerService.getCustomerByUserId(this.userId).subscribe({
      next: (cust) => {
        if (cust && cust.id) {
          this.customer = cust;
          this.order.customerId = cust.id;
          this.cdr.markForCheck();
        }
      }
    });
  }

  loadProductsForForm(): void {
    this.productService.findAll().subscribe({
      next: (data) => {
        this.products = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  addItemToForm(): void {
    if (!this.currentProduct) {
      alert("Please select a product!");
      return;
    }
    if (this.currentQuantity <= 0) {
      alert("Quantity must be positive!");
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

  removeItemFromForm(index: number): void {
    this.order.items.splice(index, 1);
    this.cdr.markForCheck();
  }

  getProductName(productId: number): string {
    return this.products.find(p => p.id == productId)?.name || 'Unknown Item';
  }

  calculateItemSubtotal(): number {
    let subtotal = 0;
    for (let item of this.order.items) {
      const p = this.products.find(prod => prod.id == item.productId);
      if (p && p.sellingPrice) subtotal += p.sellingPrice * item.quantity;
    }
    return subtotal;
  }

  calculateTotalWeight(): number {
    let weight = 0;
    for (let item of this.order.items) {
      const p = this.products.find(prod => prod.id == item.productId);
      if (p && p.weight) weight += p.weight * item.quantity;
    }
    return weight;
  }

  calculateDeliveryCharge(): number {
    const w = this.calculateTotalWeight();
    let charge = 60 + (w * 15);
    if (this.order.serviceType === 'EXPRESS') charge *= 1.5;
    if (this.order.serviceType === 'OVERNIGHT') charge *= 2.0;
    if (this.order.serviceType === 'SAME_DAY') charge *= 2.5;
    return Math.round(charge);
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

  onOrderImageChange(event: any): void {
    const fileList: FileList = event.target.files;
    if (fileList.length > 0) {
      this.orderImageFile = fileList[0];
      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.orderImagePreview = e.target.result;
      };
      reader.readAsDataURL(this.orderImageFile);
    } else {
      this.orderImagePreview = null;
      this.orderImageFile = null;
    }
  }

  saveFormOrder(): void {
    if (!this.order.deliveryPhone || this.order.deliveryPhone.trim() === '') {
      alert("Delivery phone number is required!");
      return;
    }
    if (this.order.items.length === 0) {
      alert("Please add at least one product!");
      return;
    }

    this.orderService.save(this.order, this.orderImageFile || undefined).subscribe({
      next: () => {
        alert("🚀 New customer purchase order dispatched and authorized!");
        this.closeOrderFormView();
        this.loadDashboardData();
      },
      error: (err: any) => {
        alert(err.error?.message || "Failed to dispatch order.");
      }
    });
  }

  isStepCompleted(step: string): boolean {
    if (!this.trackedResult || !this.trackedResult.status) return false;
    
    if (this.trackedResult.status === 'CANCELLED' || this.trackedResult.status === 'RETURNED') {
      return step === 'PENDING';
    }

    const currentIndex = this.statusHierarchy.indexOf(this.trackedResult.status.toUpperCase());
    const stepIndex = this.statusHierarchy.indexOf(step.toUpperCase());

    return currentIndex !== -1 && stepIndex !== -1 && stepIndex <= currentIndex;
  }

  loadCustomer(): void {
    if (this.storage.getRole() === 'ADMIN') return;
    this.cutomerService.getCustomerByUserId(this.userId).subscribe({
      next: (res) => {
        this.customer = res;
        this.storage.saveData(KEYS.CUSTOMER, res);
        this.cdr.markForCheck();
      },
      error: (err: any) => console.log(err),
    });
  }

  ngOnDestroy(): void {}

  loadDashboardData(): void {
    this.loading = true;
    this.orderService.findAll().subscribe({
      next: (orders) => {
        this.customerOrders = orders ? orders.filter((o) => o.customerId === this.userId) : [];

        this.stats.total = this.customerOrders.length;
        this.stats.pending = this.customerOrders.filter((o) => o.status === 'PENDING').length;
        this.stats.active = this.customerOrders.filter((o) =>
          ['CONFIRMED', 'PROCESSING', 'SHIPPED', 'OUT_FOR_DELIVERY'].includes(o.status),
        ).length;
        this.stats.completed = this.customerOrders.filter((o) => o.status === 'DELIVERED').length;
        this.stats.cancelled = this.customerOrders.filter((o) => o.status === 'CANCELLED').length;
        this.stats.duePayments = this.customerOrders.filter(
          (o) => o.paymentStatus !== 'PAID',
        ).length;

        this.walletBalance = this.customerOrders
          .filter((o) => o.paymentStatus === 'PAID')
          .reduce((sum, o) => sum + (Number(o.totalAmount) || 0), 0);

        this.dueAmountTotal = this.customerOrders
          .filter((o) => o.paymentStatus !== 'PAID')
          .reduce((sum, o) => sum + (parseFloat(o.dueAmount as any) || 0), 0);

        const totalOrders = this.customerOrders.length;
        const deliveredCount = this.customerOrders.filter((o) => o.status === 'DELIVERED').length;
        const processingCount = this.customerOrders.filter((o) =>
          ['CONFIRMED', 'PROCESSING', 'SHIPPED', 'OUT_FOR_DELIVERY', 'PENDING'].includes(o.status),
        ).length;
        const cancelledCount = this.customerOrders.filter((o) => o.status === 'CANCELLED').length;

        if (totalOrders > 0) {
          this.deliveredPercent = Math.round((deliveredCount / totalOrders) * 100);
          this.processingPercent = Math.round((processingCount / totalOrders) * 100);
          this.cancelledPercent = Math.round((cancelledCount / totalOrders) * 100);
        }

        this.recentOrders = [...this.customerOrders]
          .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
          .slice(0, 5);

        this.loading = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Customer metrics fetching failed:', err);
        this.loading = false;
        this.cdr.markForCheck();
      },
    });
  }

  loadRecommendations(): void {
    this.productService.findAll().subscribe({ next: (data) => {
        this.recommendations = (data || []).slice(0, 5).map((p: ProductResponseModel) => ({
          name: p.name || 'Product',
          price: p.sellingPrice || 0,
          rating:
            Math.round(((p.sellingPrice || 0) / Math.max(p.unitCost || 1, 1)) * 10) / 10 > 5
              ? 5
              : Math.round(((p.sellingPrice || 0) / Math.max(p.unitCost || 1, 1)) * 10) / 10 || 4.0,
          image: p.image || null }));
        this.cdr.markForCheck();
      },
    });
  }

  getImageUrl(imageName: string | null | undefined): string {
    return imageName ? `${this.imageBaseUrl}${imageName}` : '';
  }

  onImageError(prod: any): void {
    prod.image = null;
    this.cdr.markForCheck();
  }

  loadNotifications(): void {
    this.notificationService.findAll().subscribe({
      next: (data) => {
        this.notifications = (data || []).slice(0, 5);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  getActionIcon(action: string): string {
    const icons: Record<string, string> = {
      CREATE: 'bi-plus-circle text-success',
      UPDATE: 'bi-pencil-square text-primary',
      DELETE: 'bi-trash text-danger',
      LOGIN: 'bi-box-arrow-in-right text-info',
    };
    return icons[action] || 'bi-clock text-secondary';
  }

  isChildRouteActive(): boolean {
    return this.router.url.includes('customer_profile');
  }

  onEditProfileTriggered(): void {
    this.showSettings = false;
    this.router.navigate(['customer_profile'], { relativeTo: this.route });
  }



  downloadStatementWord(): void {
    const orderNo = this.searchBillingCode || this.searchStatementOrderId || 'STATEMENT';
    const invoiceNo = this.billingSearchResult?.invoiceNumber || ('INV-' + orderNo);
    const customerName = this.billingSearchResult?.issuedToName || this.userName || 'Customer';
    const currency = this.billingSearchResult?.currency || 'BDT';
    const totalAmount = this.billingSearchResult?.totalAmount || 0;
    const paidAmount = this.billingSearchResult?.paidAmount || 0;
    const dueAmount = this.billingSearchResult?.dueAmount || 0;

    let tableRows = '';
    if (this.statementPayments && this.statementPayments.length > 0) {
      this.statementPayments.forEach((p, index) => {
        const dateStr = p.createdAt ? new Date(p.createdAt).toLocaleString() : 'N/A';
        const method = p.paymentMethod || 'N/A';
        const acc = p.customerAccountNumber || 'N/A';
        const amount = p.paidAmount ? p.paidAmount.toFixed(2) : '0.00';
        const status = this.formatIssueStatus(p.issueStatus);
        const bgRow = index % 2 === 1 ? 'background-color: #f8fafc;' : 'background-color: #ffffff;';
        
        let statusBadge = `<span style="background-color: #f1f5f9; color: #475569; padding: 3px 8px; font-size: 8.5pt; font-weight: bold; border-radius: 10px;">${status}</span>`;
        if (p.issueStatus && p.issueStatus.includes('CONFIRMED')) {
          statusBadge = `<span style="background-color: #dcfce7; color: #15803d; border: 1px solid #86efac; padding: 3px 8px; font-size: 8.5pt; font-weight: bold; border-radius: 10px;">Confirmed by Officer</span>`;
        } else if (p.issueStatus && p.issueStatus.includes('PENDING')) {
          statusBadge = `<span style="background-color: #fef9c3; color: #a16207; border: 1px solid #fde047; padding: 3px 8px; font-size: 8.5pt; font-weight: bold; border-radius: 10px;">Pending Verification</span>`;
        }

        tableRows += `
          <tr style="${bgRow}">
            <td class="data-td" style="text-align: center; font-weight: bold;">${index + 1}</td>
            <td class="data-td" style="font-family: monospace;">${dateStr}</td>
            <td class="data-td" style="text-align: center;"><b style="background-color: #e2e8f0; padding: 2px 6px; font-size: 8.5pt;">${method}</b></td>
            <td class="data-td" style="font-family: monospace;">${acc}</td>
            <td class="data-td" style="text-align: right; font-weight: bold; color: #16a34a; font-family: monospace;">৳${amount}</td>
            <td class="data-td" style="text-align: center;">${statusBadge}</td>
          </tr>
        `;
      });
    } else {
      tableRows = `
        <tr>
          <td colspan="6" style="text-align: center; border: 1px solid #cbd5e1; padding: 12px; color: #64748b;">No payment statement transactions recorded yet.</td>
        </tr>
      `;
    }

    const wordTemplate = `
      <html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
      <head>
        <meta charset='utf-8'>
        <title>Payment Statement - ${orderNo}</title>
        <!--[if gte mso 9]>
        <xml>
          <w:WordDocument>
            <w:View>Print</w:View>
            <w:Zoom>100</w:Zoom>
            <w:DoNotOptimizeForBrowser/>
          </w:WordDocument>
        </xml>
        <![endif]-->
        <style>
          @page { size: A4 portrait; margin: 0.5in 0.5in 0.5in 0.5in; }
          body { font-family: 'Segoe UI', Arial, sans-serif; color: #0f172a; margin: 0; padding: 0; background-color: #ffffff; }
          table { border-collapse: collapse; width: 100%; }
          .title-banner { background-color: #1d4ed8; color: #ffffff; padding: 14px 18px; font-size: 18pt; font-weight: bold; text-align: left; }
          .subtitle { color: #93c5fd; font-size: 9.5pt; font-weight: normal; margin-top: 3px; }
          .section-bar { background-color: #1e3a8a; color: #ffffff; font-size: 10.5pt; font-weight: bold; padding: 6px 12px; letter-spacing: 0.5px; }
          .meta-td { padding: 7px 10px; border: 1px solid #cbd5e1; font-size: 9.5pt; }
          .meta-label { background-color: #f1f5f9; font-weight: bold; color: #475569; width: 22%; }
          .data-th { background-color: #0f172a; color: #ffffff; font-weight: bold; font-size: 9.5pt; padding: 8px 10px; border: 1px solid #0f172a; text-align: left; }
          .data-td { padding: 7px 10px; font-size: 9.5pt; border: 1px solid #e2e8f0; vertical-align: middle; }
          .summary-td { padding: 7px 10px; font-size: 9.5pt; border: 1px solid #e2e8f0; }
        </style>
      </head>
      <body>

        <!-- Executive Banner Header -->
        <table width="100%" style="margin-bottom: 12px;">
          <tr>
            <td class="title-banner">
              OFFICIAL PAYMENT STATEMENT
              <div class="subtitle">Supply Chain Management Financial Settlement Report</div>
            </td>
          </tr>
        </table>

        <!-- Order & Customer Meta Table -->
        <table width="100%" style="margin-bottom: 16px;">
          <tr>
            <td class="meta-td meta-label">Customer Order No:</td>
            <td class="meta-td" style="font-weight: bold; color: #1d4ed8; font-family: monospace;">${orderNo}</td>
            <td class="meta-td meta-label">Invoice Reference:</td>
            <td class="meta-td" style="font-family: monospace;">${invoiceNo}</td>
          </tr>
          <tr>
            <td class="meta-td meta-label">Issued To Name:</td>
            <td class="meta-td" style="font-weight: bold;">${customerName}</td>
            <td class="meta-td meta-label">Settlement Currency:</td>
            <td class="meta-td" style="font-weight: bold;">${currency}</td>
          </tr>
          <tr>
            <td class="meta-td meta-label">Generated Date:</td>
            <td class="meta-td">${new Date().toLocaleString()}</td>
            <td class="meta-td meta-label">Payment Status:</td>
            <td class="meta-td" style="font-weight: bold; color: #16a34a;">${this.billingSearchResult?.paymentStatus || 'RECORD FOUND'}</td>
          </tr>
        </table>

        <!-- Transaction Log Section -->
        <table width="100%" style="margin-bottom: 4px;">
          <tr>
            <td class="section-bar">PAYMENT STATEMENT TRANSACTION LOG</td>
          </tr>
        </table>

        <table width="100%" class="data-table" style="margin-bottom: 16px;">
          <thead>
            <tr>
              <th class="data-th" style="text-align: center; width: 6%;">SL</th>
              <th class="data-th" style="width: 24%;">Date & Time</th>
              <th class="data-th" style="width: 14%; text-align: center;">Method</th>
              <th class="data-th" style="width: 22%;">Account / Ref No</th>
              <th class="data-th" style="width: 16%; text-align: right;">Paid Amount</th>
              <th class="data-th" style="width: 18%; text-align: center;">Status</th>
            </tr>
          </thead>
          <tbody>
            ${tableRows}
          </tbody>
        </table>

        <!-- Financial Breakdown Section -->
        <table width="100%" style="margin-bottom: 4px;">
          <tr>
            <td class="section-bar">FINANCIAL BREAKDOWN SUMMARY</td>
          </tr>
        </table>

        <table width="100%" style="margin-bottom: 16px;">
          <tr>
            <td class="summary-td meta-label">Subtotal Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; font-family: monospace;">৳${Number(this.billingSearchResult?.subtotal || totalAmount).toFixed(2)}</td>
          </tr>
          <tr>
            <td class="summary-td meta-label">Tax & Shipping Fees:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; font-family: monospace;">৳${Number((this.billingSearchResult?.taxAmount || 0) + (this.billingSearchResult?.shippingFees || 0)).toFixed(2)}</td>
          </tr>
          <tr style="background-color: #eff6ff;">
            <td class="summary-td" style="font-weight: bold; color: #1d4ed8;">Total Order Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; color: #1d4ed8; font-family: monospace; font-size: 11pt;">৳${Number(totalAmount).toFixed(2)}</td>
          </tr>
          <tr style="background-color: #f0fdf4;">
            <td class="summary-td" style="font-weight: bold; color: #15803d;">Total Paid Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; color: #15803d; font-family: monospace; font-size: 11pt;">৳${Number(paidAmount).toFixed(2)}</td>
          </tr>
          <tr style="background-color: #fef2f2;">
            <td class="summary-td" style="font-weight: bold; color: #b91c1c;">Total Due Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; color: #b91c1c; font-family: monospace; font-size: 11pt;">৳${Number(dueAmount).toFixed(2)}</td>
          </tr>
        </table>

        <!-- Dual Signature Block (MSO Word Formatted Table) -->
        <table width="100%" style="margin-top: 30px; margin-bottom: 20px; border-top: 1px solid #cbd5e1; border-bottom: 1px solid #cbd5e1;">
          <tr>
            <td style="width: 45%; text-align: center; vertical-align: top; padding-top: 15px; padding-bottom: 15px;">
              <div style="font-family: monospace; color: #475569; letter-spacing: -1px; font-size: 11pt; margin-bottom: 6px;">-----------------------------------</div>
              <div style="font-weight: bold; font-size: 10pt; color: #0f172a; margin-bottom: 3px;">Commercial Officer Signature</div>
              <div style="font-size: 8.5pt; color: #64748b;">Commercial Accounts &amp; Verification</div>
            </td>
            <td style="width: 10%;"></td>
            <td style="width: 45%; text-align: center; vertical-align: top; padding-top: 15px; padding-bottom: 15px;">
              <div style="font-family: monospace; color: #475569; letter-spacing: -1px; font-size: 11pt; margin-bottom: 6px;">-----------------------------------</div>
              <div style="font-weight: bold; font-size: 10pt; color: #0f172a; margin-bottom: 3px;">Manager Signature</div>
              <div style="font-size: 8.5pt; color: #64748b;">General Manager / Operations</div>
            </td>
          </tr>
        </table>

        <!-- Document Footer -->
        <table width="100%" style="margin-top: 15px; border-top: 1px solid #cbd5e1;">
          <tr>
            <td style="padding-top: 8px; font-size: 8.5pt; color: #64748b; text-align: center;">
              Official System Generated Statement — Supply Chain Management Engine
            </td>
          </tr>
        </table>

      </body>
      </html>
    `;

    const blob = new Blob(['\ufeff' + wordTemplate], { type: 'application/msword;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `Payment_Statement_${orderNo}.doc`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  }



  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
  }

  // Add Payment Logic
  paymentImagePreview: string | null = null;
  paymentCustomerAccountNumber: string = '';
  
  openPaymentModal() {
    this.isPaymentModalOpen = true;
    this.resetPaymentState();
    this.cdr.markForCheck();
  }

  closePaymentModal() {
    this.isPaymentModalOpen = false;
    this.resetPaymentState();
    this.cdr.markForCheck();
  }

  resetPaymentState() {
    this.paymentSearchOrderNumber = '';
    this.paymentOrderDetails = null;
    this.paymentAmount = 0;
    this.paymentMethod = 'CASH';
    this.paymentFile = null;
    this.paymentImagePreview = null;
    this.paymentCustomerAccountNumber = '';
    this.paymentErrorMessage = null;
  }

  searchOrderForPayment() {
    this.paymentErrorMessage = null;
    if (!this.paymentSearchOrderNumber) return;

    this.orderService.trackOrder(this.paymentSearchOrderNumber).subscribe({
      next: (order) => {
        // Only allow if order belongs to the customer
        if (order.customerId !== this.userId) {
          this.paymentOrderDetails = null;
          this.paymentErrorMessage = "Order not found or invalid order number.";
          this.cdr.markForCheck();
          return;
        }

        this.paymentOrderDetails = order;
        if (order.dueAmount) {
          this.paymentAmount = Number(order.dueAmount);
        }
        this.cdr.markForCheck();
      },
      error: (err) => {
        this.paymentOrderDetails = null;
        this.paymentErrorMessage = "Order not found or invalid order number.";
        this.cdr.markForCheck();
      }
    });
  }

  onPaymentFileChange(event: any) {
    const fileList: FileList = event.target.files;
    if (fileList.length > 0) {
      this.paymentFile = fileList[0];
      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.paymentImagePreview = e.target.result;
      };
      reader.readAsDataURL(this.paymentFile);
    } else {
      this.paymentImagePreview = null;
      this.paymentFile = null;
    }
  }

  submitPayment() {
    this.paymentErrorMessage = null;
    if (!this.paymentOrderDetails) return;
    if (this.paymentAmount <= 0) {
      this.paymentErrorMessage = "Amount must be greater than zero.";
      return;
    }

    const payload = {
      customerOrderId: this.paymentOrderDetails.id,
      paidAmount: this.paymentAmount,
      paymentMethod: this.paymentMethod,
      customerAccountNumber: this.paymentCustomerAccountNumber
    };

    const formData = new FormData();
    formData.append('payment', new Blob([JSON.stringify(payload)], { type: 'application/json' }));
    
    if (this.paymentFile) {
      formData.append('image', this.paymentFile);
    } else {
      formData.append('image', new Blob([], { type: 'application/octet-stream' }), 'empty.png');
    }

    this.paymentService.addPayment(formData).subscribe({
      next: () => {
        alert("Payment submitted successfully. It will be verified by an officer soon.");
        this.closePaymentModal();
        this.loadDashboardData();
      },
      error: (err) => {
        this.paymentErrorMessage = err.error?.message || err.message || "Failed to add payment.";
        this.cdr.markForCheck();
      }
    });
  }
}