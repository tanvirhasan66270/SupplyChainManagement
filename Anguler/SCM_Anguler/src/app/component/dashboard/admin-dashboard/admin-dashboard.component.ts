import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Observable } from 'rxjs';
import { RouterModule, Router } from '@angular/router';
import { StorageService } from '../../../auth/auth_service/storage.service';
import { LoginResponse } from '../../../auth/Model/authModel';
import { DashboardService } from '../../../service/dashboard.service';
import { CustomerService } from '../../../service/customer.service';
import { SupplierService } from '../../../service/supplier.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { InvoiceService } from '../../../service/invoice.service';
import { WarehouseService } from '../../../service/warehouse.service';
import { DeliveryTripService } from '../../../service/delivery-trip.service';
import { ShipmentService } from '../../../service/shipment.service';
import { InventoryService } from '../../../service/inventory.service';
import { AddProductService } from '../../../service/add-product.service';
import { DriverService } from '../../../service/driver.service';
import { ManagerService } from '../../../service/manager.service';
import { LogisticsOfficerService } from '../../../service/logistics-officer.service';
import { CommercialOfficerService } from '../../../service/commercial-officer.service';
import { SalesOfficerService } from '../../../service/sales-officer.service';
import { QcInspectorService } from '../../../service/qc-inspactor.service';
import { ProcurementService } from '../../../service/procourment.service';
import { AdminService } from '../../../service/admin.service';
import { NotificationService } from '../../../system/service/notification.service';
import { ActivityLogService } from '../../../service/activity.log.service';
import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';

interface SystemCard {
  title: string;
  value: string;
  subValue: string;
  icon: string;
  color: string;
  gradient: string;
  route: string;
  trend: number;
  details: { label: string; value: string }[];
}

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, DashboardSettingsComponent],
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css'],
})
export class AdminDashboardComponent implements OnInit {
  userName = '';
  showSettings = false;
  isLoading = true;
  currentTime = new Date();

  systemCards: SystemCard[] = [];
  activityCards: { title: string; value: number; sub: string; icon: string; color: string; gradient: string; route: string }[] = [];
  allModules: { name: string; route: string; icon: string; color: string; count: number; status: string }[] = [];

  notifications: any[] = [];
  activities: any[] = [];

  // ── Activity Search ──
  allActivities: any[] = [];
  filteredActivities: any[] = [];
  activitySearchText = '';
  activityFilter = 'ALL';
  isLoadingActivities = false;

  totalUsers = 0;
  totalRevenue = 0;
  totalExpenses = 0;
  totalOrders = 0;

  // ── Role-Based User Search ──
  selectedRole = '';
  searchText = '';
  allUsers: any[] = [];
  filteredUsers: any[] = [];
  isLoadingUsers = false;
  selectedUser: any = null;
  showUserDetail = false;

  roleOptions = [
    { value: '', label: '--- Select Role ---', icon: 'bi-people' },
    { value: 'ALL', label: 'All Roles', icon: 'bi-people' },
    { value: 'ADMIN', label: 'Admin', icon: 'bi-shield-lock' },
    { value: 'MANAGER', label: 'Manager', icon: 'bi-person-gear' },
    { value: 'CUSTOMER', label: 'Customer', icon: 'bi-person' },
    { value: 'SUPPLIER', label: 'Supplier', icon: 'bi-truck' },
    { value: 'DRIVER', label: 'Driver', icon: 'bi-person-badge' },
    { value: 'PROCUREMENT', label: 'Procurement', icon: 'bi-clipboard-check' },
    { value: 'QC_INSPECTOR', label: 'QC Inspector', icon: 'bi-search' },
    { value: 'LOGISTICS_OFFICER', label: 'Logistics Officer', icon: 'bi-box-seam' },
    { value: 'COMMERCIAL_OFFICER', label: 'Commercial Officer', icon: 'bi-building' },
    { value: 'SALES_OFFICER', label: 'Sales Officer', icon: 'bi-graph-up' },
  ];

  activityFilterOptions = [
    { value: 'ALL', label: 'All Actions' },
    { value: 'CREATE', label: 'Create' },
    { value: 'UPDATE', label: 'Update' },
    { value: 'DELETE', label: 'Delete' },
    { value: 'LOGIN', label: 'Login' },
  ];

