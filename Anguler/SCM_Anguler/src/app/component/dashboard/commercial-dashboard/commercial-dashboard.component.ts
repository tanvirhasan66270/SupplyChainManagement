import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { KEYS, StorageService } from '../../../auth/auth_service/storage.service';
import { CommercialOfficerService } from '../../../service/commercial-officer.service';
import { CommercialOfficerResponseModel } from '../../shared/model/commercialOfficer';
import { LoginResponse } from '../../../auth/Model/authModel';
import { LetterOfCreditService } from '../../../service/letterofcradit.service';
import { LetterOfCreditRequestModel, LetterOfCreditResponseModel } from '../../shared/model/letterOfCraditModel';
import { ShipmentService } from '../../../service/shipment.service';
import { ShipmentResponseModel } from '../../shared/model/shipmentModel';
import { NotificationService } from '../../../system/service/notification.service';
import { NotificationModel } from '../../../system/NotificationModel';
import { InvoiceService } from '../../../service/invoice.service';
import { CustomerOrderService } from '../../../service/customer-order.service';
import { CustomerOrderResponseModel } from '../../shared/model/customerOrder';
import { InvoiceResponseModel } from '../../shared/model/invoiceModel';
import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';
import { PaymentStatementService } from '../../../service/payment-statement.service';
import { PaymentStatementResponse } from '../../shared/model/PaymentStatementModel';
import { SupplierService } from '../../../service/supplier.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { LcbankService } from '../../../service/lcbank.service';
import { LCBankResponseModel } from '../../shared/model/lcbankModel';
import { PoLineItemService } from '../../../service/po-line-item.service';
import { POLineItemResponseDTO } from '../../shared/model/pOLineItemModel';
import { environment } from '../../../../environment/environment';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-commercial-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, DashboardSettingsComponent, FormsModule],
  templateUrl: './commercial-dashboard.component.html',
  styleUrls: ['./commercial-dashboard.component.css'],
})
export class CommercialDashboardComponent implements OnInit {
  userName = '';
  showSettings = false;
  loading = true;
  today = new Date();

  kpis = [
    { label: 'Active Import LCs', value: '0 LCs', trend: 0, icon: 'bi-bank', color: 'primary' },
    { label: 'Customer Paid (BDT)', value: '৳ 0', trend: 0, icon: 'bi-wallet2', color: 'warning' },
    { label: 'LC Dues (USD)', value: '$0.00', trend: 0, icon: 'bi-currency-dollar', color: 'info' },
    {
      label: 'Customs Pending',
      value: '0 Shipments',
      trend: 0,
      icon: 'bi-file-earmark-lock',
      color: 'danger',
    },
    {
      label: 'Docs Approved Today',
      value: '0 Sets',
      trend: 0,
      icon: 'bi-file-earmark-check',
      color: 'success',
    },
  ];

  lcs: LetterOfCreditResponseModel[] = [];
  lcSearchTerm: string = '';
  documents: { name: string; type: string; date: string; status: string; url: string }[] = [];
  notifications: NotificationModel[] = [];
  invoices: InvoiceResponseModel[] = [];

  totalLCValue = 0;
  totalLCValueBDT = 0;
  totalLCValueUSD = 0;
  pendingCustoms = 0;
  approvedDocs = 0;
  dashboardBanks: LCBankResponseModel[] = [];
  dashboardShipments: ShipmentResponseModel[] = [];
  dashboardLineItems: POLineItemResponseDTO[] = [];
  dashboardCustomerOrders: CustomerOrderResponseModel[] = [];

  userId!: number;
  commercialOfficer: CommercialOfficerResponseModel | null = null;
  user: LoginResponse | null = null;

  isPaymentModalOpen = false;
  pendingPayments: PaymentStatementResponse[] = [];
  paymentStatusMessage: string | null = null;
  imgUrl = environment.imgUrl;

  // Customer Orders Master View Modal States
  isCustomerOrderModalOpen = false;
  customerOrdersList: CustomerOrderResponseModel[] = [];
  customerOrderMasterSearchTerm = '';
  customerOrderMasterLoading = false;

