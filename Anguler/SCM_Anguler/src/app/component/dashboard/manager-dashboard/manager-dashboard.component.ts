import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { KEYS, StorageService } from '../../../auth/auth_service/storage.service';
import { ManagerResponseModel } from '../../shared/model/manager';
import { ManagerService } from '../../../service/manager.service';
import { LoginResponse } from '../../../auth/Model/authModel';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { InvoiceService } from '../../../service/invoice.service';
import { WarehouseService } from '../../../service/warehouse.service';
import { DeliveryTripService } from '../../../service/delivery-trip.service';
import { QcInspectionService } from '../../../service/qc-inspection.service';
import { InventoryService } from '../../../service/inventory.service';
import { ShipmentService } from '../../../service/shipment.service';
import { NotificationService } from '../../../system/service/notification.service';
import { ActivityLogService } from '../../../service/activity.log.service';
import { GoodRecivedNoteService } from '../../../service/good-recived-note.service';
import { DailyReportService } from '../../../service/daley-report.service';
import { SupplierService } from '../../../service/supplier.service';
import { NotificationModel } from '../../../system/NotificationModel';
import { DailyReportResponseModel } from '../../shared/model/daley-report';
import { ActivityLogModel } from '../../shared/model/ActivityLogModel';
import { GoodsReceivedNoteResponseModel } from '../../shared/model/goodRecivedNoteModel';
import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-manager-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, DashboardSettingsComponent, FormsModule],
  templateUrl: './manager-dashboard.component.html',
  styleUrls: ['./manager-dashboard.component.css'],
})
export class ManagerDashboardComponent implements OnInit {
  userName = '';
  showSettings = false;
  isLoading = true;

  kpis = [
    { label: 'Total Revenue', value: '৳0', trend: 0, icon: 'bi-graph-up-arrow', color: 'success' },
    {
      label: 'Pending Approvals',
      value: '0',
      trend: 0,
      icon: 'bi-shield-exclamation',
      color: 'warning',
    },
    { label: 'Active Warehouses', value: '0', trend: 0, icon: 'bi-building', color: 'info' },
    { label: 'Total Invoices', value: '0', trend: 0, icon: 'bi-receipt', color: 'primary' },
  ];

  totalRevenue = 0;
  totalExpenses = 0;
  pendingApprovalsCount = 0;
  warehouseCount = 0;

  approvals: any[] = [];
  pendingPOs: any[] = [];
  grns: GoodsReceivedNoteResponseModel[] = [];
  grnStatusSaving: number | null = null;
  notifications: NotificationModel[] = [];
  activities: ActivityLogModel[] = [];



  lowStockItems: any[] = [];
  activeShipments: any[] = [];
  filteredShipments: any[] = [];
  shipmentSearchTerm: string = '';
  dailyReports: DailyReportResponseModel[] = [];
  failedQCCount = 0;
  supplierCount = 0;

  activeShortcut: string | null = null;
  searchQuery: string = '';
  monthQuery: string = 'All Months';
  dateQuery: string = '';
  activeTableTab: string = 'APPROVALS';

  purchaseRequisitions: any[] = []; 
filteredRequisitions: any[] = [];

  allWarehouses: any[] = [];
  allSuppliers: any[] = [];
  allInventory: any[] = [];
  allPrs: any[] = [];
  allReports: any[] = [];
  allActivities: any[] = [];

  deptPerformance = [
    { name: 'Sourcing & SCM', score: 0, color: 'success' },
    { name: 'Logistics & Fleet', score: 0, color: 'primary' },
    { name: 'Quality Control', score: 0, color: 'purple' },
    { name: 'Commercial Imports', score: 0, color: 'warning' },
  ];

  chartMonths: string[] = [];
  chartRevenue: number[] = [];
  chartExpenses: number[] = [];
  chartMax = 1;

  userId!: number;
  manager: ManagerResponseModel | null = null;
  user: LoginResponse | null = null;

