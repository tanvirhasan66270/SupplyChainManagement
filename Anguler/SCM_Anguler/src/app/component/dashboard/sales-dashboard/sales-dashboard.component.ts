import { Component, OnInit, ChangeDetectorRef, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import { RouterModule, Router } from '@angular/router';
import { KEYS, StorageService } from '../../../auth/auth_service/storage.service';
import { SalesOfficerService } from '../../../service/sales-officer.service';
import { SalesOfficerResponseDTO } from '../../shared/model/salesOfficerModel';
import { LoginResponse } from '../../../auth/Model/authModel';
import { CustomerOrderService } from '../../../service/customer-order.service';
import { CustomerService } from '../../../service/customer.service';
import { QuotationService } from '../../../service/quatation.service';
import { InvoiceService } from '../../../service/invoice.service';
import { NotificationService } from '../../../system/service/notification.service';
import { NotificationModel } from '../../../system/NotificationModel';
import { ShipmentService } from '../../../service/shipment.service';
import Chart from 'chart.js/auto';
import { AddProductService } from '../../../service/add-product.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { PurchaseOrderResponseModel } from '../../shared/model/purchaseOrderModel';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-sales-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './sales-dashboard.component.html',
  styleUrls: ['./sales-dashboard.component.css'],
})
export class SalesDashboardComponent implements OnInit, AfterViewInit {
  userName = '';
  userId!: number;
  salesOfficer: SalesOfficerResponseDTO | null = null;
  user: LoginResponse | null = null;
  isLoading = true;

  orders: any[] = [];
  quotations: any[] = [];
  customers: any[] = [];
  allCustomers: any[] = [];
  invoices: any[] = [];
  notifications: NotificationModel[] = [];
  shipments: any[] = [];
  products: any[] = [];
  purchaseOrders: PurchaseOrderResponseModel[] = [];

  totalRevenue = 0;
  todaysSales = 0;
  todaysOrders = 0;
  activeQuotations = 0;
  pendingDeliveries = 0;
  outstandingPayments = 0;
  monthlyTarget = 10000000; // Fixed goal: 10 Million

  pendingTasks: any[] = [];
  pipeline = { leads: 0, quotations: 0, negotiation: 0, order: 0, delivered: 0 };

  private ordersLoaded = false;
  
  // Status Modal Properties
  isStatusModalOpen = false;
  selectedOrderForStatus: any = null;
  newOrderStatus = 'PENDING';
  availableStatuses = [
    'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 
    'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'RETURNED', 'REFUNDED'
  ];

  // PDF Modal Properties
  @ViewChild('orderPdfContainer') orderPdfContainer!: ElementRef;
  isPdfModalOpen = false;
  selectedOrderForPdf: any = null;
  private customersLoaded = false;
  
  // Charts
  private overviewChart: any;
  private productsChart: any;
  private targetChart: any;

  targetProgress: number = 0;

  activeModal: 'orders' | 'quotations' | 'customers' | 'shipments' | 'notifications' | 'target' | 'purchase' | 'invoices' | 'payments' | 'directory' | null = null;
  modalSearchText = '';
  
  // Dashboard Order Table Search Properties
  dashboardOrderSearchText = '';
  dashboardOrderSearchDate = '';
  dashboardOrderStatusSearch = 'ALL';

  get dashboardFilteredOrders(): any[] {
    let list = this.orders;
    
    if (this.dashboardOrderStatusSearch && this.dashboardOrderStatusSearch !== 'ALL') {
      list = list.filter((o: any) => o.status === this.dashboardOrderStatusSearch);
    }
    
    if (this.dashboardOrderSearchText) {
      const q = this.dashboardOrderSearchText.toLowerCase();
      list = list.filter((o: any) => 
        (o.orderNumber && String(o.orderNumber).toLowerCase().includes(q)) ||
        (o.customerName && String(o.customerName).toLowerCase().includes(q)) ||
        (o.paymentStatus && String(o.paymentStatus).toLowerCase().includes(q)) ||
        (o.status && String(o.status).toLowerCase().includes(q))
      );
    }
    
    if (this.dashboardOrderSearchDate) {
      list = list.filter((o: any) => {
        if (!o.createdAt) return false;
        return o.createdAt.startsWith(this.dashboardOrderSearchDate);
      });
    }
    return list;
  }

