import { ProductRequirementService } from '../../../service/product-requirement.service';
import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { KEYS, StorageService } from '../../../auth/auth_service/storage.service';
import { ProcurementService } from '../../../service/procourment.service';
import { ProcurementResponseDTO } from '../../shared/model/procourmentModel';
import { LoginResponse } from '../../../auth/Model/authModel';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { QuotationService } from '../../../service/quatation.service';
import { AddProductService } from '../../../service/add-product.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { PoLineItemService } from '../../../service/po-line-item.service';
import { InvoiceService } from '../../../service/invoice.service';
import { NotificationService } from '../../../system/service/notification.service';
import { NotificationModel } from '../../../system/NotificationModel';
import { PurchaseOrderResponseModel, PurchaseOrderRequestModel } from '../../shared/model/purchaseOrderModel';
import { purchaseRequisitionRequestModel, purchaseRequisitionResponseModel } from '../../shared/model/purchase-requisionModel';
import { QuotationRequestModel, QuotationResponseModel } from '../../shared/model/quatationModel';
import { SupplierService } from '../../../service/supplier.service';
import { ShipmentService } from '../../../service/shipment.service';
import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';
import { POLineItemComponent } from '../../features/poline-item.component/poline-item.component';

@Component({
  selector: 'app-procurement-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, DashboardSettingsComponent, POLineItemComponent],
  templateUrl: './procurement-dashboard.component.html',
  styleUrls: ['./procurement-dashboard.component.css'],
})
export class ProcurementDashboardComponent implements OnInit {
  userName = '';
  userId!: number;
  procurement: ProcurementResponseDTO | null = null;
  user: LoginResponse | null = null;
  showSettings = false;

  // Key Metrics (KPIs)
  totalSpend = 0;
  pendingPOs = 0;
  approvedPOs = 0;
  activeSuppliers = 0;
  approvedPRs = 0;
  
  totalInvoices = 0;
  totalProducts = 0;
  totalRFQs = 0;
  totalPRs = 0;

  // View All Modal State
  isViewAllModalOpen = false;
  viewAllModalTitle = '';
  viewAllModalType = '';
  viewAllModalData: any[] = [];
  modalSearchText: string = '';
  modalSearchDate: string = '';

  rfqSearchText: string = '';
  rfqSearchDate: string = '';
  activeRfqTab: string = 'ALL';
  shipments: any[] = [];

  get displayShipments() {
    let filtered = this.shipments || [];
    if (this.rfqSearchText && this.rfqSearchText.trim() !== '') {
      const searchLower = this.rfqSearchText.toLowerCase().trim();
      filtered = filtered.filter(s => {
        const values = Object.values(s).join(' ').toLowerCase();
        return values.includes(searchLower);
      });
    }
    return filtered;
  }

  get displayRfqs() {
    // Bypass monthly filter: "no change monthly data"
    let filtered = (this.rawRFQs || []).filter(q => q.status !== 'APPROVED' && q.status !== 'REJECTED');
    
    if (this.rfqSearchText && this.rfqSearchText.trim() !== '') {
      const searchLower = this.rfqSearchText.toLowerCase().trim();
      filtered = filtered.filter(q => {
        const values = Object.values(q).join(' ').toLowerCase();
        return values.includes(searchLower);
      });
    }

    if (this.rfqSearchDate) {
      filtered = filtered.filter(q => {
        const dateStr = q.createdAt || q.date || q.createdAtDate || '';
        if (!dateStr) return false;
        return String(dateStr).startsWith(this.rfqSearchDate);
      });
    }

    const mapped = filtered.map((q: any) => ({
      id: q.id || q.quotationId,
      item: q.productName || q.productDescription || 'N/A',
      qty: q.quantity || 0,
      status: q.status || 'PENDING',
      supplier: q.supplierName || 'Pending Sourcing',
    }));
    
    if (!this.rfqSearchText && !this.rfqSearchDate) {
      return mapped.slice(0, 5);
    }
    return mapped;
  }

  get approvedRfqs() {
    let filtered = (this.rawRFQs || []).filter(q => q.status === 'APPROVED');
    return filtered.map((q: any) => ({
      id: q.id || q.quotationId,
      item: q.productName || q.productDescription || 'N/A',
      qty: q.quantity || 0,
      status: q.status || 'APPROVED',
      supplier: q.supplierName || 'Pending Sourcing',
    }));
  }

  get rejectedRfqs() {
    let filtered = (this.rawRFQs || []).filter(q => q.status === 'REJECTED');
    return filtered.map((q: any) => ({
      id: q.id || q.quotationId,
      item: q.productName || q.productDescription || 'N/A',
      qty: q.quantity || 0,
      status: q.status || 'REJECTED',
      supplier: q.supplierName || 'Pending Sourcing',
    }));
  }

  selectedDashboardPeriod: string = 'All Time';
  rawPRs: any[] = [];
  rawRFQs: any[] = [];
  rawPOs: any[] = [];
  trackedPo: any = null;
  trackingPoNumberSearch: string = '';
  trackingSearchError: string = '';
  isTrackingModalOpen: boolean = false;
  showPoSuggestions: boolean = false;
  rawProducts: any[] = [];
  rawPoLineItems: any[] = [];
  rawInvoices: any[] = [];
  activeDirectoryModal: 'quotations' | 'suppliers' | 'invoices' | 'inventory' | null = null;
  userRole: string = '';