  constructor(
    private storage: StorageService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private dashboardService: DashboardService,
    private customerService: CustomerService,
    private supplierService: SupplierService,
    private poService: PurchaseOrderService,
    private prService: PurchaseRequisitionService,
    private invoiceService: InvoiceService,
    private warehouseService: WarehouseService,
    private deliveryTripService: DeliveryTripService,
    private shipmentService: ShipmentService,
    private inventoryService: InventoryService,
    private productService: AddProductService,
    private driverService: DriverService,
    private managerService: ManagerService,
    private logisticsOfficerService: LogisticsOfficerService,
    private commercialOfficerService: CommercialOfficerService,
    private salesOfficerService: SalesOfficerService,
    private qcInspectorService: QcInspectorService,
    private procurementService: ProcurementService,
    private adminService: AdminService,
    private notificationService: NotificationService,
    private activityLogService: ActivityLogService,
    
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) {
      return;
    }
    this.userName = user.name;
    this.loadAllData();
    this.startClock();
  }

  startClock(): void {
    setInterval(() => {
      this.currentTime = new Date();
    }, 1000);
  }

  loadAllData(): void {
    this.isLoading = true;
    let completed = 0;
    const totalCalls = 12;
    const checkDone = () => {
      completed++;
      if (completed >= totalCalls) {
        this.isLoading = false;
        this.buildSystemCards();
        this.buildModulesList();
        this.cdr.markForCheck();
      }
    };

    this.loadCustomers(checkDone);
    this.loadSuppliers(checkDone);
    this.loadPurchaseOrders(checkDone);
    this.loadPurchaseRequisitions(checkDone);
    this.loadInvoices(checkDone);
    this.loadWarehouses(checkDone);
    this.loadDeliveryTrips(checkDone);
    this.loadShipments(checkDone);
    this.loadInventory(checkDone);
    this.loadProducts(checkDone);
    this.loadDrivers(checkDone);
    this.loadActivities(checkDone);
  }

  loadCustomers(done: () => void): void {
    this.customerService.getAll().subscribe({
      next: (data) => {
        const all = data || [];
        const active = all.filter((c: any) => c.active !== false);
        this.totalUsers += all.length;
        this.allModules.push({
          name: 'Customers',
          route: '/order',
          icon: 'bi-people',
          color: 'primary',
          count: all.length,
          status: `${active.length} active`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadSuppliers(done: () => void): void {
    this.supplierService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        const active = all.filter((s: any) => s.active !== false);
        this.totalUsers += all.length;
        this.allModules.push({
          name: 'Suppliers',
          route: '/supplier',
          icon: 'bi-truck',
          color: 'success',
          count: all.length,
          status: `${active.length} active`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadPurchaseOrders(done: () => void): void {
    this.poService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        const draft = all.filter((o: any) => o.status === 'DRAFT');
        const issued = all.filter((o: any) => o.status === 'ISSUED');
        const received = all.filter((o: any) => o.status === 'RECEIVED');
        this.totalExpenses = all.reduce((sum: number, o: any) => sum + (o.totalAmount || 0), 0);
        this.allModules.push({
          name: 'Purchase Orders',
          route: '/purchase-order',
          icon: 'bi-cart-check',
          color: 'warning',
          count: all.length,
          status: `${draft.length} draft, ${issued.length} issued`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadPurchaseRequisitions(done: () => void): void {
    this.prService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        const pending = all.filter((r: any) => r.approvalStatus === 'PENDING');
        this.allModules.push({
          name: 'Requisitions',
          route: '/purchase-requisition',
          icon: 'bi-clipboard-check',
          color: 'info',
          count: all.length,
          status: `${pending.length} pending`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadInvoices(done: () => void): void {
    this.invoiceService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        const issued = all.filter((i: any) => i.invoiceStatus === 'ISSUED');
        this.totalRevenue = all
          .filter((i: any) => i.invoiceStatus === 'ISSUED')
          .reduce((sum: number, i: any) => sum + (i.totalAmount || 0), 0);
        this.allModules.push({
          name: 'Invoices',
          route: '/invoice',
          icon: 'bi-receipt',
          color: 'purple',
          count: all.length,
          status: `${issued.length} issued`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadWarehouses(done: () => void): void {
    this.warehouseService.getAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allModules.push({
          name: 'Warehouses',
          route: '/warehouse',
          icon: 'bi-building',
          color: 'dark',
          count: all.length,
          status: `${all.length} operational`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadDeliveryTrips(done: () => void): void {
    this.deliveryTripService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        const delivered = all.filter((t: any) => t.status === 'DELIVERED');
        this.allModules.push({
          name: 'Delivery Trips',
          route: '/delivery-trip',
          icon: 'bi-truck',
          color: 'success',
          count: all.length,
          status: `${delivered.length} delivered`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadShipments(done: () => void): void {
    this.shipmentService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allModules.push({
          name: 'Shipments',
          route: '/shipment',
          icon: 'bi-box-seam',
          color: 'primary',
          count: all.length,
          status: `${all.length} tracked`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadInventory(done: () => void): void {
    this.inventoryService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allModules.push({
          name: 'Inventory',
          route: '/inventory',
          icon: 'bi-boxes',
          color: 'warning',
          count: all.length,
          status: `${all.length} items`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadProducts(done: () => void): void {
    this.productService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allModules.push({
          name: 'Products',
          route: '/product',
          icon: 'bi-tags',
          color: 'info',
          count: all.length,
          status: `${all.length} cataloged`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadDrivers(done: () => void): void {
    this.driverService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.totalUsers += all.length;
        this.allModules.push({
          name: 'Drivers',
          route: '/driver',
          icon: 'bi-person-badge',
          color: 'danger',
          count: all.length,
          status: `${all.length} registered`,
        });
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadActivities(done: () => void): void {
    this.activityLogService.findAll().subscribe({
      next: (data) => {
        this.allActivities = (data || []).sort(
          (a: any, b: any) => new Date(b.performedAt).getTime() - new Date(a.performedAt).getTime()
        );
        this.filteredActivities = [...this.allActivities];
        this.buildActivityCards();
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  buildActivityCards(): void {
    const total = this.allActivities.length;
    const creates = this.allActivities.filter((a: any) => a.action === 'CREATE').length;
    const updates = this.allActivities.filter((a: any) => a.action === 'UPDATE').length;
    const deletes = this.allActivities.filter((a: any) => a.action === 'DELETE').length;
    const logins = this.allActivities.filter((a: any) => a.action === 'LOGIN').length;
    const success = this.allActivities.filter((a: any) => a.actionStatus === 'SUCCESS').length;
    const failed = this.allActivities.filter((a: any) => a.actionStatus === 'FAILED').length;

    const today = new Date().toDateString();
    const todayCount = this.allActivities.filter((a: any) => new Date(a.performedAt).toDateString() === today).length;

    const thisWeek = new Date();
    thisWeek.setDate(thisWeek.getDate() - 7);
    const weekCount = this.allActivities.filter((a: any) => new Date(a.performedAt) >= thisWeek).length;

    const uniqueModules = [...new Set(this.allActivities.map((a: any) => a.module))].length;
    const uniqueUsers = [...new Set(this.allActivities.map((a: any) => a.userId))].length;

    this.activityCards = [
      {
        title: 'Total Activities',
        value: total,
        sub: 'all time',
        icon: 'bi-activity',
        color: '#4f63f0',
        gradient: 'linear-gradient(135deg, #4f63f0, #6366f1)',
        route: '/activity-log',
      },
      {
        title: 'Today',
        value: todayCount,
        sub: 'activities today',
        icon: 'bi-calendar-check',
        color: '#0ea5e9',
        gradient: 'linear-gradient(135deg, #0ea5e9, #38bdf8)',
        route: '/activity-log',
      },
      {
        title: 'This Week',
        value: weekCount,
        sub: 'last 7 days',
        icon: 'bi-calendar-week',
        color: '#8b5cf6',
        gradient: 'linear-gradient(135deg, #8b5cf6, #a78bfa)',
        route: '/activity-log',
      },
      {
        title: 'Creates',
        value: creates,
        sub: 'new records',
        icon: 'bi-plus-circle',
        color: '#10b981',
        gradient: 'linear-gradient(135deg, #10b981, #34d399)',
        route: '/activity-log',
      },
      {
        title: 'Updates',
        value: updates,
        sub: 'modifications',
        icon: 'bi-pencil-square',
        color: '#f59e0b',
        gradient: 'linear-gradient(135deg, #f59e0b, #fbbf24)',
        route: '/activity-log',
      },
      {
        title: 'Deletes',
        value: deletes,
        sub: 'removed records',
        icon: 'bi-trash',
        color: '#ef4444',
        gradient: 'linear-gradient(135deg, #ef4444, #f87171)',
        route: '/activity-log',
      },
      {
        title: 'Logins',
        value: logins,
        sub: 'auth sessions',
        icon: 'bi-box-arrow-in-right',
        color: '#06b6d4',
        gradient: 'linear-gradient(135deg, #06b6d4, #22d3ee)',
        route: '/activity-log',
      },
      {
        title: 'Failed',
        value: failed,
        sub: 'errors',
        icon: 'bi-exclamation-triangle',
        color: '#dc2626',
        gradient: 'linear-gradient(135deg, #dc2626, #ef4444)',
        route: '/activity-log',
      },
      {
        title: 'Modules',
        value: uniqueModules,
        sub: 'active modules',
        icon: 'bi-grid',
        color: '#059669',
        gradient: 'linear-gradient(135deg, #059669, #10b981)',
        route: '/activity-log',
      },
      {
        title: 'Active Users',
        value: uniqueUsers,
        sub: 'participating users',
        icon: 'bi-people',
        color: '#7c3aed',
        gradient: 'linear-gradient(135deg, #7c3aed, #8b5cf6)',
        route: '/activity-log',
      },
    ];
  }

  buildSystemCards(): void {
    this.totalOrders = this.allModules.find(m => m.name === 'Purchase Orders')?.count || 0;

    this.systemCards = [
      {
        title: 'Total Users',
        value: `${this.totalUsers}`,
        subValue: 'across all roles',
        icon: 'bi-people-fill',
        color: '#4f63f0',
        gradient: 'linear-gradient(135deg, #4f63f0, #6366f1)',
        route: '/admin',
        trend: 0,
        details: [
          { label: 'Customers', value: `${this.allModules.find(m => m.name === 'Customers')?.count || 0}` },
          { label: 'Suppliers', value: `${this.allModules.find(m => m.name === 'Suppliers')?.count || 0}` },
          { label: 'Drivers', value: `${this.allModules.find(m => m.name === 'Drivers')?.count || 0}` },
        ],
      },
      {
        title: 'Total Revenue',
        value: `৳${this.formatNumber(this.totalRevenue)}`,
        subValue: 'from issued invoices',
        icon: 'bi-currency-dollar',
        color: '#10b981',
        gradient: 'linear-gradient(135deg, #10b981, #34d399)',
        route: '/invoice',
        trend: 0,
        details: [
          { label: 'Invoices', value: `${this.allModules.find(m => m.name === 'Invoices')?.count || 0}` },
          { label: 'Total Spend', value: `৳${this.formatNumber(this.totalExpenses)}` },
        ],
      },
      {
        title: 'Purchase Orders',
        value: `${this.totalOrders}`,
        subValue: 'total orders',
        icon: 'bi-cart-check-fill',
        color: '#f59e0b',
        gradient: 'linear-gradient(135deg, #f59e0b, #fbbf24)',
        route: '/purchase-order',
        trend: 0,
        details: [
          { label: 'Expenses', value: `৳${this.formatNumber(this.totalExpenses)}` },
          { label: 'Requisitions', value: `${this.allModules.find(m => m.name === 'Requisitions')?.count || 0}` },
        ],
      },
      {
        title: 'Inventory Items',
        value: `${this.allModules.find(m => m.name === 'Inventory')?.count || 0}`,
        subValue: 'stock items tracked',
        icon: 'bi-box-seam-fill',
        color: '#8b5cf6',
        gradient: 'linear-gradient(135deg, #8b5cf6, #a78bfa)',
        route: '/inventory',
        trend: 0,
        details: [
          { label: 'Products', value: `${this.allModules.find(m => m.name === 'Products')?.count || 0}` },
          { label: 'Warehouses', value: `${this.allModules.find(m => m.name === 'Warehouses')?.count || 0}` },
        ],
      },
      {
        title: 'Shipments',
        value: `${this.allModules.find(m => m.name === 'Shipments')?.count || 0}`,
        subValue: 'shipments tracked',
        icon: 'bi-truck',
        color: '#0ea5e9',
        gradient: 'linear-gradient(135deg, #0ea5e9, #38bdf8)',
        route: '/shipment',
        trend: 0,
        details: [
          { label: 'Deliveries', value: `${this.allModules.find(m => m.name === 'Delivery Trips')?.count || 0}` },
        ],
      },
      {
        title: 'System Health',
        value: '100%',
        subValue: 'all modules operational',
        icon: 'bi-shield-check',
        color: '#10b981',
        gradient: 'linear-gradient(135deg, #059669, #10b981)',
        route: '/activity-log',
        trend: 0,
        details: [
          { label: 'Modules', value: `${this.allModules.length}` },
          { label: 'Status', value: 'Online' },
        ],
      },
    ];
  }

  buildModulesList(): void {
    this.allModules.sort((a, b) => b.count - a.count);
  }

  formatNumber(num: number): string {
    if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
    if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
    return num.toLocaleString();
  }

  getModuleColorClass(color: string): string {
    const map: Record<string, string> = {
      primary: 'bg-primary-subtle text-primary',
      success: 'bg-success-subtle text-success',
      warning: 'bg-warning-subtle text-warning',
      danger: 'bg-danger-subtle text-danger',
      info: 'bg-info-subtle text-info',
      purple: 'bg-purple-subtle text-purple',
      dark: 'bg-dark-subtle text-dark',
    };
    return map[color] || 'bg-secondary-subtle text-secondary';
  }

  getStatusDotColor(status: string): string {
    if (status.includes('pending')) return 'bg-warning';
    if (status.includes('active') || status.includes('operational') || status.includes('delivered')) return 'bg-success';
    return 'bg-info';
  }

  getActionIcon(action: string): string {
    const map: Record<string, string> = {
      CREATE: 'bi-plus-circle text-success',
      UPDATE: 'bi-pencil-square text-primary',
      DELETE: 'bi-trash text-danger',
      LOGIN: 'bi-box-arrow-in-right text-info',
    };
    return map[action] || 'bi-circle text-secondary';
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

  abs(value: number): number {
    return Math.abs(value);
  }

  // ── Role-Based User Search Methods ──

  onRoleChange(): void {
    this.searchText = '';
    this.loadUsersByRole();
  }

  loadUsersByRole(): void {
    this.isLoadingUsers = true;
    this.searchText = '';
    this.allUsers = [];
    this.filteredUsers = [];
    this.cdr.markForCheck();

    const role = this.selectedRole;

    if (!role || role === '') {
      this.allUsers = [];
      this.filteredUsers = [];
      this.isLoadingUsers = false;
      this.cdr.markForCheck();
      return;
    }

    if (role === 'ALL') {
      this.loadAllUsers();
      return;
    }

    this.loadUsersBySpecificRole(role);
  }

  loadAllUsers(): void {
    let totalLoaded = 0;
    const totalServices = 10;
    const allData: any[] = [];

    const checkDone = () => {
      totalLoaded++;
      if (totalLoaded >= totalServices) {
        this.allUsers = allData;
        this.applySearchFilter();
        this.isLoadingUsers = false;
        this.cdr.markForCheck();
      }
    };

    this.customerService.getAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'CUSTOMER', _roleColor: 'primary' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.supplierService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'SUPPLIER', _roleColor: 'success' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.driverService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'DRIVER', _roleColor: 'danger' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.managerService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'MANAGER', _roleColor: 'warning' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.logisticsOfficerService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'LOGISTICS_OFFICER', _roleColor: 'info' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.commercialOfficerService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'COMMERCIAL_OFFICER', _roleColor: 'purple' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.salesOfficerService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'SALES_OFFICER', _roleColor: 'dark' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.qcInspectorService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'QC_INSPECTOR', _roleColor: 'secondary' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.procurementService.findAll().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'PROCUREMENT', _roleColor: 'info' }));
        checkDone();
      },
      error: () => checkDone(),
    });

    this.adminService.getAllAdmins().subscribe({ next: (data) => {
        (data || []).forEach((u: any) => allData.push({ ...u, _roleLabel: 'ADMIN', _roleColor: 'danger' }));
        checkDone();
      },
      error: () => checkDone(),
    });
  }

  loadUsersBySpecificRole(role: string): void {
    const serviceMap: Record<string, Observable<any[]>> = {
      ADMIN: this.adminService.getAllAdmins(),
      MANAGER: this.managerService.findAll(),
      CUSTOMER: this.customerService.getAll(),
      SUPPLIER: this.supplierService.findAll(),
      DRIVER: this.driverService.findAll(),
      PROCUREMENT: this.procurementService.findAll(),
      QC_INSPECTOR: this.qcInspectorService.findAll(),
      LOGISTICS_OFFICER: this.logisticsOfficerService.findAll(),
      COMMERCIAL_OFFICER: this.commercialOfficerService.findAll(),
      SALES_OFFICER: this.salesOfficerService.findAll(),
    };

    const service = serviceMap[role];
    if (!service) {
      this.isLoadingUsers = false;
      this.cdr.markForCheck();
      return;
    }

    service.subscribe({ next: (data) => {
        this.allUsers = (data || []).map((u: any) => ({
          ...u,
          _roleLabel: role,
          _roleColor: this.getRoleColor(role) }));
        this.applySearchFilter();
        this.isLoadingUsers = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.allUsers = [];
        this.filteredUsers = [];
        this.isLoadingUsers = false;
        this.cdr.markForCheck();
      },
    });
  }

  applySearchFilter(): void {
    const term = this.searchText.toLowerCase().trim();
    if (!term) {
      this.filteredUsers = [...this.allUsers];
    } else {
      this.filteredUsers = this.allUsers.filter((u) => {
        const name = (u.name || u.driverName || '').toLowerCase();
        const email = (u.email || '').toLowerCase();
        const phone = (u.phone || '').toLowerCase();
        return name.includes(term) || email.includes(term) || phone.includes(term);
      });
    }
  }

  onSearchChange(): void {
    this.applySearchFilter();
  }

  getRoleColor(role: string): string {
    const map: Record<string, string> = {
      ADMIN: 'danger',
      MANAGER: 'warning',
      CUSTOMER: 'primary',
      SUPPLIER: 'success',
      DRIVER: 'danger',
      PROCUREMENT: 'info',
      QC_INSPECTOR: 'secondary',
      LOGISTICS_OFFICER: 'info',
      COMMERCIAL_OFFICER: 'purple',
      SALES_OFFICER: 'dark',
    };
    return map[role] || 'secondary';
  }

  getUserDisplayName(u: any): string {
    return u.name || u.driverName || 'N/A';
  }

  viewUserDetail(user: any): void {
    this.selectedUser = user;
    this.showUserDetail = true;
    this.cdr.markForCheck();
  }

  closeUserDetail(): void {
    this.selectedUser = null;
    this.showUserDetail = false;
    this.cdr.markForCheck();
  }

  // ── Activity Search Methods ──

  onActivitySearchChange(): void {
    this.applyActivityFilter();
  }

  onActivityFilterChange(): void {
    this.activitySearchText = '';
    this.applyActivityFilter();
  }

  applyActivityFilter(): void {
    const term = this.activitySearchText.toLowerCase().trim();
    const actionFilter = this.activityFilter;

    this.filteredActivities = this.allActivities.filter((log: any) => {
      const matchesAction = actionFilter === 'ALL' || log.action === actionFilter;

      const matchesSearch =
        !term ||
        (log.action || '').toLowerCase().includes(term) ||
        (log.module || '').toLowerCase().includes(term) ||
        (log.description || '').toLowerCase().includes(term) ||
        (log.userEmail || '').toLowerCase().includes(term) ||
        (log.referenceId || '').toLowerCase().includes(term);

      return matchesAction && matchesSearch;
    });
  }

  resetActivityFilters(): void {
    this.activitySearchText = '';
    this.activityFilter = 'ALL';
    this.filteredActivities = [...this.allActivities];
    this.cdr.markForCheck();
  }

  resetUserFilters(): void {
    this.selectedRole = '';
    this.searchText = '';
    this.allUsers = [];
    this.filteredUsers = [];
    this.isLoadingUsers = false;
    this.cdr.markForCheck();
  }

  getActivityStatusCount(status: string): number {
    return this.allActivities.filter((a: any) => a.actionStatus === status).length;
  }

  navigateTo(route: string): void {
    this.router.navigate([route]);
  }

  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
  }
}