  // Commercial Invoices Master View Modal States
  isInvoiceModalOpen = false;
  invoicesList: InvoiceResponseModel[] = [];
  invoiceMasterSearchTerm = '';
  invoiceMasterLoading = false;

  // Shipping & Cargo Master View Modal States
  isShippingModalOpen = false;
  shipmentsMasterList: ShipmentResponseModel[] = [];
  shipmentMasterSearchTerm = '';
  shipmentMasterLoading = false;

  // LC Registry Master View Modal States
  isLcRegistryModalOpen = false;
  lcRegistrySearchTerm = '';

  // PO Line Items Modal States
  isLineItemsModalOpen = false;
  lineItemsList: POLineItemResponseDTO[] = [];
  lineItemsLoading = false;
  lineItemsSearchTerm = '';

  // Add New LC Modal States
  isAddLcModalOpen = false;
  lcPurchaseOrders: any[] = [];
  lcSuppliers: any[] = [];
  lcBanks: any[] = [];
  selectedLcFile: File | null = null;
  lcFormLoading = false;
  lcFormSuccessMessage: string | null = null;
  lcFormErrorMessage: string | null = null;

  newLc: LetterOfCreditRequestModel = {
    purchaseOrderId: 0,
    issuingBankId: 0,
    shipmentIncoTerms: 'FOB',
    latestShipmentDate: '',
    portOfLoading: '',
    portOfDischarge: '',
    amount: 0,
    supplierId: 0,
    currency: 'USD',
    expiryDate: '',
    lcStatus: 'OPENED',
    documentVaultUrl: ''
  };