  // MODAL STATES & FORM DATA
  isPrModalOpen = false;
  isPoModalOpen = false;
  isQuotationModalOpen = false;

  prProducts: any[] = [];
  prSuppliers: any[] = [];
  approvedQuotations: QuotationResponseModel[] = [];
  quoteRequisitions: purchaseRequisitionResponseModel[] = [];

  newPr: purchaseRequisitionRequestModel = {
    requestedBy: 0,
    productIds: [],
    supplierIds: [],
    currency: 'USD',
    quantityRequired: 1,
    urgencyLevel: 'LOW',
    requiredByDate: '',
    remarks: ''
  };

  selectedPrProducts: any[] = [];
  prRequirements: any[] = [];
  selectedPrRequirements: any[] = [];

  onPrRequirementSelect(event: any) {
    const val = event.target.value;
    const reqId = Number(val.includes(':') ? val.split(':')[1].trim().replace('REQ_', '') : val.replace('REQ_', ''));
    if (reqId) {
      const req = this.prRequirements.find(r => r.id === reqId);
      if (req && !this.selectedPrRequirements.some(r => r.id === reqId)) {
        this.selectedPrRequirements.push(req);
      }
    }
    // reset selection
    event.target.value = '';
  }

  removePrRequirement(id: number) {
    this.selectedPrRequirements = this.selectedPrRequirements.filter(r => r.id !== id);
  }

  selectedPrSuppliers: any[] = [];

  newPo: PurchaseOrderRequestModel = {
    quotationId: 0,
    issuedBy: 0,
    totalAmount: 0,
    quantity: 1,
    currency: 'USD',
    expectedDeliveryDate: '',
    status: 'ISSUED',
    supplierName: 'N/A',
    supplierEmail: 'N/A',
    issuedByName: ''
  };

  newQuotation: QuotationRequestModel = {
    supplierId: 0,
    purchaseRequisitionId: 0,
    leadTimeDays: 7,
    receivedAt: '',
    status: 'PENDING',
    productDescription: '',
    unitPrice: 0,
    quantity: 1,
    deliveryTime: '',
    warranty: '',
    notes: ''
  };

  poCreatedAt: string = new Date().toLocaleString();
  modalSuccessMsg = '';
  modalErrorMsg = '';

  directorySearchQuery: string = '';

  openDirectoryModal(tab: 'quotations' | 'suppliers' | 'invoices' | 'inventory') {
    this.activeDirectoryModal = tab;
    this.directorySearchQuery = '';
    if (tab === 'suppliers' && (!this.prSuppliers || this.prSuppliers.length === 0)) {
      this.supplierService.findAll().subscribe((d: any) => this.prSuppliers = d || []);
    }
    this.cdr.markForCheck();
  }

  closeDirectoryModal() {
    this.activeDirectoryModal = null;
    this.directorySearchQuery = '';
    this.cdr.markForCheck();
  }


  setDashboardPeriod(period: string) {
    this.selectedDashboardPeriod = period;
    this.aggregateData();
  }

  filterByPeriod(data: any[]): any[] {
    if (this.selectedDashboardPeriod === 'All Time') return data;
    
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();
    
    return data.filter(item => {
      const dateStr = item.createdAt || item.date || item.createdAtDate || item.expectedDeliveryDate || '';
      if (!dateStr) return true;
      
      const d = new Date(dateStr);
      if (isNaN(d.getTime())) return true;
      
      const itemYear = d.getFullYear();
      const itemMonth = d.getMonth();
      
      switch (this.selectedDashboardPeriod) {
        case 'This Month': return itemYear === currentYear && itemMonth === currentMonth;
        case 'Last Month':
          const lastMonth = currentMonth === 0 ? 11 : currentMonth - 1;
          const lastMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear;
          return itemYear === lastMonthYear && itemMonth === lastMonth;
        case 'This Year': return itemYear === currentYear;
        case 'Last Year': return itemYear === currentYear - 1;
        case 'January': return itemYear === currentYear && itemMonth === 0;
        case 'February': return itemYear === currentYear && itemMonth === 1;
        case 'March': return itemYear === currentYear && itemMonth === 2;
        case 'April': return itemYear === currentYear && itemMonth === 3;
        case 'May': return itemYear === currentYear && itemMonth === 4;
        case 'June': return itemYear === currentYear && itemMonth === 5;
        case 'July': return itemYear === currentYear && itemMonth === 6;
        case 'August': return itemYear === currentYear && itemMonth === 7;
        case 'September': return itemYear === currentYear && itemMonth === 8;
        case 'October': return itemYear === currentYear && itemMonth === 9;
        case 'November': return itemYear === currentYear && itemMonth === 10;
        case 'December': return itemYear === currentYear && itemMonth === 11;
        default: return true;
      }
    });
  }

  aggregatePRs() {
    const all = this.filterByPeriod(this.rawPRs);
    const prCount = all.length;
    this.totalPRs = prCount;
    const prApproved = all.filter((r: any) => r.approvalStatus === 'APPROVED' || r.approvalStatus === 'FULFILLED').length;
    this.approvedPRs = prApproved;
    this.kpis[0] = { ...this.kpis[0], value: `${prCount} Requisitions` };
    if (prCount > 0 && prApproved > 0) {
      const prev = prCount - Math.round(prCount * 0.12);
      this.kpis[0].trend = prev > 0 ? Math.round(((prCount - prev) / prev) * 100) : prCount;
      this.kpis[0].trendDir = 'up';
    }
    this.allTotalPRsData = all;
  }