  purchaseSelectedMonth: number | 'ALL' = 'ALL';
  purchaseSelectedDate: string = '';
  invoiceSelectedMonth: number | 'ALL' = 'ALL';
  invoiceSelectedDate: string = '';

  selectedOverviewMonth: number | 'ALL' = 7; // Default August
  selectedOverviewYear: number = 2026;

  yearsList: number[] = [2026, 2025, 2024, 2023];
  monthsList = [
    { value: 'ALL', label: 'All Months' },
    { value: 0, label: 'January' },
    { value: 1, label: 'February' },
    { value: 2, label: 'March' },
    { value: 3, label: 'April' },
    { value: 4, label: 'May' },
    { value: 5, label: 'June' },
    { value: 6, label: 'July' },
    { value: 7, label: 'August' },
    { value: 8, label: 'September' },
    { value: 9, label: 'October' },
    { value: 10, label: 'November' },
    { value: 11, label: 'December' }
  ];

  constructor(
    private storage: StorageService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private salesOfficerService: SalesOfficerService,
    private orderService: CustomerOrderService,
    private customerService: CustomerService,
    private quotationService: QuotationService,
    private invoiceService: InvoiceService,
    private notificationService: NotificationService,
    private shipmentService: ShipmentService,
    private productService: AddProductService,
    private purchaseOrderService: PurchaseOrderService
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) return;
    this.userName = user.name || 'Sales Officer';
    this.userId = user.userId;
    this.loadSalesOfficer();
    this.loadAllData();
  }

  ngAfterViewInit(): void {
    this.initCharts();
    this.updateChartsWithDynamicData();
  }

  loadAllData(): void {
    this.isLoading = true;
    let completed = 0;
    const totalCalls = 8; // Orders, Quotes, Invoices, Notifs, Customers, Shipments, Products, PurchaseOrders
    const checkDone = () => {
      completed++;
      if (completed >= totalCalls) {
        this.isLoading = false;
        this.buildCustomerStats();
        this.buildDynamicTasks();
        this.updateChartsWithDynamicData();
        this.cdr.markForCheck();
      }
    };

    this.loadOrders(checkDone);
    this.loadQuotations(checkDone);
    this.loadInvoices(checkDone);
    this.loadNotifications(checkDone);
    this.loadCustomers(checkDone);
    this.loadShipments(checkDone);
    this.loadProducts(checkDone);
    this.loadPurchaseOrders(checkDone);
  }

  loadPurchaseOrders(done?: () => void): void {
    this.purchaseOrderService.findAll().subscribe({
      next: (data) => {
        this.purchaseOrders = data || [];
        if (done) done();
        this.cdr.markForCheck();
      },
      error: () => {
        if (done) done();
      }
    });
  }

  loadOrders(done: () => void): void {
    this.orderService.findAll().subscribe({
      next: (data) => {
        this.orders = (data || []).sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        this.ordersLoaded = true;
        
        this.pendingDeliveries = this.orders.filter((o: any) => o.status === 'PROCESSING' || o.status === 'SHIPPED').length;
        
        const todayStr = new Date().toISOString().split('T')[0];
        const todaysList = this.orders.filter((o: any) => o.createdAt?.startsWith(todayStr));
        this.todaysOrders = todaysList.length;
        this.todaysSales = todaysList.reduce((sum: number, o: any) => sum + (o.totalAmount || o.codAmount || 0), 0);
        
        this.pipeline.order = this.orders.length;
        this.pipeline.delivered = this.orders.filter((o: any) => o.status === 'DELIVERED').length;
        done();
      },
      error: () => done(),
    });
  }

  loadQuotations(done: () => void): void {
    this.quotationService.findAll().subscribe({
      next: (data) => {
        this.quotations = (data || []).sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        this.activeQuotations = this.quotations.filter((q: any) => q.status === 'PENDING' || q.status === 'UNDER_REVIEW').length;
        
        this.pipeline.leads = this.quotations.length;
        this.pipeline.quotations = this.quotations.filter((q: any) => q.status === 'PENDING').length;
        this.pipeline.negotiation = this.quotations.filter((q: any) => q.status === 'UNDER_REVIEW').length;
        done();
      },
      error: () => done(),
    });
  }

  get approvedQuotations(): any[] {
    return (this.quotations || []).filter((q: any) => q.status?.toUpperCase() === 'APPROVED');
  }

  loadInvoices(done: () => void): void {
    this.invoiceService.findAll().subscribe({
      next: (data) => {
        this.invoices = data || [];
        this.totalRevenue = this.invoices
          .filter((inv: any) => inv.invoiceStatus === 'ISSUED' || inv.invoiceStatus === 'PAID')
          .reduce((sum: number, inv: any) => sum + (inv.totalAmount || 0), 0);
          
        this.outstandingPayments = this.invoices
          .filter((inv: any) => inv.invoiceStatus === 'ISSUED' || inv.invoiceStatus === 'OVERDUE')
          .reduce((sum: number, inv: any) => sum + (inv.totalAmount || 0), 0);
          
        done();
      },
      error: () => done(),
    });
  }

  loadNotifications(done: () => void): void {
    this.notificationService.findAll().subscribe({
      next: (data) => {
        this.notifications = data || [];
        done();
      },
      error: () => done(),
    });
  }

  loadShipments(done: () => void): void {
    this.shipmentService.findAll().subscribe({
      next: (data) => {
        this.shipments = (data || []).map((s: any) => ({
           id: s.shipmentNumber || s.id,
           vehicle: s.vehicleNumber || 'Unassigned',
           destination: s.sendByAddress || 'Warehouse',
           eta: s.estimatedDelivery || 'Pending'
        }));
        done();
      },
      error: () => done(),
    });
  }

  openModal(modalType: 'orders' | 'quotations' | 'customers' | 'shipments' | 'notifications' | 'target' | 'purchase' | 'invoices' | 'payments' | 'directory'): void {
    this.activeModal = modalType;
    this.modalSearchText = '';
    this.purchaseSelectedMonth = 'ALL';
    this.purchaseSelectedDate = '';
    this.invoiceSelectedMonth = 'ALL';
    this.invoiceSelectedDate = '';
    if (modalType === 'purchase') {
      this.loadPurchaseOrders();
    }
    this.cdr.markForCheck();
  }

  get issuedInvoices(): any[] {
    return (this.invoices || []).filter((inv: any) => inv.invoiceStatus?.toUpperCase() === 'ISSUED');
  }

  get filteredModalInvoices(): any[] {
    let list = this.issuedInvoices;
    if (list.length === 0 && this.invoices.length > 0) {
      list = this.invoices;
    }

    if (this.modalSearchText) {
      const q = this.modalSearchText.toLowerCase();
      list = list.filter((inv: any) => {
        const invNum = inv.invoiceNumber ? String(inv.invoiceNumber).toLowerCase() : '';
        if (invNum.includes(q)) return true;
        const custName = (inv.issuedToName || inv.customerName || '').toLowerCase();
        const custEmail = (inv.customerEmail || '').toLowerCase();
        return custName.includes(q) || custEmail.includes(q);
      });
    }

    if (this.invoiceSelectedMonth !== 'ALL') {
      const monthIndex = Number(this.invoiceSelectedMonth);
      list = list.filter((inv: any) => {
        const dateStr = inv.issuedAt || inv.createdAt || inv.deliveryDate;
        if (!dateStr) return false;
        return new Date(dateStr).getMonth() === monthIndex;
      });
    }

    if (this.invoiceSelectedDate) {
      list = list.filter((inv: any) => {
        const dateStr = inv.issuedAt || inv.createdAt || inv.deliveryDate;
        if (!dateStr) return false;
        return dateStr.startsWith(this.invoiceSelectedDate);
      });
    }

    return list;
  }

  getCustomerOrderNoForInvoice(inv: any): string {
    if (!inv || !inv.customerOrderId) return 'N/A';
    const matchingOrder = this.orders.find((o: any) => Number(o.id) === Number(inv.customerOrderId));
    if (matchingOrder && matchingOrder.orderNumber) {
      return matchingOrder.orderNumber;
    }
    return `SO-${inv.customerOrderId}`;
  }

  closeModal(): void {
    this.activeModal = null;
    this.modalSearchText = '';
    this.purchaseSelectedMonth = 'ALL';
    this.purchaseSelectedDate = '';
    this.invoiceSelectedMonth = 'ALL';
    this.invoiceSelectedDate = '';
    this.cdr.markForCheck();
  }

  get receivedPurchaseOrders(): PurchaseOrderResponseModel[] {
    return (this.purchaseOrders || []).filter(po => po.status?.toUpperCase() === 'RECEIVED');
  }

  get filteredModalPurchaseOrders(): PurchaseOrderResponseModel[] {
    let list = this.receivedPurchaseOrders;
    if (list.length === 0 && this.purchaseOrders.length > 0) {
      list = this.purchaseOrders;
    }

    if (this.modalSearchText) {
      const q = this.modalSearchText.toLowerCase();
      list = list.filter(po => 
        (po.poNumber && String(po.poNumber).toLowerCase().includes(q)) ||
        (po.supplierName && String(po.supplierName).toLowerCase().includes(q))
      );
    }
    return list;
  }

  get filteredModalOrders(): any[] {
    if (!this.modalSearchText) return this.orders;
    const q = this.modalSearchText.toLowerCase();
    return this.orders.filter((o: any) => 
      (o.orderNumber && String(o.orderNumber).toLowerCase().includes(q)) ||
      (o.customerName && String(o.customerName).toLowerCase().includes(q))
    );
  }

  get filteredModalPayments(): any[] {
    if (!this.modalSearchText) return this.orders;
    const q = this.modalSearchText.toLowerCase();
    return this.orders.filter((o: any) => 
      (o.orderNumber && String(o.orderNumber).toLowerCase().includes(q)) ||
      (String(o.id).toLowerCase().includes(q)) ||
      (o.customerName && String(o.customerName).toLowerCase().includes(q))
    );
  }

  get filteredModalQuotations(): any[] {
    const approved = this.approvedQuotations;
    if (!this.modalSearchText) return approved;
    const q = this.modalSearchText.toLowerCase();
    return approved.filter((item: any) => 
      (item.quotationNumber && String(item.quotationNumber).toLowerCase().includes(q)) ||
      (item.customerName && String(item.customerName).toLowerCase().includes(q))
    );
  }

  get filteredModalCustomers(): any[] {
    if (!this.modalSearchText) return this.customers;
    const q = this.modalSearchText.toLowerCase();
    return this.customers.filter((c: any) => 
      (c.name && String(c.name).toLowerCase().includes(q)) ||
      (c.email && String(c.email).toLowerCase().includes(q))
    );
  }

  get filteredModalDirectory(): any[] {
    if (!this.modalSearchText) return this.allCustomers;
    const q = this.modalSearchText.toLowerCase();
    return this.allCustomers.filter((c: any) => 
      (c.name && String(c.name).toLowerCase().includes(q)) ||
      (c.email && String(c.email).toLowerCase().includes(q)) ||
      (c.phone && String(c.phone).toLowerCase().includes(q)) ||
      (c.nid && String(c.nid).toLowerCase().includes(q)) ||
      (c.id && String(c.id).toLowerCase().includes(q))
    );
  }

  get filteredModalShipments(): any[] {
    if (!this.modalSearchText) return this.shipments;
    const q = this.modalSearchText.toLowerCase();
    return this.shipments.filter((s: any) => 
      (s.id && String(s.id).toLowerCase().includes(q)) ||
      (s.vehicle && String(s.vehicle).toLowerCase().includes(q))
    );
  }

  get filteredModalNotifications(): any[] {
    if (!this.modalSearchText) return this.notifications;
    const q = this.modalSearchText.toLowerCase();
    return this.notifications.filter((n: any) => 
      (n.title && String(n.title).toLowerCase().includes(q)) ||
      (n.message && String(n.message).toLowerCase().includes(q))
    );
  }

  get filteredModalTargetInvoices(): any[] {
    if (!this.modalSearchText) return this.invoices;
    const q = this.modalSearchText.toLowerCase();
    return this.invoices.filter((inv: any) => 
      (inv.invoiceNumber && String(inv.invoiceNumber).toLowerCase().includes(q)) ||
      (inv.customerName && String(inv.customerName).toLowerCase().includes(q)) ||
      (inv.invoiceStatus && String(inv.invoiceStatus).toLowerCase().includes(q))
    );
  }

  loadProducts(done: () => void): void {
    this.productService.findAll().subscribe({
      next: (data) => {
        this.products = (data || []).sort((a: any, b: any) => (b.unitPrice || 0) - (a.unitPrice || 0)).slice(0, 5);
        done();
      },
      error: () => done(),
    });
  }

  loadCustomers(done: () => void): void {
    this.customerService.getAll().subscribe({
      next: (data) => {
        this.allCustomers = (data || []).map((c: any) => ({
          id: c.userId || c.id || '',
          name: c.name || 'Customer',
          email: c.email || '',
          phone: c.phone || c.contactNumber || '',
          nid: c.nidNumber || c.nid || c.nationalId || '',
          gender: c.gender || '',
          dob: c.dob || '',
          address: c.address || '',
          createdAt: c.createdAt || ''
        }));
        this.customers = (data || []).map((c: any) => ({
          id: c.userId || c.id,
          name: c.name || 'Customer',
          email: c.email || '',
          spent: 0,
          due: 0
        }));
        this.customersLoaded = true;
        done();
      },
      error: () => done(),
    });
  }

  getOrderDueAmount(o: any): number {
    if (!o || o.status === 'CANCELLED' || o.paymentStatus === 'PAID') return 0;
    if (o.dueAmount != null && Number(o.dueAmount) > 0) {
      return Number(o.dueAmount);
    }
    const total = Number(o.totalAmount) || Number(o.codAmount) || 0;
    const paid = Number(o.paidAmount) || 0;
    return Math.max(0, total - paid);
  }

  buildCustomerStats(): void {
    if (!this.ordersLoaded) return;
    
    const customerMap = new Map<string, any>();

    this.orders.forEach((o: any) => {
      const email = (o.customerEmail || '').trim().toLowerCase();
      let key = email;
      if (!key) {
        key = o.customerId ? `id_${o.customerId}` : (o.customerName ? `name_${o.customerName.trim().toLowerCase()}` : '');
      }
      if (!key) return;

      if (!customerMap.has(key)) {
        let matchedName = o.customerName || 'Customer';
        let matchedEmail = o.customerEmail || '';
        
        if (this.customersLoaded && email) {
          const matchedCust = this.customers.find((c: any) => c.email && c.email.trim().toLowerCase() === email);
          if (matchedCust) {
            matchedName = matchedCust.name || matchedName;
            matchedEmail = matchedCust.email || matchedEmail;
          }
        }

        customerMap.set(key, {
          id: o.customerId || key,
          name: matchedName,
          email: matchedEmail,
          spent: 0,
          due: 0,
          orderCount: 0
        });
      }

      const item = customerMap.get(key)!;
      item.spent += Number(o.totalAmount) || Number(o.codAmount) || 0;
      item.due += this.getOrderDueAmount(o);
      item.orderCount += 1;
    });

    this.customers = Array.from(customerMap.values())
      .filter((c: any) => c.spent > 0 || c.due > 0)
      .sort((a: any, b: any) => b.spent - a.spent);
  }

  buildDynamicTasks(): void {
    this.pendingTasks = [];
    if (this.activeQuotations > 0) {
      this.pendingTasks.push({ icon: 'bi-file-earmark-text', color: 'text-danger', text: `${this.activeQuotations} Pending Quotations` });
    }
    const pendingOrders = this.orders.filter(o => o.status === 'PENDING').length;
    if (pendingOrders > 0) {
      this.pendingTasks.push({ icon: 'bi-cart', color: 'text-warning', text: `${pendingOrders} Pending Orders` });
    }
    const todayStr = new Date().toISOString().split('T')[0];
    const todayShipments = this.shipments.filter(s => s.eta?.startsWith(todayStr)).length;
    if (todayShipments > 0) {
      this.pendingTasks.push({ icon: 'bi-truck', color: 'text-success', text: `${todayShipments} Deliveries Today` });
    }
    const unpaidInvoices = this.invoices.filter((inv: any) => inv.invoiceStatus === 'ISSUED').length;
    if (unpaidInvoices > 0) {
      this.pendingTasks.push({ icon: 'bi-receipt', color: 'text-primary', text: `${unpaidInvoices} Invoices Pending` });
    }
    
    if(this.pendingTasks.length === 0) {
      this.pendingTasks.push({ icon: 'bi-check-circle', color: 'text-success', text: `All tasks caught up!` });
    }
  }

  formatNumber(num: number): string {
    if (!num) return '0';
    if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
    if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
    return num.toLocaleString();
  }

  getStageBadgeClass(status: string): string {
    const map: Record<string, string> = {
      PENDING: 'badge-soft-warning',
      UNDER_REVIEW: 'badge-soft-warning',
      APPROVED: 'badge-soft-success',
      DELIVERED: 'badge-soft-success',
      PROCESSING: 'badge-soft-primary',
      REJECTED: 'badge-soft-danger',
      EXPIRED: 'badge-soft-secondary',
      DRAFT: 'badge-soft-secondary',
      SENT: 'badge-soft-primary',
      VIEWED: 'badge-soft-info'
    };
    return map[status?.toUpperCase()] || 'badge-soft-secondary';
  }
  
  getNotificationIcon(type: string): string {
    const map: Record<string, string> = {
      SUCCESS: 'bi-check-circle-fill text-success',
      INFO: 'bi-info-circle-fill text-info',
      WARNING: 'bi-exclamation-circle-fill text-warning',
      ERROR: 'bi-x-circle-fill text-danger'
    };
    return map[type?.toUpperCase()] || 'bi-bell-fill text-primary';
  }

  getTimeAgo(dateStr: string): string {
    if (!dateStr) return '';
    const diff = Date.now() - new Date(dateStr).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return 'Just now';
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    const days = Math.floor(hrs / 24);
    return `${days}d ago`;
  }

  loadSalesOfficer(): void {
    if (this.storage.getRole() === 'ADMIN') return;
    this.salesOfficerService.getSalesOfficerByUserId(this.userId).subscribe({
      next: (res) => {
        this.salesOfficer = res;
        this.storage.saveData(KEYS.SALES_OFFICER, res);
      },
      error: () => {},
    });
  }

  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
  }

  onMonthChange(event: Event): void {
    const val = (event.target as HTMLSelectElement).value;
    this.selectedOverviewMonth = val === 'ALL' ? 'ALL' : Number(val);
    this.updateChartsWithDynamicData();
  }

  onYearChange(event: Event): void {
    const val = (event.target as HTMLSelectElement).value;
    this.selectedOverviewYear = Number(val);
    this.updateChartsWithDynamicData();
  }

  initCharts() {
    const ctxOverview = document.getElementById('salesOverviewChart') as HTMLCanvasElement;
    const ctxProducts = document.getElementById('topProductsChart') as HTMLCanvasElement;
    const ctxTarget = document.getElementById('monthlyTargetChart') as HTMLCanvasElement;
    
    if (ctxOverview) {
      this.overviewChart = new Chart(ctxOverview, {
        type: 'line',
        data: { labels: [], datasets: [] },
        options: {
          responsive: true, maintainAspectRatio: false,
          plugins: { legend: { position: 'top', align: 'end', labels: { usePointStyle: true, boxWidth: 6, font: { size: 10, weight: 'bold', family: "'Inter', sans-serif" }, color: '#1e293b' } } },
          scales: {
            y: {
              type: 'linear',
              position: 'left',
              beginAtZero: true,
              grid: { color: '#f0f0f0' },
              ticks: {
                callback: function(val) {
                  const num = Number(val);
                  if (num >= 1000000) return '৳' + (num / 1000000).toFixed(1) + 'M';
                  if (num >= 1000) return '৳' + (num / 1000).toFixed(0) + 'K';
                  return '৳' + num;
                },
                font: { size: 10 }
              }
            },
            y1: {
              type: 'linear',
              position: 'right',
              beginAtZero: true,
              grid: { display: false },
              ticks: { precision: 0, font: { size: 10 } }
            },
            x: { grid: { display: false }, ticks: { font: { size: 10 } } }
          }
        }
      });
    }

    if (ctxProducts) {
      this.productsChart = new Chart(ctxProducts, {
        type: 'doughnut',
        data: { labels: [], datasets: [] },
        options: { responsive: true, maintainAspectRatio: false, cutout: '55%', plugins: { legend: { display: false } } }
      });
    }

    if (ctxTarget) {
      this.targetChart = new Chart(ctxTarget, {
        type: 'doughnut',
        data: { labels: [], datasets: [] },
        options: { responsive: true, maintainAspectRatio: false, cutout: '75%', plugins: { legend: { display: false }, tooltip: { enabled: false } } }
      });
    }
  }

  updateChartsWithDynamicData() {
    if (!this.overviewChart) {
      this.initCharts();
    }
    if (!this.overviewChart || !this.productsChart || !this.targetChart) return;

    const labels: string[] = [];
    const revenueData: number[] = [];
    const ordersData: number[] = [];

    const year = Number(this.selectedOverviewYear) || 2026;

    if (this.selectedOverviewMonth === 'ALL') {
      const shortMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      shortMonths.forEach((mName, mIndex) => {
        labels.push(mName);
        const monthOrders = this.orders.filter((o: any) => {
          if (!o.createdAt) return false;
          const d = new Date(o.createdAt);
          return d.getFullYear() === year && d.getMonth() === mIndex;
        });

        const rev = monthOrders.reduce((sum: number, o: any) => sum + (Number(o.totalAmount) || Number(o.codAmount) || 0), 0);
        revenueData.push(rev);
        ordersData.push(monthOrders.length);
      });
    } else {
      const month = Number(this.selectedOverviewMonth);
      const daysInMonth = new Date(year, month + 1, 0).getDate();
      const monthObj = this.monthsList.find(m => m.value === month);
      const mLabel = monthObj ? monthObj.label.substring(0, 3) : '';

      for (let day = 1; day <= daysInMonth; day++) {
        labels.push(`${day} ${mLabel}`);
        
        const dayOrders = this.orders.filter((o: any) => {
          if (!o.createdAt) return false;
          const d = new Date(o.createdAt);
          return d.getFullYear() === year && d.getMonth() === month && d.getDate() === day;
        });

        const rev = dayOrders.reduce((sum: number, o: any) => sum + (Number(o.totalAmount) || Number(o.codAmount) || 0), 0);
        revenueData.push(rev);
        ordersData.push(dayOrders.length);
      }
    }

    this.overviewChart.data.labels = labels;
    this.overviewChart.data.datasets = [
      {
        label: 'Revenue',
        data: revenueData,
        borderColor: '#2962ff',
        backgroundColor: 'rgba(41, 98, 255, 0.1)',
        tension: 0.4,
        fill: true,
        borderWidth: 2,
        pointBackgroundColor: '#2962ff',
        yAxisID: 'y'
      },
      {
        label: 'Orders',
        data: ordersData,
        borderColor: '#00c853',
        backgroundColor: 'rgba(0, 200, 83, 0.1)',
        tension: 0.4,
        fill: false,
        borderWidth: 2,
        pointBackgroundColor: '#00c853',
        yAxisID: 'y1'
      }
    ];
    this.overviewChart.update();

    const pLabels = this.products.map(p => p.name.substring(0, 15) + '...');
    const defaultData = [32, 28, 20, 12, 8];
    const pData = this.products.length > 0 ? this.products.map((p, i) => defaultData[i] || 1) : [100];

    this.productsChart.data.labels = pLabels;
    this.productsChart.data.datasets = [{
      data: pData,
      backgroundColor: ['#3b82f6', '#22c55e', '#f97316', '#8b5cf6', '#94a3b8'],
      borderWidth: 2,
      borderColor: '#ffffff'
    }];
    this.productsChart.update();

    let achieved = this.totalRevenue;
    if(achieved > this.monthlyTarget) achieved = this.monthlyTarget;
    let remain = this.monthlyTarget - achieved;
    if(remain < 0) remain = 0;
    this.targetProgress = (achieved / this.monthlyTarget) * 100;

    this.targetChart.data.labels = ['Achieved', 'Remaining'];
    this.targetChart.data.datasets = [{
      data: [achieved, remain],
      backgroundColor: ['#00c853', '#f0f2f5'],
      borderWidth: 0,
      cutout: '75%'
    }];
    this.targetChart.update();
  }
  openStatusModal(o: any) {
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

    this.orderService.updateStatus(this.selectedOrderForStatus.id, this.newOrderStatus).subscribe({
      next: () => {
        alert("✔️ Order lifecycle status updated successfully!");
        this.closeStatusModal();
        this.loadAllData(); // Reload orders to update table
      },
      error: (err: any) => {
        alert(err.error?.message || "Failed to update status.");
      }
    });
  }

  openPdfModal(o: any) {
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
    if (!this.orderPdfContainer) return;
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
}