  constructor(
    private storage: StorageService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private managerService: ManagerService,
    private prService: PurchaseRequisitionService,
    private poService: PurchaseOrderService,
    private invoiceService: InvoiceService,
    private warehouseService: WarehouseService,
    private deliveryTripService: DeliveryTripService,
    private qcService: QcInspectionService,
    private inventoryService: InventoryService,
    private shipmentService: ShipmentService,
    private notificationService: NotificationService,
    private activityLogService: ActivityLogService,
    private grnService: GoodRecivedNoteService,
    private dailyReportService: DailyReportService,
    private supplierService: SupplierService,
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) {
      return;
    }
    this.userName = user.name;
    this.userId = user.userId;
    this.loadManager();
    this.loadAllData();
  }


  filterTable() {
  const query = this.searchQuery.toLowerCase().trim();
  
  if (!query) {
    this.filteredRequisitions = [...this.purchaseRequisitions];
    return;
  }

  this.filteredRequisitions = this.purchaseRequisitions.filter(item => {
    return (item.prid?.toLowerCase().includes(query)) ||
           (item.requesterName?.toLowerCase().includes(query)) ||
           (item.status?.toLowerCase().includes(query));
  });
}

  getNotificationIcon(notif: any): string {
    const t = (notif.type || '').toUpperCase();
    if (t.includes('PURCHASE_REQUISITION') || t.includes('PRQ') || notif.title?.includes('Purchase Requisition')) return 'bi-clipboard-check';
    if (t.includes('PURCHASE_ORDER') || t.includes('PO') || notif.title?.includes('Purchase Order')) return 'bi-cart-check';
    if (t.includes('SHIPMENT')) return 'bi-truck';
    if (t.includes('TRIP')) return 'bi-exclamation-triangle';
    if (t.includes('REPORT') || t.includes('APPROVED')) return 'bi-check-circle';
    if (t.includes('INVOICE') || t.includes('PAYMENT')) return 'bi-receipt';
    if (t.includes('WAREHOUSE') || t.includes('STOCK') || t.includes('INVENTORY')) return 'bi-box-seam';
    return 'bi-bell';
  }

  getNotificationColorClass(notif: any): string {
    const t = (notif.type || '').toUpperCase();
    if (t.includes('PURCHASE_REQUISITION') || t.includes('PRQ') || notif.title?.includes('Purchase Requisition')) return 'bg-info-subtle text-info';
    if (t.includes('PURCHASE_ORDER') || t.includes('PO') || notif.title?.includes('Purchase Order')) return 'bg-primary-subtle text-primary';
    if (t.includes('SHIPMENT')) return 'bg-success-subtle text-success';
    if (t.includes('TRIP') || t.includes('ALERT') || t.includes('WARNING')) return 'bg-warning-subtle text-warning';
    if (t.includes('REPORT') || t.includes('APPROVED')) return 'bg-success-subtle text-success';
    if (t.includes('INVOICE') || t.includes('PAYMENT')) return 'bg-danger-subtle text-danger';
    if (t.includes('WAREHOUSE') || t.includes('STOCK') || t.includes('INVENTORY')) return 'bg-secondary-subtle text-secondary';
    return 'bg-primary-subtle text-primary';
  }

  loadAllData(): void {
    this.isLoading = true;
    let completed = 0;
    // 🎯 টোটাল কল ১৪ করা হলো (Supplier সহ)
    const totalCalls = 14;
    const checkDone = () => {
      completed++;
      if (completed >= totalCalls) {
        this.isLoading = false;
        this.buildChartData();
        this.cdr.markForCheck();
      }
    };

    this.loadPurchaseRequisitions(checkDone);
    this.loadPurchaseOrders(checkDone);
    this.loadInvoices(checkDone);
    this.loadWarehouses(checkDone);
    this.loadDeliveryTrips(checkDone);
    this.loadQcInspections(checkDone);
    this.loadNotifications(checkDone);
    this.loadActivityLogs(checkDone);
    this.loadGRNs(checkDone);
    this.loadInventoryData(checkDone);
    this.loadShipmentsData(checkDone);
    this.loadDailyReports(checkDone);
    this.loadSuppliers(checkDone);
    
    // 🎯 পাইপলাইনে নতুন মেথডটি সেন্ট্রাললি এক্সিকিউট করা হলো
    this.loadPendingPurchaseOrders(checkDone);
  }

  loadInventoryData(done: () => void): void {
    this.inventoryService.findAll().subscribe({
      next: (data) => {
        const invs = data || [];
        this.allInventory = invs;
        // Define low stock as available quantity less than 50 (or any threshold)
        this.lowStockItems = invs.filter((i: any) => (i.availableQuantity || 0) < 50);
        
        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();
        let lastMonth = currentMonth - 1;
        let lastMonthYear = currentYear;
        if (lastMonth < 0) { lastMonth = 11; lastMonthYear--; }
        
        let stockThis = 0; let stockLast = 0;
        this.lowStockItems.forEach((i: any) => {
            const dateStr = i.lastUpdated || i.createdAt;
            if (dateStr) {
                const d = new Date(dateStr);
                if (d.getMonth() === currentMonth && d.getFullYear() === currentYear) {
                    stockThis++;
                } else if (d.getMonth() === lastMonth && d.getFullYear() === lastMonthYear) {
                    stockLast++;
                }
            }
        });
        
        let stockTrend = stockLast > 0 ? Math.round(((stockThis - stockLast) / stockLast) * 100) : (stockThis > 0 ? 100 : 0);

        // Push a new KPI for Low Stock
        this.kpis.push({
          label: 'Low Stock Alerts',
          value: `${this.lowStockItems.length}`,
          trend: stockTrend,
          icon: 'bi-exclamation-triangle',
          color: 'danger',
        });
        
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  filterShipments(): void {
    if (!this.shipmentSearchTerm) {
      this.filteredShipments = [...this.activeShipments];
      return;
    }
    const term = this.shipmentSearchTerm.toLowerCase();
    this.filteredShipments = this.activeShipments.filter(s => 
      (s.id && s.id.toString().includes(term)) ||
      (s.supplierName && s.supplierName.toLowerCase().includes(term)) ||
      (s.receiverName && s.receiverName.toLowerCase().includes(term)) ||
      (s.sendByAddress && s.sendByAddress.toLowerCase().includes(term)) ||
      (s.destination && s.destination.toLowerCase().includes(term)) ||
      (s.origin && s.origin.toLowerCase().includes(term)) ||
      (s.vehicleNumber && s.vehicleNumber.toLowerCase().includes(term)) ||
      (s.captainRegistrationNumber && s.captainRegistrationNumber.toLowerCase().includes(term)) ||
      (s.driverName && s.driverName.toLowerCase().includes(term))
    );
  }

  loadShipmentsData(done: () => void): void {
    this.shipmentService.findAll().subscribe({
        next: (data) => {
          const all = data || [];
          this.activeShipments = all; // Removed status filter because ShipmentResponseModel does not have a status field
          this.filteredShipments = [...this.activeShipments];
          
          const delivered = all.filter((s: any) => s.status === 'DELIVERED');
        this.deptPerformance[1].score = all.length > 0 ? Math.round((delivered.length / all.length) * 100) : 0;
        
        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();
        let lastMonth = currentMonth - 1;
        let lastMonthYear = currentYear;
        if (lastMonth < 0) { lastMonth = 11; lastMonthYear--; }
        
        let shipThis = 0; let shipLast = 0;
        this.activeShipments.forEach((s: any) => {
            const dateStr = s.createdAt || s.updatedAt || s.estimatedDelivery;
            if (dateStr) {
                const d = new Date(dateStr);
                if (d.getMonth() === currentMonth && d.getFullYear() === currentYear) {
                    shipThis++;
                } else if (d.getMonth() === lastMonth && d.getFullYear() === lastMonthYear) {
                    shipLast++;
                }
            }
        });
        
        let shipTrend = shipLast > 0 ? Math.round(((shipThis - shipLast) / shipLast) * 100) : (shipThis > 0 ? 100 : 0);

        // Push a new KPI for Active Shipments
        this.kpis.push({
          label: 'Active Shipments',
          value: `${this.activeShipments.length}`,
          trend: shipTrend, // Now dynamic!
          icon: 'bi-truck',
          color: 'primary',
        });
        
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadDailyReports(done: () => void): void {
    this.dailyReportService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allReports = all;
        this.dailyReports = all.slice(0, 5); // display top 5
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadSuppliers(done: () => void): void {
    this.supplierService.findAll().subscribe({
      next: (data) => {
        const suppliers = data || [];
        this.allSuppliers = suppliers;
        this.supplierCount = suppliers.length;
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  approveReport(id: number) {
    if (!confirm(`Are you sure you want to approve Report #${id}?`)) return;
    this.dailyReportService.approve(id).subscribe({
      next: () => {
        alert('Daily Report approved successfully!');
        // Update local state to APPROVED
        const idx = this.dailyReports.findIndex(r => r.id === id);
        if (idx !== -1) {
            this.dailyReports[idx].reportStatus = 'APPROVED';
        }
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Approval failed:', err);
        alert(err.error?.message || 'Failed to approve Daily Report.');
      }
    });
  }

  loadPurchaseRequisitions(done: () => void): void {
    this.prService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allPrs = all;
        const pending = all.filter((r: any) => r.approvalStatus === 'PENDING');
        const approved = all.filter((r: any) => r.approvalStatus === 'APPROVED');
        this.pendingApprovalsCount = pending.length;
        
        this.deptPerformance[0].score = all.length > 0 ? Math.round((approved.length / all.length) * 100) : 0;
        
        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();
        let lastMonth = currentMonth - 1;
        let lastMonthYear = currentYear;
        if (lastMonth < 0) { lastMonth = 11; lastMonthYear--; }
        
        let reqThis = 0; let reqLast = 0;
        all.forEach((r: any) => {
            const dateStr = r.createdAt || r.requiredByDate;
            if (dateStr) {
                const d = new Date(dateStr);
                if (d.getMonth() === currentMonth && d.getFullYear() === currentYear) {
                    reqThis++;
                } else if (d.getMonth() === lastMonth && d.getFullYear() === lastMonthYear) {
                    reqLast++;
                }
            }
        });
        let reqTrend = reqLast > 0 ? Math.round(((reqThis - reqLast) / reqLast) * 100) : (reqThis > 0 ? 100 : 0);

        this.kpis[1] = {
          label: 'Pending Approvals',
          value: `${pending.length}`,
          trend: reqTrend,
          icon: 'bi-shield-exclamation',
          color: 'warning',
        };
        this.approvals = pending.slice(0, 5).map((r: any) => ({
          id: r.id,
          type: 'Purchase Requisition',
          requester: r.requestedByName || r.requestedBy || 'System',
          amount: r.quantityRequired || 0,
          date: r.requiredByDate || 'N/A',
        }));
        const sourcingScore = all.length > 0 ? Math.round((approved.length / all.length) * 100) : 0;
        this.deptPerformance[0].score = sourcingScore;
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadPurchaseOrders(done: () => void): void {
    this.poService.findAll().subscribe({
      next: (data) => {
        const orders = data || [];
        this.totalExpenses = orders.reduce((sum: number, o: any) => sum + (o.totalAmount || 0), 0);
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  // 🎯 ড্রাফট ও পেন্ডিং পারচেজ অর্ডার ম্যাট্রিক্স লোডার
  loadPendingPurchaseOrders(done?: () => void) {
    this.poService.findAll().subscribe({
      next: (data) => {
        const allOrders = data || [];
        
        // DRAFT বা PENDING স্ট্যাটাসের অর্ডার ফিল্টারিং
        const filteredPOs = allOrders.filter(
          po => po.status === 'DRAFT' || po.status === 'PENDING'
        );

        // নাল সেফটিসহ ফিল্ড ম্যাপিং আর্কিটেকচার
        this.pendingPOs = filteredPOs.map((po: any) => ({
          id: po.id,
          poNumber: po.poNumber || `PO-#${po.id}`,
          supplierName: po.supplierName || (po.supplier ? po.supplier.name : 'Apex Logistics Group'),
          deliveryDue: po.expectedDeliveryDate || po.createdAt || 'N/A',
          amount: po.totalAmount || po.amount || 0,
          status: po.status
        }));

        this.cdr.markForCheck();
        if (done) done();
      },
      error: (err: any) => {
        console.error('SCM PO Matrix Stream Error:', err);
        if (done) done();
      }
    });
  }

  approvePO(id: number) {
    this.poService.approve(id).subscribe({
      next: () => {
        alert('Purchase Order authorized successfully!');
        // লাইভ ডাটা প্যানেল রিফ্রেশ
        this.pendingPOs = this.pendingPOs.filter(po => po.id !== id);
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Authorization failed:', err);
        alert(err.error?.message || 'Failed to authorize Purchase Order.');
      }
    });
  }

  loadInvoices(done: () => void): void {
    this.invoiceService.findAll().subscribe({
      next: (data) => {
        const invoices = data || [];
        const issued = invoices.filter((inv: any) => inv.invoiceStatus === 'ISSUED');
        const paid = invoices.filter((inv: any) => inv.invoiceStatus === 'PAID');
        
        this.deptPerformance[3].score = invoices.length > 0 ? Math.round((paid.length / invoices.length) * 100) : 0;

        this.totalRevenue = invoices
          .filter((inv: any) => inv.invoiceStatus === 'ISSUED')
          .reduce((sum: number, inv: any) => sum + (inv.totalAmount || 0), 0);
          
        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();
        let lastMonth = currentMonth - 1;
        let lastMonthYear = currentYear;
        if (lastMonth < 0) { lastMonth = 11; lastMonthYear--; }
        
        let revThis = 0; let revLast = 0;
        let invThis = 0; let invLast = 0;
        
        invoices.forEach((inv: any) => {
            const dateStr = inv.issuedAt || inv.createdAt;
            if (dateStr) {
                const d = new Date(dateStr);
                if (d.getMonth() === currentMonth && d.getFullYear() === currentYear) {
                    invThis++;
                    if (inv.invoiceStatus === 'ISSUED') revThis += (inv.totalAmount || 0);
                } else if (d.getMonth() === lastMonth && d.getFullYear() === lastMonthYear) {
                    invLast++;
                    if (inv.invoiceStatus === 'ISSUED') revLast += (inv.totalAmount || 0);
                }
            }
        });
        
        let revTrend = revLast > 0 ? Math.round(((revThis - revLast) / revLast) * 100) : (revThis > 0 ? 100 : 0);
        let invTrend = invLast > 0 ? Math.round(((invThis - invLast) / invLast) * 100) : (invThis > 0 ? 100 : 0);

        this.kpis[0] = {
          label: 'Total Revenue',
          value: `৳${this.formatNumber(this.totalRevenue)}`,
          trend: revTrend,
          icon: 'bi-graph-up-arrow',
          color: 'success',
        };
        this.kpis[3] = {
          label: 'Total Invoices',
          value: `${invoices.length}`,
          trend: invTrend,
          icon: 'bi-receipt',
          color: 'primary',
        };
        const commercialScore =
          invoices.length > 0 ? Math.round((issued.length / invoices.length) * 100) : 0;
        this.deptPerformance[3].score = commercialScore;
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadWarehouses(done: () => void): void {
    this.warehouseService.getAll().subscribe({
      next: (data) => {
        const warehouses = data || [];
        this.allWarehouses = warehouses;
        this.warehouseCount = warehouses.length;
        
        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();
        let lastMonth = currentMonth - 1;
        let lastMonthYear = currentYear;
        if (lastMonth < 0) { lastMonth = 11; lastMonthYear--; }
        
        let whThis = 0; let whLast = 0;
        warehouses.forEach((w: any) => {
            const dateStr = w.createdAt || w.lastUpdated;
            if (dateStr) {
                const d = new Date(dateStr);
                if (d.getMonth() === currentMonth && d.getFullYear() === currentYear) {
                    whThis++;
                } else if (d.getMonth() === lastMonth && d.getFullYear() === lastMonthYear) {
                    whLast++;
                }
            }
        });
        
        let whTrend = whLast > 0 ? Math.round(((whThis - whLast) / whLast) * 100) : (whThis > 0 ? 100 : 0);
        
        this.kpis[2] = {
          label: 'Active Warehouses',
          value: `${this.warehouseCount}`,
          trend: whTrend,
          icon: 'bi-building',
          color: 'info',
        };
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadDeliveryTrips(done: () => void): void {
    this.deliveryTripService.findAll().subscribe({
      next: (data) => {
        const trips = data || [];
        const delivered = trips.filter((t: any) => t.status === 'DELIVERED');
        const logisticsScore =
          trips.length > 0 ? Math.round((delivered.length / trips.length) * 100) : 0;
        this.deptPerformance[1].score = logisticsScore;
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadQcInspections(done: () => void): void {
    this.qcService.findAll().subscribe({
      next: (data) => {
        const inspections = data || [];
        const passed = inspections.filter(
          (i: any) => i.result === 'GOOD' || i.result === 'VERY_GOOD',
        );
        const failed = inspections.filter(
          (i: any) => i.result === 'POOR' || i.result === 'REJECTED' || i.result === 'BAD',
        );
        this.failedQCCount = failed.length;
        const qcScore =
          inspections.length > 0 ? Math.round((passed.length / inspections.length) * 100) : 0;
        this.deptPerformance[2].score = qcScore;
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadNotifications(done: () => void): void {
    this.notificationService.findAll().subscribe({
      next: (data) => {
        this.notifications = (data || []).slice(0, 5);
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadActivityLogs(done: () => void): void {
    this.activityLogService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allActivities = all;
        this.activities = all.slice(0, 5);
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  loadGRNs(done: () => void): void {
    this.grnService.findAll().subscribe({
      next: (data) => {
        this.grns = (data || []).filter((g: GoodsReceivedNoteResponseModel) =>
          g.status === 'PENDING' || g.status === 'PARTIALLY_RECEIVED' || g.status === 'INSPECTED'
        );
        this.cdr.markForCheck();
        done();
      },
      error: () => done(),
    });
  }

  changeGrnStatus(grn: GoodsReceivedNoteResponseModel, newStatus: string) {
    if (!confirm(`Set GRN ${grn.grnNumber} status to "${newStatus}"?`)) return;
    this.grnStatusSaving = grn.id;
    const payload = {
      poId: grn.poId,
      productId: grn.productId || null,
      receivedQuantity: grn.receivedQuantity,
      receivedBy: grn.receivedBy,
      warehouseId: grn.warehouseId,
      receivedAt: grn.receivedAt,
      status: newStatus,
      remarks: grn.remarks,
      inspectedBy: grn.inspectedBy,
      inspectionDate: grn.inspectionDate,
      lineItems: [],
    };
    this.grnService.update(grn.id, payload).subscribe({
      next: () => {
        this.grnStatusSaving = null;
        this.loadGRNs(() => this.cdr.markForCheck());
      },
      error: (err: any) => {
        this.grnStatusSaving = null;
        alert(err.error?.message || 'Status update failed.');
        this.cdr.markForCheck();
      },
    });
  }

  buildChartData(): void {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const now = new Date();
    const months: string[] = [];
    const revMap: Record<string, number> = {};
    const expMap: Record<string, number> = {};

    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      months.push(monthNames[d.getMonth()]);
      revMap[key] = 0;
      expMap[key] = 0;
    }

    this.invoiceService.findAll().subscribe({
      next: (invoices) => {
        (invoices || []).forEach((inv: any) => {
          if (inv.invoiceStatus === 'ISSUED' && inv.issuedAt) {
            const d = new Date(inv.issuedAt);
            const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
            if (revMap[key] !== undefined) revMap[key] += inv.totalAmount || 0;
          }
        });

        this.poService.findAll().subscribe({
          next: (orders) => {
            (orders || []).forEach((po: any) => {
              if (po.createdAt) {
                const d = new Date(po.createdAt);
                const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
                if (expMap[key] !== undefined) expMap[key] += po.totalAmount || 0;
              }
            });

            this.chartMonths = months;
            this.chartRevenue = months.map((_, i) => {
              const key = Object.keys(revMap)[i];
              return revMap[key] || 0;
            });
            this.chartExpenses = months.map((_, i) => {
              const key = Object.keys(expMap)[i];
              return expMap[key] || 0;
            });
            this.chartMax = Math.max(...this.chartRevenue, ...this.chartExpenses, 1);
            this.cdr.markForCheck();
          },
        });
      },
    });
  }

  formatNumber(num: number): string {
    if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
    if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
    return num.toLocaleString();
  }

  getChartY(value: number): number {
    return 160 - (value / this.chartMax) * 140;
  }

  loadManager(): void {
    if (this.storage.getRole() === 'ADMIN') return;
    this.managerService.getManagerByUserId(this.userId).subscribe({
      next: (res) => {
        this.manager = res;
        this.storage.saveData(KEYS.MANAGER, res);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  approve(id: string): void {
    this.prService.approve(+id).subscribe({
      next: () => {
        this.approvals = this.approvals.filter((a) => a.id !== id);
        this.pendingApprovalsCount = Math.max(0, this.pendingApprovalsCount - 1);
        this.kpis[1].value = `${this.pendingApprovalsCount}`;
        this.cdr.markForCheck();
      },
      error: (err: any) => alert(err.error?.message || 'Approval failed'),
    });
  }

  reject(id: string): void {
    this.prService.rejectOrCancel(+id, 'REJECT').subscribe({
      next: () => {
        this.approvals = this.approvals.filter((a) => a.id !== id);
        this.pendingApprovalsCount = Math.max(0, this.pendingApprovalsCount - 1);
        this.kpis[1].value = `${this.pendingApprovalsCount}`;
        this.cdr.markForCheck();
      },
      error: (err: any) => alert(err.error?.message || 'Rejection failed'),
    });
  }

  getActionIcon(action: string): string {
    if (!action) return 'bi-activity';
    const a = action.toUpperCase();
    if (a.includes('CREATE') || a.includes('ADD')) return 'bi-plus-circle-fill';
    if (a.includes('UPDATE') || a.includes('EDIT')) return 'bi-pencil-square';
    if (a.includes('DELETE') || a.includes('REMOVE')) return 'bi-trash-fill';
    if (a.includes('APPROVE') || a.includes('ACCEPT')) return 'bi-check-circle-fill';
    if (a.includes('REJECT') || a.includes('DECLINE')) return 'bi-x-circle-fill';
    if (a.includes('STATUS')) return 'bi-arrow-repeat';
    if (a.includes('SYNC')) return 'bi-cloud-sync';
    if (a.includes('LOGIN')) return 'bi-box-arrow-in-right';
    return 'bi-activity';
  }

  getActionColorClass(action: string, module: string): string {
    if (!action) return 'bg-light text-secondary';
    const a = action.toUpperCase();
    
    // Color by Action type first
    if (a.includes('DELETE') || a.includes('REJECT')) return 'bg-danger-subtle text-danger';
    if (a.includes('CREATE') || a.includes('APPROVE')) return 'bg-success-subtle text-success';
    if (a.includes('STATUS')) return 'bg-info-subtle text-info';
    if (a.includes('UPDATE')) return 'bg-primary-subtle text-primary';
    
    // Fallback to module coloring
    const m = (module || '').toUpperCase();
    if (m.includes('INVOICE') || m.includes('PAYMENT')) return 'bg-danger-subtle text-danger';
    if (m.includes('PURCHASE')) return 'bg-primary-subtle text-primary';
    if (m.includes('SHIPMENT')) return 'bg-success-subtle text-success';
    
    return 'bg-secondary-subtle text-secondary';
  }

  toggleShortcut(shortcut: string) {
    if (this.activeShortcut === shortcut) {
      this.activeShortcut = null;
    } else {
      this.activeShortcut = shortcut;
      this.searchQuery = '';
      this.monthQuery = 'All Months';
      this.dateQuery = '';
    }
  }

  get filteredShortcutData(): any[] {
    let data: any[] = [];
    switch (this.activeShortcut) {
      case 'REPORT': data = this.allReports; break;
      case 'AUDIT': data = this.allActivities; break;
      case 'WAREHOUSE': data = this.allWarehouses; break;
      case 'PR': data = this.allPrs; break;
      case 'SUPPLIER': data = this.allSuppliers; break;
      case 'INVENTORY': data = this.allInventory; break;
    }

    // Apply specific Date and Month filters for PR and REPORT
    if (this.activeShortcut === 'PR' || this.activeShortcut === 'REPORT') {
      if (this.monthQuery && this.monthQuery !== 'All Months') {
        const monthIndex = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'].indexOf(this.monthQuery);
        if (monthIndex !== -1) {
          data = data.filter(item => {
            const dateStr = this.activeShortcut === 'PR' ? (item.createdAt || item.requiredByDate) : item.reportDate;
            if (!dateStr) return false;
            return new Date(dateStr).getMonth() === monthIndex;
          });
        }
      }
      if (this.dateQuery) {
        // dateQuery comes from <input type="date"> which is YYYY-MM-DD
        data = data.filter(item => {
          const dateStr = this.activeShortcut === 'PR' ? (item.createdAt || item.requiredByDate) : item.reportDate;
          if (!dateStr) return false;
          // compare local date string slice
          const itemDate = new Date(dateStr);
          // adjust for timezone to get local YYYY-MM-DD
          const localISO = new Date(itemDate.getTime() - (itemDate.getTimezoneOffset() * 60000)).toISOString().split('T')[0];
          return localISO === this.dateQuery;
        });
      }
    }

    if (!this.searchQuery || this.searchQuery.trim() === '') return data;
    
    const q = this.searchQuery.toLowerCase();
    return data.filter(item => {
      const values = Object.values(item).map(v => v ? String(v).toLowerCase() : '');
      return values.some(val => val.includes(q));
    });
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

  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
  }
}