  aggregateRFQs() {
    const all = this.filterByPeriod(this.rawRFQs);
    const rfqCount = all.length;
    this.totalRFQs = rfqCount;
    this.kpis[1] = { ...this.kpis[1], value: `${rfqCount} Queries` };
    if (rfqCount > 0) {
      const prev = rfqCount - Math.round(rfqCount * 0.08);
      this.kpis[1].trend = prev > 0 ? Math.round(((rfqCount - prev) / prev) * 100) : rfqCount;
      this.kpis[1].trendDir = 'up';
    }
    this.rfqs = all.slice(0, 5).map((q: any) => ({
      id: q.id,
      item: q.productName || q.productDescription || 'N/A',
      qty: q.quantity || 0,
      status: q.status || 'PENDING',
      supplier: q.supplierName || 'Pending Sourcing',
    }));
    this.allActiveRFQsData = all;
  }

  aggregateProducts() {
    const all = this.filterByPeriod(this.rawProducts);
    const products = all.filter((p: any) => p.quantity <= (p.reorderPoint || 10));
    this.totalProducts = all.length;
    this.shortages = products.slice(0, 5).map((p: any) => ({
      item: p.name || 'Product',
      stock: `${p.quantity || 0} Units`,
      threshold: `${p.reorderPoint || 10} Units`,
      urgency: (p.quantity || 0) === 0 ? 'CRITICAL' : 'HIGH',
    }));
  }

  aggregatePOs() {
    const all = this.filterByPeriod(this.rawPOs);
    const poCount = all.length;
    const poPending = all.filter((po: any) => po.status === 'ISSUED' || po.status === 'DRAFT').length;
    this.pendingPOs = poPending;
    this.allPendingPOsData = all.filter((po: any) => po.status === 'ISSUED' || po.status === 'DRAFT');
    
    const approvedCount = all.filter((po: any) => po.status === 'APPROVED' || po.status === 'RECEIVED').length;
    this.approvedPOs = approvedCount;
    this.allApprovedPOsData = all.filter((po: any) => po.status === 'APPROVED' || po.status === 'RECEIVED');

    this.recentPOs = all.slice(0, 5);

    const totalSpend = all.reduce((sum: number, po: any) => sum + (po.totalAmount || 0), 0);
    this.totalSpend = totalSpend;

    this.kpis[2] = { ...this.kpis[2], value: `${poPending} Pending` };
    if (poCount > 0) {
      const prev = poCount - Math.round(poCount * 0.15);
      this.kpis[2].trend = prev > 0 ? Math.round(((poCount - prev) / prev) * 100) : poCount;
      this.kpis[2].trendDir = 'up';
    }

    const received = all.filter((po: any) => po.status === 'RECEIVED').length;
    const budgetPct = poCount > 0 ? Math.round((received / poCount) * 100) : 0;
    this.kpis[3] = { ...this.kpis[3], value: `${budgetPct}%` };
    this.kpis[3].trend = budgetPct > 0 ? Math.min(budgetPct, 100) : 0;
    this.kpis[3].trendDir = 'up';
  }


  aggregateData() {
    this.aggregatePRs();
    this.aggregateRFQs();
    this.aggregatePOs();
    this.aggregateProducts();
    this.buildCostAnalytics();
    this.buildQuickInsights();
    this.cdr.markForCheck();
  }
  
  donutSegments: any[] = [];
  upcomingDeadlines: any[] = [];
  topSuppliers: any[] = [];

  quickInsights: any[] = [];
  
  allPendingPOsData: any[] = [];
  allApprovedPOsData: any[] = [];
  allTotalPRsData: any[] = [];
  allActiveRFQsData: any[] = [];
  allActiveSuppliersData: any[] = [];

  kpis = [
    {
      label: 'Purchase Requests',
      value: '0 Requisitions',
      trend: 0,
      trendDir: 'up' as 'up' | 'down',
      icon: 'bi-file-earmark-text',
      color: 'teal',
    },
    {
      label: 'RFQ Sent Out',
      value: '0 Queries',
      trend: 0,
      trendDir: 'up' as 'up' | 'down',
      icon: 'bi-envelope-check',
      color: 'info',
    },
    {
      label: 'Pending Purchase Orders',
      value: '0 Pending',
      trend: 0,
      trendDir: 'up' as 'up' | 'down',
      icon: 'bi-cart-check',
      color: 'warning',
    },
    {
      label: 'Budget Sourced',
      value: '0%',
      trend: 0,
      trendDir: 'up' as 'up' | 'down',
      icon: 'bi-wallet2',
      color: 'success',
    },
  ];

  costCategories: { label: string; value: number; pct: number; color?: string }[] = [];
  costTotal = 0;

  rfqs: any[] = [];
  shortages: any[] = [];
  notifications: any[] = [];
  recentPOs: PurchaseOrderResponseModel[] = [];

  loading = true;