  constructor(
    private storage: StorageService,
    private commercialOfficerService: CommercialOfficerService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private lcService: LetterOfCreditService,
    private shipmentService: ShipmentService,
    private notificationService: NotificationService,
    private invoiceService: InvoiceService,
    private customerOrderService: CustomerOrderService,
    private paymentStatementService: PaymentStatementService,
    private poService: PurchaseOrderService,
    private supplierService: SupplierService,
    private lcBankService: LcbankService,
    private poLineItemService: PoLineItemService,
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) {
      return;
    }
    this.userName = user.name;
    this.userId = user.userId;
    this.loadCommercialOfficer();
    this.loadDashboardData();
    this.loadNotifications();
    this.loadInvoices();
  }

  loadDashboardData() {
    this.documents = [];
    this.lcService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        const activeLCs = all.filter((lc) => lc.lcStatus !== 'CANCELLED');
        this.totalLCValue = activeLCs.reduce((sum: number, lc) => sum + (lc.amount || 0), 0);
        
        this.totalLCValueBDT = activeLCs
          .filter(lc => !lc.currency || lc.currency.toUpperCase() === 'BDT' || lc.currency.toUpperCase() === 'TAKA')
          .reduce((sum: number, lc) => sum + (lc.amount || 0), 0);

        this.totalLCValueUSD = activeLCs
          .filter(lc => lc.currency && lc.currency.toUpperCase() === 'USD')
          .reduce((sum: number, lc) => sum + (lc.amount || 0), 0);

        this.kpis[0] = { ...this.kpis[0], value: `${activeLCs.length} LCs` };
        this.kpis[2] = { ...this.kpis[2], value: `$${this.totalLCValueUSD.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}` };
        this.lcs = activeLCs.slice(0, 5);
        this.buildLCDocuments(all);
        this.loading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.loading = false;
        this.cdr.markForCheck();
      },
    });

    this.shipmentService.findAll().subscribe({
      next: (data) => {
        const all = (data || []) as any[];
        const pending = all.filter((s) => s.status === 'PENDING' || s.status === 'CUSTOMS');
        this.pendingCustoms = pending.length;
        this.kpis[3] = { ...this.kpis[3], value: `${pending.length} Shipments` };
        this.dashboardShipments = all.slice(0, 4);
        this.buildShipmentDocuments(all);
        this.cdr.markForCheck();
      },
    });

    this.lcBankService.findAll().subscribe({
      next: (banks) => {
        this.dashboardBanks = (banks || []).slice(0, 4);
        this.cdr.markForCheck();
      },
      error: () => {}
    });

    this.poLineItemService.findAll().subscribe({
      next: (items) => {
        this.dashboardLineItems = (items || []).slice(0, 4);
        this.cdr.markForCheck();
      },
      error: () => {}
    });

    this.paymentStatementService.getPaymentsByStatus('PENDING_VERIFICATION').subscribe({
      next: (res: PaymentStatementResponse[]) => {
        this.pendingPayments = (res || []).slice(0, 4);
        this.cdr.markForCheck();
      },
      error: () => {}
    });

    this.customerOrderService.findAll().subscribe({
      next: (orders) => {
        this.dashboardCustomerOrders = (orders || []).slice(0, 5);
        this.cdr.markForCheck();
      },
      error: () => {}
    });
  }

  buildLCDocuments(lcs: LetterOfCreditResponseModel[]) {
    const lcdocs = lcs
      .filter((lc) => lc.documentVaultUrl)
      .map((lc) => ({
        name: `LC Document - ${lc.lcNumber}`,
        type: 'Letter of Credit',
        date: lc.createdAt ? new Date(lc.createdAt).toLocaleDateString() : 'N/A',
        status: lc.lcStatus === 'OPENED' ? 'Approved' : 'Pending Review',
        url: lc.documentVaultUrl,
      }));
    this.documents = [...this.documents, ...lcdocs];
  }

  buildShipmentDocuments(shipments: ShipmentResponseModel[]) {
    const shipDocs = shipments
      .filter((s) => s.podFileUrl)
      .map((s) => ({
        name: `POD - ${s.shipmentNumber}`,
        type: 'Shipment',
        date: s.createdAt ? new Date(s.createdAt).toLocaleDateString() : 'N/A',
        status: 'Approved',
        url: s.podFileUrl,
      }));
    this.documents = [...this.documents, ...shipDocs];
    this.approvedDocs = this.documents.filter((d) => d.status === 'Approved').length;
    this.kpis[4] = { ...this.kpis[4], value: `${this.approvedDocs} Sets` };
  }

  loadInvoices() {
    this.invoiceService.findAll().subscribe({
      next: (data: InvoiceResponseModel[]) => {
        const allInvoices = data || [];
        const totalPaid = allInvoices.reduce((sum, inv) => sum + (inv.paidAmount || 0), 0);
        this.kpis[1] = { ...this.kpis[1], value: `৳ ${totalPaid.toLocaleString()}` };
        this.invoices = allInvoices.slice(0, 5);
        this.cdr.markForCheck();
      },
    });
  }

  loadNotifications() {
    this.notificationService.findAll().subscribe({
      next: (data) => {
        this.notifications = (data || []).slice(0, 8);
        this.cdr.markForCheck();
      },
    });
  }

  loadCommercialOfficer(): void {
    if (this.storage.getRole() === 'ADMIN') return;
    this.commercialOfficerService.getCommercialOfficerByUserId(this.userId).subscribe({
      next: (res) => {
        this.commercialOfficer = res;
        this.storage.saveData(KEYS.COMMERCIAL_OFFICER, res);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  toggleSettings(): void {
    this.showSettings = !this.showSettings;
    this.cdr.markForCheck();
  }

  closeSettings(): void {
    this.showSettings = false;
    this.cdr.markForCheck();
  }

  getLCStatusClass(status: string): string {
    switch (status) {
      case 'DRAFT':
        return 'bg-secondary-subtle text-secondary';
      case 'OPENED':
        return 'bg-success-subtle text-success';
      case 'AMENDED':
        return 'bg-warning-subtle text-warning';
      case 'EXPIRED':
        return 'bg-danger-subtle text-danger';
      case 'CANCELLED':
        return 'bg-dark-subtle text-dark';
      default:
        return 'bg-secondary-subtle text-secondary';
    }
  }

  getNotifIcon(type: string): string {
    switch (type) {
      case 'SHIPMENT':
        return 'bi-truck text-primary';
      case 'TRIP_ALERT':
        return 'bi-exclamation-triangle text-warning';
      case 'REPORT_APPROVED':
        return 'bi-check-circle text-success';
      default:
        return 'bi-bell text-secondary';
    }
  }

  getActionIcon(action: string): string {
    switch (action) {
      case 'CREATE':
        return 'bi-plus-circle text-success';
      case 'UPDATE':
        return 'bi-pencil-square text-primary';
      case 'DELETE':
        return 'bi-trash text-danger';
      case 'LOGIN':
        return 'bi-box-arrow-in-right text-info';
      default:
        return 'bi-activity text-secondary';
    }
  }

  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
    this.cdr.markForCheck();
  }

  // Payment Verification Modal Methods
  openPaymentModal(): void {
    this.isPaymentModalOpen = true;
    this.paymentStatusMessage = null;
    this.loadPendingPayments();
    this.cdr.markForCheck();
  }

  closePaymentModal(): void {
    this.isPaymentModalOpen = false;
    this.cdr.markForCheck();
  }

  loadPendingPayments(): void {
    this.paymentStatementService.getPaymentsByStatus('PENDING_VERIFICATION').subscribe({
      next: (data) => {
        this.pendingPayments = data || [];
        this.cdr.markForCheck();
      },
      error: () => {
        this.pendingPayments = [];
        this.cdr.markForCheck();
      }
    });
  }

  updatePaymentStatus(id: number, status: string): void {
    this.paymentStatusMessage = null;
    this.paymentStatementService.updatePaymentStatus(id, status).subscribe({
      next: () => {
        this.paymentStatusMessage = `Payment has been successfully ${status === 'CONFIRMED_BY_OFFICER' ? 'Confirmed' : 'Rejected'}.`;
        this.loadPendingPayments();
      },
      error: (err) => {
        this.paymentStatusMessage = err.error?.message || 'Failed to update payment status.';
        this.cdr.markForCheck();
      }
    });
  }

  // Customer Orders Master View Modal Methods
  openCustomerOrdersModal(): void {
    this.isCustomerOrderModalOpen = true;
    this.customerOrderMasterSearchTerm = '';
    this.customerOrderMasterLoading = true;
    this.customerOrderService.findAll().subscribe({
      next: (res) => {
        this.customerOrdersList = res || [];
        this.customerOrderMasterLoading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.customerOrdersList = [];
        this.customerOrderMasterLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  closeCustomerOrdersModal(): void {
    this.isCustomerOrderModalOpen = false;
    this.cdr.markForCheck();
  }

  get filteredMasterCustomerOrders(): CustomerOrderResponseModel[] {
    if (!this.customerOrderMasterSearchTerm.trim()) {
      return this.customerOrdersList;
    }
    const term = this.customerOrderMasterSearchTerm.toLowerCase().trim();
    return this.customerOrdersList.filter(o =>
      (o.orderNumber && o.orderNumber.toLowerCase().includes(term)) ||
      (o.customerName && o.customerName.toLowerCase().includes(term)) ||
      (o.customerEmail && o.customerEmail.toLowerCase().includes(term)) ||
      (o.paymentMethod && o.paymentMethod.toLowerCase().includes(term)) ||
      (o.status && o.status.toLowerCase().includes(term))
    );
  }

  // Commercial Invoices Master View Modal Methods
  openInvoiceModal(): void {
    this.isInvoiceModalOpen = true;
    this.invoiceMasterSearchTerm = '';
    this.invoiceMasterLoading = true;
    this.invoiceService.findAll().subscribe({
      next: (res) => {
        this.invoicesList = res || [];
        this.invoiceMasterLoading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.invoicesList = [];
        this.invoiceMasterLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  closeInvoiceModal(): void {
    this.isInvoiceModalOpen = false;
    this.cdr.markForCheck();
  }

  get filteredMasterInvoices(): InvoiceResponseModel[] {
    if (!this.invoiceMasterSearchTerm.trim()) {
      return this.invoicesList;
    }
    const term = this.invoiceMasterSearchTerm.toLowerCase().trim();
    return this.invoicesList.filter(inv =>
      (inv.invoiceNumber && inv.invoiceNumber.toLowerCase().includes(term)) ||
      (inv.issuedToName && inv.issuedToName.toLowerCase().includes(term)) ||
      (inv.customerEmail && inv.customerEmail.toLowerCase().includes(term)) ||
      (inv.paymentStatus && inv.paymentStatus.toLowerCase().includes(term)) ||
      (inv.invoiceStatus && inv.invoiceStatus.toLowerCase().includes(term))
    );
  }

  // Shipping & Cargo Master View Modal Methods
  openShippingModal(): void {
    this.isShippingModalOpen = true;
    this.shipmentMasterSearchTerm = '';
    this.shipmentMasterLoading = true;
    this.shipmentService.findAll().subscribe({
      next: (res) => {
        this.shipmentsMasterList = res || [];
        this.shipmentMasterLoading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.shipmentsMasterList = [];
        this.shipmentMasterLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  closeShippingModal(): void {
    this.isShippingModalOpen = false;
    this.cdr.markForCheck();
  }

  get filteredMasterShipments(): ShipmentResponseModel[] {
    if (!this.shipmentMasterSearchTerm.trim()) {
      return this.shipmentsMasterList;
    }
    const term = this.shipmentMasterSearchTerm.toLowerCase().trim();
    return this.shipmentsMasterList.filter(shp =>
      (shp.shipmentNumber && shp.shipmentNumber.toLowerCase().includes(term)) ||
      (shp.supplierName && shp.supplierName.toLowerCase().includes(term)) ||
      (shp.vehicleNumber && shp.vehicleNumber.toLowerCase().includes(term)) ||
      (shp.origin && shp.origin.toLowerCase().includes(term)) ||
      (shp.sendByAddress && shp.sendByAddress.toLowerCase().includes(term))
    );
  }

  downloadInvoiceWord(inv: InvoiceResponseModel): void {
    if (!inv) return;
    const invoiceNo = inv.invoiceNumber || 'INV-SETTLEMENT';
    const customerName = inv.issuedToName || 'Valued Commercial Client';
    const currency = inv.currency || 'BDT';
    const totalAmount = inv.totalAmount || 0;
    const paidAmount = Number(inv.paidAmount || 0);
    const dueAmount = Number(inv.dueAmount || 0);

    const wordTemplate = `
      <html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
      <head>
        <meta charset='utf-8'>
        <title>Commercial Invoice - ${invoiceNo}</title>
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
          .summary-td { padding: 7px 10px; font-size: 9.5pt; border: 1px solid #e2e8f0; }
        </style>
      </head>
      <body>
        <table width="100%" style="margin-bottom: 12px;">
          <tr>
            <td class="title-banner">
              OFFICIAL COMMERCIAL INVOICE
              <div class="subtitle">Supply Chain Management Import &amp; Export Settlement</div>
            </td>
          </tr>
        </table>

        <table width="100%" style="margin-bottom: 16px;">
          <tr>
            <td class="meta-td meta-label">Invoice Number:</td>
            <td class="meta-td" style="font-weight: bold; color: #2563eb; font-family: monospace;">${invoiceNo}</td>
            <td class="meta-td meta-label">Settlement Currency:</td>
            <td class="meta-td" style="font-weight: bold;">${currency}</td>
          </tr>
          <tr>
            <td class="meta-td meta-label">Billed To Name:</td>
            <td class="meta-td" style="font-weight: bold;">${customerName}</td>
            <td class="meta-td meta-label">Customer Email:</td>
            <td class="meta-td">${inv.customerEmail || 'N/A'}</td>
          </tr>
          <tr>
            <td class="meta-td meta-label">Invoice Date:</td>
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
            <td class="section-bar">COMMERCIAL FINANCIAL BREAKDOWN</td>
          </tr>
        </table>

        <table width="100%" style="margin-bottom: 16px;">
          <tr>
            <td class="summary-td meta-label">Subtotal Amount:</td>
            <td class="summary-td" style="text-align: right; font-weight: bold; font-family: monospace;">৳${Number(inv.subtotal || totalAmount).toFixed(2)}</td>
          </tr>
          <tr>
            <td class="summary-td meta-label">Shipping &amp; Logistics Fees:</td>
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
              Official System Generated Document — Supply Chain Management Engine
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

  // Add New LC Modal Methods
  openAddLcModal(): void {
    this.isAddLcModalOpen = true;
    this.lcFormSuccessMessage = null;
    this.lcFormErrorMessage = null;
    this.selectedLcFile = null;
    this.resetNewLcForm();
    this.loadLcDropdowns();
    this.cdr.markForCheck();
  }

  closeAddLcModal(): void {
    this.isAddLcModalOpen = false;
    this.cdr.markForCheck();
  }

  resetNewLcForm(): void {
    this.newLc = {
      purchaseOrderId: 0,
      issuingBankId: 0,
      shipmentIncoTerms: 'FOB',
      latestShipmentDate: '',
      portOfLoading: '',
      portOfDischarge: '',
      amount: 0,
      supplierId: 0,
      currency: 'USD',
      expiryDate: '',
      lcStatus: 'OPENED',
      documentVaultUrl: ''
    };
  }

  loadLcDropdowns(): void {
    this.poService.findAll().subscribe({ next: (res) => { this.lcPurchaseOrders = res || []; this.cdr.markForCheck(); } });
    this.supplierService.findAll().subscribe({ next: (res) => { this.lcSuppliers = res || []; this.cdr.markForCheck(); } });
    this.lcBankService.findAll().subscribe({ next: (res) => { this.lcBanks = res || []; this.cdr.markForCheck(); } });
  }

  onLcFileSelected(event: any): void {
    if (event.target.files && event.target.files.length > 0) {
      this.selectedLcFile = event.target.files[0];
    }
  }

  submitNewLc(): void {
    this.lcFormErrorMessage = null;
    this.lcFormSuccessMessage = null;

    if (!this.newLc.purchaseOrderId || +this.newLc.purchaseOrderId === 0 ||
        !this.newLc.supplierId || +this.newLc.supplierId === 0 ||
        !this.newLc.issuingBankId || +this.newLc.issuingBankId === 0) {
      this.lcFormErrorMessage = "Please select a valid Purchase Order, Supplier, and Issuing Bank from dropdown options.";
      this.cdr.markForCheck();
      return;
    }

    if (!this.newLc.amount || this.newLc.amount <= 0) {
      this.lcFormErrorMessage = "Please enter a valid contract amount greater than 0.";
      this.cdr.markForCheck();
      return;
    }

    this.lcFormLoading = true;
    this.lcService.save(this.newLc, this.selectedLcFile).subscribe({
      next: (createdLc) => {
        this.lcFormSuccessMessage = `Letter of Credit #${createdLc.lcNumber || 'NEW'} has been successfully registered!`;
        this.lcFormLoading = false;
        this.loadDashboardData();
        setTimeout(() => {
          this.closeAddLcModal();
        }, 1500);
      },
      error: (err) => {
        this.lcFormErrorMessage = err.error?.message || "Failed to issue Letter of Credit. Please check input parameters.";
        this.lcFormLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  // LC Registry Master View Modal Methods
  openLcRegistryModal(): void {
    this.isLcRegistryModalOpen = true;
    this.lcRegistrySearchTerm = '';
    this.loadDashboardData();
    this.cdr.markForCheck();
  }

  closeLcRegistryModal(): void {
    this.isLcRegistryModalOpen = false;
    this.cdr.markForCheck();
  }

  get filteredRegistryLCs(): LetterOfCreditResponseModel[] {
    if (!this.lcRegistrySearchTerm.trim()) {
      return this.lcs;
    }
    const term = this.lcRegistrySearchTerm.toLowerCase().trim();
    return this.lcs.filter(lc =>
      (lc.lcNumber && lc.lcNumber.toLowerCase().includes(term)) ||
      (lc.issuingBankName && lc.issuingBankName.toLowerCase().includes(term)) ||
      (lc.supplierName && lc.supplierName.toLowerCase().includes(term)) ||
      (lc.shipmentIncoTerms && lc.shipmentIncoTerms.toLowerCase().includes(term)) ||
      (lc.lcStatus && lc.lcStatus.toLowerCase().includes(term))
    );
  }

  // PO Line Items Modal Methods
  openLineItemsModal(): void {
    this.isLineItemsModalOpen = true;
    this.lineItemsLoading = true;
    this.lineItemsSearchTerm = '';
    this.poLineItemService.findAll().subscribe({
      next: (res) => {
        this.lineItemsList = res || [];
        this.lineItemsLoading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.lineItemsList = [];
        this.lineItemsLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  closeLineItemsModal(): void {
    this.isLineItemsModalOpen = false;
    this.cdr.markForCheck();
  }
}