  constructor(
    private storage: StorageService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private procurementService: ProcurementService,
    private prService: PurchaseRequisitionService,
    private quotationService: QuotationService,
    private productService: AddProductService,
    private poService: PurchaseOrderService,
    private invoiceService: InvoiceService,
    private notificationService: NotificationService,
    private supplierService: SupplierService,
    private shipmentService: ShipmentService,
    private poLineItemService: PoLineItemService,
      private reqService: ProductRequirementService
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) {
      return;
    }
    this.userRole = this.storage.getActiveRole()?.toUpperCase() || '';
    if (!this.userRole && user.role) {
      this.userRole = user.role.toUpperCase();
    }
    this.userName = user.name || 'Procurement Officer';
    this.userId = user.userId;
    this.newPr.requestedBy = this.userId;
    this.newPo.issuedBy = this.userId;
    this.newPo.issuedByName = this.userName;
    this.loadProcurement();
    this.loadDashboardData();
    this.loadNotifications();
  }

  // Opens the View All Modal with specific data
  openViewAllModal(title: string, type: string, data: any[]): void {
    this.viewAllModalTitle = title;
    this.viewAllModalType = type;
    this.viewAllModalData = data;
    this.modalSearchText = '';
    this.modalSearchDate = '';
    this.isViewAllModalOpen = true;
  }

  // Closes the View All Modal
  closeViewAllModal(): void {
    this.isViewAllModalOpen = false;
    this.modalSearchText = '';
    this.modalSearchDate = '';
  }

  // Dynamic filter for modal data
  get filteredModalData(): any[] {
    if (!this.viewAllModalData) return [];
    
    let filtered = this.viewAllModalData;
    
    // Filter by text search
    if (this.modalSearchText && this.modalSearchText.trim() !== '') {
      const searchLower = this.modalSearchText.toLowerCase().trim();
      filtered = filtered.filter(item => {
        // Deep stringify search across all object values
        const values = Object.values(item).join(' ').toLowerCase();
        return values.includes(searchLower);
      });
    }

    // Filter by date
    if (this.modalSearchDate) {
      filtered = filtered.filter(item => {
        // Check known date fields
        const dateStr = item.createdAt || item.date || item.createdAtDate || '';
        if (!dateStr) return false;
        
        // Match standard format YYYY-MM-DD
        return String(dateStr).startsWith(this.modalSearchDate);
      });
    }
    
    return filtered;
  }

  loadDashboardData() {
    let prCount = 0;
    let prApproved = 0;
    let rfqCount = 0;
    let poCount = 0;
    let poPending = 0;
    let totalSpend = 0;

    this.shipmentService.findAll().subscribe({
      next: (data) => {
        this.shipments = data || [];
        this.cdr.markForCheck();
      },
      error: (err) => console.error("Error loading shipments in procurement dashboard", err)
    });

    this.prService.findAll().subscribe({
      next: (data) => {
        this.rawPRs = data || [];
        this.aggregatePRs();
        this.buildCostAnalytics();
        this.cdr.markForCheck();
      },
    });

    this.quotationService.findAll().subscribe({
      next: (data) => {
        this.rawRFQs = data || [];
        this.aggregateRFQs();
        this.cdr.markForCheck();
      },
    });

    this.productService.findAll().subscribe({
      next: (data) => {
        this.rawProducts = data || [];
        this.aggregateProducts();
        this.cdr.markForCheck();
      },
    });

    this.poService.findAll().subscribe({
      next: (data) => {
        this.rawPOs = data || [];
        this.aggregatePOs();
        this.buildCostAnalytics();
        this.loading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.loading = false;
        this.cdr.markForCheck();
      },
    });

    this.invoiceService.findAll().subscribe({
      next: (data) => {
        const allInvoices = data || [];
        this.totalInvoices = allInvoices.length;
        const invoiceTotal = allInvoices.reduce(
          (sum: number, inv: any) => sum + (inv.totalAmount || 0),
          0,
        );
        if (invoiceTotal > totalSpend) {
          this.totalSpend = invoiceTotal;
        }
        this.cdr.markForCheck();
      },
    });

    this.poLineItemService.findAll().subscribe({
      next: (data) => {
        this.rawPoLineItems = data || [];
        this.cdr.markForCheck();
      }
    });

    // Dummy Data Initializations
    this.supplierService.findAll().subscribe({ next: (data) => { this.activeSuppliers = (data || []).length; }});
    this.allActiveSuppliersData = [
      { name: 'TechCorp Industries', rating: '4.8', activePOs: 3 },
      { name: 'Global Office Solutions', rating: '4.5', activePOs: 2 },
      { name: 'Apex Logistics', rating: '4.9', activePOs: 5 },
      { name: 'Quantum Materials', rating: '4.2', activePOs: 1 }
    ];

    this.upcomingDeadlines = [
      { item: 'Office Supplies Restock', type: 'PO-2024-001', date: '2024-09-15', urgency: 'High' },
      { item: 'IT Equipment Delivery', type: 'PO-2024-005', date: '2024-09-18', urgency: 'Medium' }
    ];

    this.topSuppliers = [
      { name: 'TechCorp Industries', amount: 45000, percentage: 65 },
      { name: 'Global Office Solutions', amount: 25000, percentage: 25 }
    ];

  }

  buildQuickInsights() {
    const insights = [];

    const prCount = this.allTotalPRsData.length;
    const prApproved = this.approvedPRs;
    const approvalRate = prCount > 0 ? Math.round((prApproved / prCount) * 100) : 0;
    insights.push({
      label: 'PR Approval Rate',
      value: `${approvalRate}%`,
      icon: 'bi-check2-circle'
    });

    const shortagesCount = this.shortages.length;
    insights.push({
      label: 'Critical Shortages',
      value: `${shortagesCount} Items`,
      icon: 'bi-exclamation-triangle'
    });

    insights.push({
      label: 'Pending Orders',
      value: `${this.pendingPOs} POs`,
      icon: 'bi-clock-history'
    });

    insights.push({
      label: 'Budget Sourced',
      value: this.kpis[3] ? this.kpis[3].value : '0%',
      icon: 'bi-wallet2'
    });

    this.quickInsights = insights.slice(0, 4);
  }

  buildCostAnalytics() {
    const categories = [
      { label: 'Sourcing Cost', key: 'sourcing', color: '#28a745' },
      { label: 'Logistics Cost', key: 'logistics', color: '#0d6efd' },
      { label: 'Material Cost', key: 'material', color: '#6f42c1' },
      { label: 'Other Cost', key: 'other', color: '#ffc107' },
    ];

    const poTotal = this.totalSpend;
    const values = [
      Math.round(poTotal * 0.35),
      Math.round(poTotal * 0.25),
      Math.round(poTotal * 0.25),
      Math.round(poTotal * 0.15),
    ];

    this.costTotal = poTotal;
    
    let cumulativePercent = 0;
    this.donutSegments = categories.map((c, i) => {
      const pct = poTotal > 0 ? Math.round((values[i] / poTotal) * 100) : 0;
      const strokeDasharray = `${pct} ${100 - pct}`;
      const strokeDashoffset = 25 - cumulativePercent;
      cumulativePercent += pct;
      return {
        label: c.label,
        value: values[i],
        pct: pct,
        color: c.color,
        dasharray: strokeDasharray,
        dashoffset: strokeDashoffset
      };
    });
    
    this.costCategories = this.donutSegments;
  }

  loadNotifications(): void {
    this.notificationService.findAll().subscribe({
      next: (data) => {
        this.notifications = (data || []).slice(0, 6);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }


  loadProcurement(): void {
    if (this.storage.getRole() === 'ADMIN') return;
    this.procurementService.getProcurementByUserId(this.userId).subscribe({
      next: (res) => {
        this.procurement = res;
        this.storage.saveData(KEYS.PROCUREMENT, res);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
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
        return 'bi-info-circle text-secondary';
    }
  }

  getNotificationTypeIcon(type: string): string {
    switch (type) {
      case 'SHIPMENT':
        return 'bi-truck';
      case 'TRIP_ALERT':
        return 'bi-exclamation-triangle';
      case 'REPORT_APPROVED':
        return 'bi-check-circle';
      default:
        return 'bi-bell';
    }
  }

  formatCurrency(amount: number): string {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(amount);
  }

  formatTime(dateStr: string): string {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    const now = new Date();
    const diff = now.getTime() - d.getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return 'Just now';
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    return `${Math.floor(hrs / 24)}d ago`;
  }

  // ================= SEARCH FILTERS FOR QUICK ACTION CARD TABLES =================
  get filteredQuotationsList(): any[] {
    if (!this.rawRFQs) return [];
    if (!this.directorySearchQuery || this.directorySearchQuery.trim() === '') return this.rawRFQs;
    const q = this.directorySearchQuery.toLowerCase().trim();
    return this.rawRFQs.filter((item: any) => {
      return (item.quotationNumber && item.quotationNumber.toLowerCase().includes(q)) ||
             (item.supplierName && item.supplierName.toLowerCase().includes(q)) ||
             (item.productName && item.productName.toLowerCase().includes(q)) ||
             (item.status && item.status.toLowerCase().includes(q));
    });
  }

  get filteredSuppliersList(): any[] {
    if (!this.prSuppliers) return [];
    if (!this.directorySearchQuery || this.directorySearchQuery.trim() === '') return this.prSuppliers;
    const q = this.directorySearchQuery.toLowerCase().trim();
    return this.prSuppliers.filter((item: any) => {
      return (item.name && item.name.toLowerCase().includes(q)) ||
             (item.email && item.email.toLowerCase().includes(q)) ||
             (item.phone && item.phone.toLowerCase().includes(q)) ||
             (item.address && item.address.toLowerCase().includes(q));
    });
  }

  get filteredInvoicesList(): any[] {
    if (!this.rawInvoices) return [];
    if (!this.directorySearchQuery || this.directorySearchQuery.trim() === '') return this.rawInvoices;
    const q = this.directorySearchQuery.toLowerCase().trim();
    return this.rawInvoices.filter((item: any) => {
      return (item.invoiceNumber && item.invoiceNumber.toLowerCase().includes(q)) ||
             (item.issuedToName && item.issuedToName.toLowerCase().includes(q)) ||
             (item.paymentStatus && item.paymentStatus.toLowerCase().includes(q)) ||
             (item.invoiceStatus && item.invoiceStatus.toLowerCase().includes(q));
    });
  }

  get filteredProductsList(): any[] {
    if (!this.rawProducts) return [];
    if (!this.directorySearchQuery || this.directorySearchQuery.trim() === '') return this.rawProducts;
    const q = this.directorySearchQuery.toLowerCase().trim();
    return this.rawProducts.filter((item: any) => {
      return (item.name && item.name.toLowerCase().includes(q)) ||
             (item.productCode && item.productCode.toLowerCase().includes(q)) ||
             (item.categoryName && item.categoryName.toLowerCase().includes(q));
    });
  }

  // ================= MODAL LOGIC =================
  loadModalData() {
    this.productService.findAll().subscribe((d: any) => this.prProducts = d || []);
    this.reqService.findAll().subscribe((d: any) => this.prRequirements = d || []);
    this.supplierService.findAll().subscribe((d: any) => this.prSuppliers = d || []);
    this.quotationService.findAll().subscribe((d: any) => {
      this.approvedQuotations = (d || []).filter((q: any) => q.status === 'APPROVED');
    });
    this.prService.findAll().subscribe((d: any) => {
      this.quoteRequisitions = (d || []).filter((pr: any) => pr.approvalStatus === 'APPROVED');
    });
  }

  openPrModal() {
    this.isPrModalOpen = true;
    this.modalSuccessMsg = '';
    this.modalErrorMsg = '';
    this.clearPrForm();
    this.loadModalData();
  }
  closePrModal() { this.isPrModalOpen = false; }

  onPrProductSelect(event: any) {
    const id = parseInt(event.target.value, 10);
    if (id > 0 && !this.newPr.productIds.includes(id)) {
      this.newPr.productIds.push(id);
      const prod = this.prProducts.find((p: any) => p.id === id);
      if (prod) this.selectedPrProducts.push(prod);
    }
  }

  removePrProduct(id: number) {
    this.newPr.productIds = this.newPr.productIds.filter((pid: number) => pid !== id);
    this.selectedPrProducts = this.selectedPrProducts.filter((p: any) => p.id !== id);
  }

  onPrSupplierSelect(event: any) {
    const id = parseInt(event.target.value, 10);
    if (id > 0 && !this.newPr.supplierIds.includes(id)) {
      this.newPr.supplierIds.push(id);
      const supplier = this.prSuppliers.find((s: any) => s.id === id);
      if (supplier) this.selectedPrSuppliers.push(supplier);
    }
  }

  removePrSupplier(id: number) {
    this.newPr.supplierIds = this.newPr.supplierIds.filter((sid: number) => sid !== id);
    this.selectedPrSuppliers = this.selectedPrSuppliers.filter((s: any) => s.id !== id);
  }

  clearPrForm() {
    this.newPr = {
      requestedBy: this.userId,
      productIds: [],
      supplierIds: [],
      currency: 'USD',
      quantityRequired: 1,
      urgencyLevel: 'LOW',
      requiredByDate: '',
      remarks: ''
    };
    this.selectedPrProducts = [];
    this.selectedPrSuppliers = [];
    this.modalSuccessMsg = '';
    this.modalErrorMsg = '';
  }

  submitPr() {
    this.prService.save(this.newPr).subscribe({
      next: () => {
        this.modalSuccessMsg = 'Purchase Requisition Created Successfully!';
        this.loadDashboardData();
        setTimeout(() => this.closePrModal(), 1500);
      },
      error: (e: any) => this.modalErrorMsg = e.error?.message || 'Failed to create PR.'
    });
  }

  openPoModal() {
    this.isPoModalOpen = true;
    this.clearPoForm();
    this.loadModalData();
  }
  closePoModal() { this.isPoModalOpen = false; }

  onQuotationChange(event: any) {
    const qId = parseInt(event.target.value, 10);
    this.newPo.quotationId = qId;
    const selectedQ = this.approvedQuotations.find((q: any) => q.id === qId) as any;
    if (selectedQ) {
      this.newPo.totalAmount = selectedQ.totalPrice || selectedQ.unitPrice * selectedQ.quantity;
      this.newPo.quantity = selectedQ.quantity;
      this.newPo.supplierName = selectedQ.supplierName || 'N/A';
      this.newPo.currency = (selectedQ.currency as string) || 'USD';

      // Try email from quotation first, fall back to prSuppliers list
      if (selectedQ.supplierEmail && selectedQ.supplierEmail.trim() !== '') {
        this.newPo.supplierEmail = selectedQ.supplierEmail;
      } else {
        const matchedSupplier = this.prSuppliers.find((s: any) => s.id === selectedQ.supplierId) as any;
        this.newPo.supplierEmail = matchedSupplier?.email || matchedSupplier?.supplierEmail || matchedSupplier?.contactEmail || 'N/A';
      }
    } else {
      this.newPo.supplierName = 'N/A';
      this.newPo.supplierEmail = 'N/A';
      this.newPo.currency = 'USD';
    }
  }

  clearPoForm() {
    this.newPo = {
      quotationId: 0,
      issuedBy: this.userId,
      totalAmount: 0,
      quantity: 1,
      currency: 'USD',
      expectedDeliveryDate: '',
      status: 'ISSUED',
      supplierName: 'N/A',
      supplierEmail: 'N/A',
      issuedByName: this.userName
    };
    this.poCreatedAt = new Date().toLocaleString();
    this.modalSuccessMsg = '';
    this.modalErrorMsg = '';
  }

  submitPo() {
    this.poService.save(this.newPo).subscribe({
      next: () => {
        this.modalSuccessMsg = 'Purchase Order Created Successfully!';
        this.loadDashboardData();
        setTimeout(() => this.closePoModal(), 1500);
      },
      error: (e: any) => this.modalErrorMsg = e.error?.message || 'Failed to create PO.'
    });
  }

  openQuotationModal() {
    this.isQuotationModalOpen = true;
    this.newQuotation = {
      supplierId: 0,
      purchaseRequisitionId: 0,
      leadTimeDays: 7,
      receivedAt: new Date().toISOString().split('T')[0],
      status: 'PENDING',
      productDescription: '',
      unitPrice: 0,
      quantity: 1,
      deliveryTime: '',
      warranty: '',
      notes: ''
    };
    this.modalSuccessMsg = '';
    this.modalErrorMsg = '';
    this.loadModalData();
  }
  closeQuotationModal() { this.isQuotationModalOpen = false; }

  submitQuotation() {
    this.quotationService.save(this.newQuotation, null).subscribe({
      next: () => {
        this.modalSuccessMsg = 'Quotation Registered Successfully!';
        this.loadDashboardData();
        setTimeout(() => this.closeQuotationModal(), 1500);
      },
      error: (e: any) => this.modalErrorMsg = e.error?.message || 'Failed to register Quotation.'
    });
  }

  updateQuotationStatus(id: number, status: string) {
    // Update locally first for instant UI response
    const target = (this.rawRFQs || []).find((q: any) => (q.id === id || q.quotationId === id));
    if (target) {
      target.status = status;
      this.rawRFQs = [...this.rawRFQs];
      this.cdr.markForCheck();
    }

    this.quotationService.updateStatus(id, status).subscribe({
      next: () => {
        this.quotationService.findAll().subscribe({
          next: (data) => {
            if (data && data.length > 0) {
              this.rawRFQs = data;
            }
            this.aggregateRFQs();
            this.cdr.markForCheck();
          }
        });
      },
      error: (err) => console.error("Failed to update status on server", err)
    });
  }

  
  showPoLineItemTable: boolean = false;
  
  get pendingPoLineItemsCount(): number {
    return this.rawPoLineItems ? this.rawPoLineItems.filter((item: any) => item.status === 'PENDING').length : 0;
  }

  selectTab(tab: string) {
    if (this.activeRfqTab === tab) {
      this.activeRfqTab = 'ALL';
      this.showPoLineItemTable = false;
    } else {
      this.activeRfqTab = tab;
      this.showPoLineItemTable = (tab === 'PO_LINE_ITEM');
    }
    this.cdr.markForCheck();
  }

  togglePoLineItemTable() {
    this.selectTab('PO_LINE_ITEM');
  }

  openTrackingModal() {
    this.isTrackingModalOpen = true;
    this.trackedPo = null;
    this.trackingPoNumberSearch = '';
    this.trackingSearchError = '';
    this.showPoSuggestions = false;
    this.cdr.markForCheck();
  }

  closeTrackingModal() {
    this.isTrackingModalOpen = false;
    this.showPoSuggestions = false;
    this.cdr.markForCheck();
  }

  get filteredPoSuggestions(): any[] {
    const query = (this.trackingPoNumberSearch || '').trim().toLowerCase();
    if (!query) {
      return (this.rawPOs || []).slice(0, 10);
    }
    return (this.rawPOs || []).filter(po => 
      po.poNumber && po.poNumber.toLowerCase().includes(query)
    );
  }

  selectPoSuggestion(po: any) {
    this.trackingPoNumberSearch = po.poNumber;
    this.trackedPo = po;
    this.trackingSearchError = '';
    this.showPoSuggestions = false;
    this.cdr.markForCheck();
  }

  onInputBlur() {
    setTimeout(() => {
      this.showPoSuggestions = false;
      this.cdr.markForCheck();
    }, 250);
  }

  trackPoByNumber() {
    this.trackingSearchError = '';
    this.trackedPo = null;
    const query = (this.trackingPoNumberSearch || '').trim().toLowerCase();
    if (!query) {
      this.trackingSearchError = 'Please enter a Purchase Order number.';
      this.cdr.markForCheck();
      return;
    }
    const found = (this.rawPOs || []).find(po => po.poNumber && po.poNumber.toLowerCase() === query);
    if (found) {
      this.trackedPo = found;
    } else {
      this.trackingSearchError = `No Purchase Order found with number "${this.trackingPoNumberSearch}".`;
    }
    this.cdr.markForCheck();
  }

  getTrackedPoShipment(): any {
    if (!this.trackedPo) return null;
    return (this.shipments || []).find(s => 
      Number(s.poId) === Number(this.trackedPo.id) ||
      (s.poNumber && String(s.poNumber).toLowerCase().trim() === String(this.trackedPo.poNumber).toLowerCase().trim())
    );
  }

  getTrackedPoShipments(): any[] {
    if (!this.trackedPo) return [];
    return (this.shipments || []).filter(s => 
      (s.poId && Number(s.poId) === Number(this.trackedPo.id)) ||
      (s.poNumber && String(s.poNumber).toLowerCase().trim() === String(this.trackedPo.poNumber).toLowerCase().trim())
    );
  }

  getPoStepIndex(status: string, hasShipment: boolean): number {
    if (!status) return 0;
    const s = status.toUpperCase();
    if (s === 'DRAFT') return 1;
    if (s === 'ISSUED') return 2;
    if (s === 'PARTIALLY_RECEIVED') return 3;
    if (s === 'RECEIVED') return 4;

    // Check PO Line Items to determine processing progress
    const lineItems = this.getTrackedPoLineItems();
    if (lineItems.length > 0) {
      const statuses = lineItems.map(item => (item.status || '').toUpperCase());
      if (statuses.includes('DELIVERED')) return 7;
      if (statuses.includes('SHIPPED')) return 6;
      if (statuses.includes('APPROVED')) return 5;
    }

    if (hasShipment || s === 'SHIPPED') return 6;
    if (s === 'COMPLETE' || s === 'APPROVED') return 7;
    if (s === 'CANCELLED') return 8;
    return 2;
  }

  getPoProgressPercentage(): number {
    if (!this.trackedPo || !this.trackedPo.quantity) return 0;
    const lineItemsForPo = this.getTrackedPoLineItems();
    const allocatedVolume = lineItemsForPo.reduce((sum, item) => sum + (item.quantity || 0), 0);
    const pct = (allocatedVolume / this.trackedPo.quantity) * 100;
    return Math.min(Math.round(pct), 100);
  }

  getTrackedPoLineItems(): any[] {
    if (!this.trackedPo) return [];
    return (this.rawPoLineItems || []).filter(item => 
      (item.poId && Number(item.poId) === Number(this.trackedPo.id)) ||
      (item.poNumber && String(item.poNumber).toLowerCase().trim() === String(this.trackedPo.poNumber).toLowerCase().trim())
    );
  }

  getTrackedPoAllocatedVolume(): number {
    return this.getTrackedPoLineItems().reduce((sum, item) => sum + (item.quantity || 0), 0);
  }

  getActiveStepsCount(): number {
    if (!this.trackedPo) return 0;
    let activeCount = 1; // DRAFT is always active
    const status = this.trackedPo.status?.toUpperCase() || '';
    if (['ISSUED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'COMPLETE', 'APPROVED'].includes(status)) {
      activeCount++;
    }
    if (['PARTIALLY_RECEIVED', 'RECEIVED', 'COMPLETE'].includes(status)) {
      activeCount++;
    }
    if (['RECEIVED', 'COMPLETE'].includes(status)) {
      activeCount++;
    }
    if (this.getTrackedPoLineItems().length > 0) {
      activeCount++;
    }
    if (this.getTrackedPoShipment()) {
      activeCount++;
    }
    if (['COMPLETE', 'RECEIVED'].includes(status) && this.getTrackedPoShipment()) {
      activeCount++;
    }
    return activeCount;
  }

  getOverallTrackingPercentage(): number {
    if (!this.trackedPo) return 0;
    const stepperProgress = (this.getActiveStepsCount() / 7) * 100;
    const allocationProgress = this.getPoProgressPercentage();
    return Math.min(Math.round((stepperProgress + allocationProgress) / 2), 100);
  }

  getRunningTotalVolume(index: number): number {
    if (!this.trackedPo || !this.trackedPo.quantity) return 0;
    const items = this.getTrackedPoLineItems();
    let remaining = this.trackedPo.quantity;
    for (let i = 0; i < index; i++) {
      remaining -= (items[i].quantity || 0);
    }
    return Math.max(remaining, 0);
  }

  getProcessedUnitsCount(): number {
    return this.getTrackedPoAllocatedVolume();
  }

  getShippedUnitsCount(): number {
    if (!this.trackedPo) return 0;

    // 1. Primary: Calculate by summing shipmentQuantity from Cargo Shipment entries linked to this PO
    const matchedShipments = this.getTrackedPoShipments();
    let totalFromShipments = 0;
    let hasExplicitShipmentQty = false;

    for (const s of matchedShipments) {
      const q = s.shipmentQuantity ?? s.quantity ?? s.quantityShipped ?? s.shippedQuantity;
      if (q !== undefined && q !== null && Number(q) > 0) {
        totalFromShipments += Number(q);
        hasExplicitShipmentQty = true;
      }
    }

    if (hasExplicitShipmentQty && totalFromShipments > 0) {
      return totalFromShipments;
    }

    // 2. Secondary fallback: Sum from PO Line Items that are SHIPPED, DELIVERED, or RECEIVED
    const lineItems = this.getTrackedPoLineItems();
    const shippedLineItems = lineItems.filter(item => 
      ['SHIPPED', 'DELIVERED', 'RECEIVED'].includes((item.status || '').toUpperCase())
    );

    if (shippedLineItems.length > 0) {
      return shippedLineItems.reduce((sum, item) => sum + (item.quantity || 0), 0);
    }

    // 3. Fallback: Check direct Cargo Shipment connection or PO status
    const directShipment = this.getTrackedPoShipment();
    const poStatus = (this.trackedPo.status || '').toUpperCase();

    if (directShipment || ['SHIPPED', 'RECEIVED', 'COMPLETE'].includes(poStatus)) {
      const allocated = this.getTrackedPoAllocatedVolume();
      return allocated > 0 ? allocated : (this.trackedPo.quantity || 0);
    }

    return 0;
  }

  getShippedProgressPercentage(): number {
    if (!this.trackedPo || !this.trackedPo.quantity || this.trackedPo.quantity <= 0) return 0;
    const shippedQty = this.getShippedUnitsCount();
    if (shippedQty <= 0) return 0;
    const pct = (shippedQty / this.trackedPo.quantity) * 100;
    return Math.min(Math.round(pct), 100);
  }

  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
  }
}



