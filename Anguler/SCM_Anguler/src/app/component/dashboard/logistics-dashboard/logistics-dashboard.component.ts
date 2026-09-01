import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { environment } from '../../../../environment/environment';
import { FormsModule } from '@angular/forms';
import { KEYS, StorageService } from '../../../auth/auth_service/storage.service';
import { LogisticsOfficerService } from '../../../service/logistics-officer.service';
import { LogisticsOfficerResponseModel } from '../../shared/model/logisticsOfficer';
import { LoginResponse } from '../../../auth/Model/authModel';
import { ShipmentService } from '../../../service/shipment.service';
import { WarehouseService } from '../../../service/warehouse.service';
import { NotificationService } from '../../../system/service/notification.service';
import { DeliveryTripService } from '../../../service/delivery-trip.service';
import { InventoryService } from '../../../service/inventory.service';
import { StockMovementService } from '../../../service/stock-movement.service';
import { VehicleService } from '../../../service/vehicle.service';
import { GoodRecivedNoteService } from '../../../service/good-recived-note.service';
import { AddProductService } from '../../../service/add-product.service';
import { CustomerService } from '../../../service/customer.service';
import { QcInspectorService } from '../../../service/qc-inspactor.service';
import { ManagerService } from '../../../service/manager.service';
import { PurchaseOrderService } from '../../../service/purchase-orde.service';
import { PurchaseRequisitionService } from '../../../service/purchase-requisition.service';
import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';
import { QcInspectionService } from '../../../service/qc-inspection.service';
import { NotificationModel } from '../../../system/NotificationModel';
import { StockMovementRequestModel } from '../../shared/model/stock-movement';
import { GoodsReceivedNoteRequestModel } from '../../shared/model/goodRecivedNoteModel';
import { VehicleRequestModel } from '../../shared/model/vehicleModel';
import { InventoryRequestModel } from '../../shared/model/inventoryModel';
import { DeliveryTripRequestModel } from '../../shared/model/DeliveryTripModel';

@Component({
  selector: 'app-logistics-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, DashboardSettingsComponent],
  templateUrl: './logistics-dashboard.component.html',
  styleUrls: ['./logistics-dashboard.component.css'],
})
export class LogisticsDashboardComponent implements OnInit {
  userName = '';
  userId!: number;
  logisticsOfficer: LogisticsOfficerResponseModel | null = null;
  user: LoginResponse | null = null;
  showSettings = false;
  loading = true;

  // Key Metrics
  totalShipments = 0;
  activeShipments = 0;
  delayedShipments = 0;
  
  lowStockItemsCount = 0;
  lowStockTooltip = '';
  totalTrips = 0;
  activeTrips = 0;
  lowStockItems: any[] = [];
  
  totalVehicles = 0;
  availableVehicles = 0;
  
  warehouseCapacityPercent = 0;
  
  totalMovements = 0;
  movementsToday = 0;
  inventoryTrend = 0;
  
  shipmentsTrend = 0;
  delayedTrend = 0;
  tripsTrend = 0;
  warehouseTrend = 0;

  totalInventoryCount = 0;
  totalAvailableQuantity = 0;

  // Grid Data
  dispatchSchedule: any[] = [];
  liveTimeline: any[] = [];
  dispatchQueue: any[] = [];
  
  // Quick Nav Modal States & Data
  showStockNavModal = false;
  showStockMovementNavModal = false;
  showGRNNavModal = false;
  showDeliveryTripNavModal = false;
  showVehicleNavModal = false;
  showQCInspectionNavModal = false;
  showDetailsModal = false;
  showImageModal = false;
  selectedInspectionForView: any = null;
  readonly imageBaseUrl = environment.apiUrl.replace('/api/', '') + 'images/qc';
  
  stockList: any[] = [];
  stockMovementList: any[] = [];
  grnList: any[] = [];
  deliveryTripList: any[] = [];
  vehicleList: any[] = [];
  qcInspectionList: any[] = [];
  productList: any[] = [];
  customerList: any[] = [];

  // Form Models for all 5 nav forms
  stockForm = {
    productId: 0,
    warehouseId: 0,
    quantityOnHand: 0,
    quantityReserved: 0,
    locationStatus: '',
    expiryDate: '',
    stockStatus: 'IN_STOCK'
  };

  movementForm = {
    movementType: 'INWARD',
    productId: 0,
    quantity: 0,
    sourceWarehouseId: 0,
    warehouseId: 0,
    referenceId: '',
    remarks: ''
  };

  grnForm = {
    poId: 0,
    poNumber: '',
    supplierName: 'Global Suppliers Ltd',
    supplierId: 0,
    grnNumber: '',
    waybillNumber: '',
    receivedQuantity: 0,
    receivedAt: new Date().toISOString().split('T')[0],
    qcStatus: 'PENDING',
    warehouseId: 0,
    productId: 0,
    inspectedBy: null as number | null,
    inspectionDate: '',
    lineItems: [] as any[],
    remarks: ''
  };

  users: any[] = [];

  tripForm = {
    dispatcherId: 0,
    customerId: 0,
    vehicleId: 0,
    status: 'PENDING',
    customerAddress: '',
    remarks: ''
  };

  vehicleForm = {
    vehicleNumber: '',
    type: 'COVERED_VAN',
    model: 'Tata Turbo',
    capacity: 5,
    status: 'AVAILABLE',
    driverName: ''
  };

  selectedVehicleType = '';
  filteredVehicles: any[] = [];
  
  // Chart Data
  fleetStats = { available: { val: 0, pct: 0, offset: 0, dash: '0 100' }, onRoute: { val: 0, pct: 0, offset: 0, dash: '0 100' }, maintenance: { val: 0, pct: 0, offset: 0, dash: '0 100' }, offline: { val: 0, pct: 0, offset: 0, dash: '0 100' } };
  inventoryStats = { in: { val: 0, pct: 0, offset: 0, dash: '0 100' }, out: { val: 0, pct: 0, offset: 0, dash: '0 100' }, transfer: { val: 0, pct: 0, offset: 0, dash: '0 100' } };
  
  // Shipment Performance Line Chart Data
  shipmentPerformancePoints = "M 0 140 L 500 140";
  shipmentPerformanceFill = "M 0 140 L 500 140 Z";
  shipmentDataPoints: any[] = [];
  shipmentHistoryStats = { total: 0, delivered: 0, inTransit: 0, delayed: 0 };
  chartLabels: { x: number, text: string }[] = [];
  
  monthsList = [
    { value: 0, label: 'January' }, { value: 1, label: 'February' }, { value: 2, label: 'March' },
    { value: 3, label: 'April' }, { value: 4, label: 'May' }, { value: 5, label: 'June' },
    { value: 6, label: 'July' }, { value: 7, label: 'August' }, { value: 8, label: 'September' },
    { value: 9, label: 'October' }, { value: 10, label: 'November' }, { value: 11, label: 'December' }
  ];
  selectedPerformanceMonth = new Date().getMonth();
  selectedPerformanceYear = new Date().getFullYear();
  allShipments: any[] = [];

  warehouses: any[] = [];
  purchaseOrders: any[] = [];
  purchaseRequisitions: any[] = [];
  filteredProducts: any[] = [];
  alerts: any[] = [];
  
  // Modal State
  showActivityModal = false;
  loadingActivities = false;
  
  showWarehouseModal = false;
  showShipmentModal = false;
  showDispatchModal = false;
  showScheduleModal = false;
  showMapModal = false;
  
  hasActiveTrackingDevice = false;

  constructor(
    private storage: StorageService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private logisticsOfficerService: LogisticsOfficerService,
    private shipmentService: ShipmentService,
    private warehouseService: WarehouseService,
    private notificationService: NotificationService,
    private deliveryTripService: DeliveryTripService,
    private inventoryService: InventoryService,
    private vehicleService: VehicleService,
    private stockMovementService: StockMovementService,
    private grnService: GoodRecivedNoteService,
    private productService: AddProductService,
    private customerService: CustomerService,
    private managerService: ManagerService,
    private qcInspectorService: QcInspectorService,
    private poService: PurchaseOrderService,
    private prService: PurchaseRequisitionService,
    private qcInspectionService: QcInspectionService
  ) {}

  ngOnInit(): void {
    const user = this.storage.getUser();
    if (!user) {
      return;
    }
    this.userName = user.name || 'Logistics Officer';
    this.userId = user.userId;
    this.tripForm.dispatcherId = user.userId;
    this.loadLogisticsOfficer();
    this.loadDashboardData();
    this.loadNavFormData();
  }

  loadNavFormData() {
    this.productService.findAll().subscribe({
      next: (data: any) => {
        this.productList = data || [];
        this.filteredProducts = [...this.productList];
        this.cdr.markForCheck();
      }
    });

    this.customerService.getAll().subscribe({
      next: (data: any) => {
        this.customerList = data || [];
        this.cdr.markForCheck();
      }
    });

    this.poService.findAll().subscribe({
      next: (data: any) => {
        this.purchaseOrders = data || [];
        this.cdr.markForCheck();
      }
    });

    this.prService.findAll().subscribe({
      next: (data: any) => {
        this.purchaseRequisitions = data || [];
        this.cdr.markForCheck();
      }
    });

    this.vehicleService.findAll().subscribe({
      next: (data: any) => {
        this.vehicleList = data || [];
        this.cdr.markForCheck();
      }
    });

    const managers$ = this.managerService.findAll();
    const inspectors$ = this.qcInspectorService.findAll();

    managers$.subscribe({
      next: (managers) => {
        const managerUsers = (managers || []).map((m: any) => ({
          id: m.userId || m.id,
          name: m.name || m.managerName,
          role: 'WAREHOUSE_MANAGER'
        }));
        inspectors$.subscribe({
          next: (inspectors) => {
            const inspectorUsers = (inspectors || []).map((i: any) => ({
              id: i.userId || i.id,
              name: i.name || i.inspectorName,
              role: 'QUALITY_INSPECTOR'
            }));
            this.users = [...managerUsers, ...inspectorUsers];
            this.cdr.markForCheck();
          },
          error: () => {
            this.users = managerUsers;
            this.cdr.markForCheck();
          }
        });
      },
      error: () => {
        inspectors$.subscribe({
          next: (inspectors) => {
            this.users = (inspectors || []).map((i: any) => ({
              id: i.userId || i.id,
              name: i.name || i.inspectorName,
              role: 'QUALITY_INSPECTOR'
            }));
            this.cdr.markForCheck();
          },
          error: () => {
            this.users = [];
          }
        });
      }
    });
  }

  loadDashboardData() {
    // 1. Shipments
    this.shipmentService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.allShipments = all;
        this.totalShipments = all.length;
        
        const active = all.filter((s: any) => s.status === 'IN_TRANSIT' || s.status === 'DISPATCHING' || s.status === 'PENDING');
        this.activeShipments = active.length;
        
        const delayed = all.filter((s: any) => s.status === 'DELAYED');
        this.delayedShipments = delayed.length || 0;
        
        const today = new Date();
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        const shipmentsToday = all.filter((s: any) => {
            if (!s.createdAt) return false;
            const d = new Date(s.createdAt);
            return d.getDate() === today.getDate() && d.getMonth() === today.getMonth() && d.getFullYear() === today.getFullYear();
        });
        const shipmentsYesterday = all.filter((s: any) => {
            if (!s.createdAt) return false;
            const d = new Date(s.createdAt);
            return d.getDate() === yesterday.getDate() && d.getMonth() === yesterday.getMonth() && d.getFullYear() === yesterday.getFullYear();
        });
        
        if (shipmentsYesterday.length > 0) {
            this.shipmentsTrend = Math.round(((shipmentsToday.length - shipmentsYesterday.length) / shipmentsYesterday.length) * 100);
        } else if (shipmentsToday.length > 0) {
            this.shipmentsTrend = 100;
        } else {
            this.shipmentsTrend = 0;
        }
        
        const delayedToday = shipmentsToday.filter((s: any) => s.status === 'DELAYED').length;
        const delayedYesterday = shipmentsYesterday.filter((s: any) => s.status === 'DELAYED').length;
        this.delayedTrend = delayedToday - delayedYesterday;
        
        // Build Dispatch Queue
        this.dispatchQueue = all.slice(0, 5).map((s: any, index: number) => ({
          id: s.id || `SHP-125${6 + index}`,
          customer: s.receiverName || 'Apex Logistics',
          driver: s.driverName || 'Rahim Uddin',
          vehicle: s.vehicleNumber || `TR-0${index + 1}`,
          destination: s.destination || s.origin || 'Dhaka',
          priority: index < 2 ? 'High' : (index === 2 ? 'Low' : 'Medium'),
          eta: s.estimatedDelivery || '10:30 AM',
          status: s.status || 'PENDING',
        }));

        // Build Live Timeline dynamically
        this.liveTimeline = all.slice(0, 4).map((s: any, index: number) => {
            const colors: any = { 'PENDING': 'warning', 'DISPATCHING': 'primary', 'IN_TRANSIT': 'primary', 'DELIVERED': 'success', 'DELAYED': 'danger' };
            const statusLabel: any = { 'PENDING': 'Processing', 'DISPATCHING': 'Dispatching', 'IN_TRANSIT': 'In Transit', 'DELIVERED': 'Delivered', 'DELAYED': 'Delayed' };
            
            const currentStatus = s.status || 'PENDING';
            let etaText = 'ETA: 4h';
            let timeStr = '10:30 AM';
            
            if (s.estimatedDelivery) {
              const d = new Date(s.estimatedDelivery);
              if (!isNaN(d.getTime())) {
                const now = new Date();
                const diffMs = d.getTime() - now.getTime();
                if (diffMs > 0) {
                   const hours = Math.round(diffMs / (1000 * 60 * 60));
                   etaText = `ETA: ${hours}h`;
                }
                timeStr = d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
              }
            } else if (s.createdAt) {
               const d = new Date(s.createdAt);
               if (!isNaN(d.getTime())) {
                  timeStr = d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
               }
            }

            const orderNum = s.shipmentNumber || s.poId || s.id || (index + 1);

            return {
                order: `#${orderNum}`,
                status: statusLabel[currentStatus] || 'Processing',
                time: currentStatus === 'DELIVERED' ? 'Completed' : etaText,
                time2: timeStr,
                color: colors[currentStatus] || 'success'
            };
        });
        
        if (this.liveTimeline.length === 0) {
            this.generateDummyTimeline();
        }

        this.generatePerformanceChartData(all);
        this.loading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.generateDummyTimeline();
        this.loading = false;
        this.cdr.markForCheck();
      },
    });

    // 2. Delivery Trips
    this.deliveryTripService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        this.totalTrips = all.length || 0; // Removing fallback logic to make dynamic
        
        const active = all.filter((t: any) => t.status === 'IN_TRANSIT' || t.status === 'PENDING');
        this.activeTrips = active.length || 0; // Removing fallback

        const today = new Date();
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        const tripsToday = all.filter((t: any) => {
            if (!t.createdAt && !t.estimatedArrival) return false;
            const d = new Date(t.createdAt || t.estimatedArrival);
            return d.getDate() === today.getDate() && d.getMonth() === today.getMonth() && d.getFullYear() === today.getFullYear();
        });
        const tripsYesterday = all.filter((t: any) => {
            if (!t.createdAt && !t.estimatedArrival) return false;
            const d = new Date(t.createdAt || t.estimatedArrival);
            return d.getDate() === yesterday.getDate() && d.getMonth() === yesterday.getMonth() && d.getFullYear() === yesterday.getFullYear();
        });
        
        if (tripsYesterday.length > 0) {
            this.tripsTrend = Math.round(((tripsToday.length - tripsYesterday.length) / tripsYesterday.length) * 100);
        } else if (tripsToday.length > 0) {
            this.tripsTrend = 100;
        } else {
            this.tripsTrend = 0;
        }

        this.dispatchSchedule = all.slice(0, 5).map((t: any) => ({
          tripId: t.tripNumber || `TR-${t.id || '01'}`,
          destination: t.destination || 'Dhaka',
          time: t.estimatedArrival || '10:30 AM',
          status: t.status || 'Scheduled'
        }));
        
        if (this.dispatchSchedule.length === 0) {
            const dests = ['Dhaka', 'Chattogram', 'Khulna', 'Rajshahi', 'Sylhet'];
            const times = ['10:30 AM', '12:00 PM', '02:30 PM', '04:00 PM', '05:30 PM'];
            const statuses = ['In Transit', 'Scheduled', 'Scheduled', 'Scheduled', 'Pending'];
            this.dispatchSchedule = [1,2,3,4,5].map((i, idx) => ({ tripId: `TR-0${i}`, destination: dests[idx], time: times[idx], status: statuses[idx] }));
        }

        this.cdr.markForCheck();
      },
      error: () => {},
    });

    // 3. Vehicles
    this.vehicleService.findAll().subscribe({
        next: (data) => {
            const all = data || [];
            this.totalVehicles = all.length;
            
            const available = all.filter((v: any) => v.status === 'AVAILABLE').length;
            const onRoute = all.filter((v: any) => v.status === 'IN_TRANSIT' || v.status === 'ON_ROUTE').length;
            const maintenance = all.filter((v: any) => v.status === 'MAINTENANCE').length;
            const offline = all.filter((v: any) => v.status === 'OFFLINE' || v.status === 'INACTIVE').length;
            
            this.availableVehicles = available;
            if (all.length > 0) {
                this.calculateFleetDonut(available, onRoute, maintenance, offline, all.length);
            }
            this.cdr.markForCheck();
        },
        error: () => {
            this.totalVehicles = 0;
            this.availableVehicles = 0;
        }
    });

    // 4. Warehouses
    this.warehouseService.getAll().subscribe({ next: (data) => {
        const all = data || [];
        const whNames = ['Warehouse A (Dhaka)', 'Warehouse B (Chattogram)', 'Warehouse C (Khulna)', 'Warehouse D (Rajshahi)'];
        this.warehouses = all.map((w: any, index: number) => ({
          id: w.id,
          name: w.name || whNames[index % whNames.length],
          capacity: w.capacity || 1000,
          location: w.location || '' }));
        if(this.warehouses.length === 0) {
            this.warehouses = whNames.map((name, i) => ({ id: i, name, capacity: 1000 }));
        }
        this.computeWarehouseCapacity();
        this.cdr.markForCheck();
      },
      error: () => {},
    });

    // 5. Inventory (Only for warehouse capacity & total inventory count)
    this.inventoryService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        // Calculate inventory metrics
        this.totalInventoryCount = all.reduce((sum: number, inv: any) => sum + (inv.quantityOnHand || inv.availableSellable || 0), 0);
        this.totalAvailableQuantity = all.reduce((sum: number, inv: any) => sum + (inv.availableQuantity || 0), 0);
        
        // Low Stock Logic based on Reserved Quota <= 5
        this.lowStockItems = all.filter((inv: any) => (inv.quantityReserved || 0) <= 5);
        this.lowStockItemsCount = this.lowStockItems.length;
        
        if (this.lowStockItemsCount > 0) {
            this.lowStockTooltip = this.lowStockItems.map((item: any) => `[PID: ${item.productId}] ${item.productName}`).join('\n');
        } else {
            this.lowStockTooltip = 'All stock levels are optimal';
        }
        
        this.computeWarehouseCapacity(all);
        this.cdr.markForCheck();
      },
      error: () => {},
    });

    // 5.5 Stock Movements (For Today's Inventory Movement Donut)
    this.stockMovementService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        
        const today = new Date();
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        const movementsTodayList = all.filter((m: any) => {
            if (!m.movedAt) return false;
            const d = new Date(m.movedAt);
            return d.getDate() === today.getDate() && d.getMonth() === today.getMonth() && d.getFullYear() === today.getFullYear();
        });

        const movementsYesterdayList = all.filter((m: any) => {
            if (!m.movedAt) return false;
            const d = new Date(m.movedAt);
            return d.getDate() === yesterday.getDate() && d.getMonth() === yesterday.getMonth() && d.getFullYear() === yesterday.getFullYear();
        });
        
        this.totalMovements = movementsTodayList.length;
        
        let inCount = 0, outCount = 0, transferCount = 0;
        movementsTodayList.forEach((m: any) => {
            if (m.movementType === 'INWARD') inCount++;
            else if (m.movementType === 'OUTWARD') outCount++;
            else transferCount++; // TRANSFER, ADJUSTMENT, etc
        });
        
        this.calculateInventoryDonut(inCount, outCount, transferCount, this.totalMovements);

        if (movementsYesterdayList.length > 0) {
            this.inventoryTrend = Math.round(((this.totalMovements - movementsYesterdayList.length) / movementsYesterdayList.length) * 100);
        } else if (this.totalMovements > 0) {
            this.inventoryTrend = 100;
        } else {
            this.inventoryTrend = 0;
        }

        this.cdr.markForCheck();
      },
      error: () => {},
    });
    
    // 6. Alerts
    this.notificationService.findAll().subscribe({
      next: (data) => {
        const all = data || [];
        
        this.alerts = all.slice(0, 4).map((n: any) => {
            let bsType = 'info';
            let icon = 'bi-info-circle';
            
            if (n.type === 'SHIPMENT') { bsType = 'warning'; icon = 'bi-box-seam'; }
            else if (n.type === 'TRIP_ALERT') { bsType = 'danger'; icon = 'bi-exclamation-triangle-fill'; }
            else if (n.type === 'REPORT_APPROVED') { bsType = 'success'; icon = 'bi-check-circle-fill'; }
            else if (n.title?.toLowerCase().includes('capacity')) { bsType = 'danger'; icon = 'bi-exclamation-triangle-fill'; }
            else if (n.title?.toLowerCase().includes('delayed')) { bsType = 'warning'; icon = 'bi-clock-history'; }
            else if (n.title?.toLowerCase().includes('maintenance')) { bsType = 'warning'; icon = 'bi-tools'; }
            else if (n.title?.toLowerCase().includes('assigned')) { bsType = 'info'; icon = 'bi-calendar-check'; }
            
            let timeStr = 'Just now';
            if (n.createdAt) {
                const diffMs = new Date().getTime() - new Date(n.createdAt).getTime();
                const diffMins = Math.floor(diffMs / 60000);
                if (diffMins === 0) timeStr = 'Just now';
                else if (diffMins < 60) timeStr = `${diffMins} mins ago`;
                else if (diffMins < 1440) timeStr = `${Math.floor(diffMins/60)} hours ago`;
                else timeStr = `${Math.floor(diffMins/1440)} days ago`;
            }
            
            let displayMessage = n.title || 'System Notification';
            if (n.message && n.message !== n.title) {
                displayMessage += ` (${n.message})`;
            }

            return {
                type: bsType,
                message: displayMessage,
                time: timeStr,
                icon: icon
            };
        });

        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  // Calculate SVG attributes for Fleet Donut Chart
  private calculateFleetDonut(av: number, rt: number, mt: number, off: number, total: number) {
      if (total === 0) return;
      const avPct = Math.round((av / total) * 100);
      const rtPct = Math.round((rt / total) * 100);
      const mtPct = Math.round((mt / total) * 100);
      const offPct = Math.round((off / total) * 100);

      const offset1 = 25; // CSS starts at top (25 offset for rotate-90)
      const offset2 = 100 - avPct + offset1;
      const offset3 = offset2 - rtPct;
      const offset4 = offset3 - mtPct;

      this.fleetStats = {
          available: { val: av, pct: avPct, offset: offset1, dash: `${avPct} ${100 - avPct}` },
          onRoute: { val: rt, pct: rtPct, offset: offset2, dash: `${rtPct} ${100 - rtPct}` },
          maintenance: { val: mt, pct: mtPct, offset: offset3, dash: `${mtPct} ${100 - mtPct}` },
          offline: { val: off, pct: offPct, offset: offset4, dash: `${offPct} ${100 - offPct}` }
      };
  }

  // Calculate SVG attributes for Inventory Donut Chart
  private calculateInventoryDonut(invIn: number, out: number, tx: number, total: number) {
      if (total === 0) return;
      const inPct = Math.round((invIn / total) * 100);
      const outPct = Math.round((out / total) * 100);
      const txPct = Math.round((tx / total) * 100);

      const offset1 = 25;
      const offset2 = 100 - inPct + offset1;
      const offset3 = offset2 - outPct;

      this.inventoryStats = {
          in: { val: invIn, pct: inPct, offset: offset1, dash: `${inPct} ${100 - inPct}` },
          out: { val: out, pct: outPct, offset: offset2, dash: `${outPct} ${100 - outPct}` },
          transfer: { val: tx, pct: txPct, offset: offset3, dash: `${txPct} ${100 - txPct}` }
      };
  }

  onPerformanceMonthChange(event: any) {
      this.selectedPerformanceMonth = +event.target.value;
      this.generatePerformanceChartData(this.allShipments);
  }

  private generatePerformanceChartData(shipments: any[]) {
      const xSpacing = 500 / 5; // 5 segments for 6 points
      const yMax = 120; // max height (lower is higher on SVG)
      
      const year = this.selectedPerformanceYear;
      const month = this.selectedPerformanceMonth;
      const daysInMonth = new Date(year, month + 1, 0).getDate();
      const monthShort = new Date(year, month, 1).toLocaleString('default', { month: 'short' });
      
      const days = [1, Math.floor(daysInMonth*0.2), Math.floor(daysInMonth*0.4), Math.floor(daysInMonth*0.6), Math.floor(daysInMonth*0.8), daysInMonth];
      
      this.chartLabels = days.map((day, i) => {
          let x = i * xSpacing;
          if (i === 5) x = 465; // adjust last label to fit SVG
          return { x, text: `${monthShort} ${day.toString().padStart(2, '0')}` };
      });

      const vals = [0, 0, 0, 0, 0, 0];
      const currentMonthShipments = shipments.filter(s => {
          if (!s.createdAt) return false;
          const d = new Date(s.createdAt);
          return d.getMonth() === month && d.getFullYear() === year;
      });

      if (currentMonthShipments.length > 0) {
          currentMonthShipments.forEach(s => {
              const d = new Date(s.createdAt);
              const day = d.getDate();
              let closestIdx = 0;
              let minDiff = daysInMonth + 1;
              days.forEach((bDay, idx) => {
                  const diff = Math.abs(day - bDay);
                  if (diff < minDiff) {
                      minDiff = diff;
                      closestIdx = idx;
                  }
              });
              vals[closestIdx]++;
          });
      }
      
      const maxVal = Math.max(...vals, 1);
      
      this.shipmentDataPoints = vals.map((val, i) => ({
          x: i * xSpacing,
          y: yMax - ((val / maxVal) * (yMax - 20))
      }));

      let path = `M 0 140 L 0 ${this.shipmentDataPoints[0].y}`;
      let fillPath = `M 0 140 L 0 ${this.shipmentDataPoints[0].y}`;
      
      for (let i = 0; i < this.shipmentDataPoints.length - 1; i++) {
          const p1 = this.shipmentDataPoints[i];
          const p2 = this.shipmentDataPoints[i + 1];
          const cx = (p1.x + p2.x) / 2;
          const curve = ` C ${cx} ${p1.y}, ${cx} ${p2.y}, ${p2.x} ${p2.y}`;
          path += curve;
          fillPath += curve;
      }
      
      this.shipmentPerformancePoints = path;
      this.shipmentPerformanceFill = fillPath + ` L 500 140 Z`;
      
      this.shipmentHistoryStats = {
          total: shipments.length,
          delivered: shipments.filter((s:any)=>s.status==='DELIVERED').length,
          inTransit: shipments.filter((s:any)=>s.status==='IN_TRANSIT').length,
          delayed: shipments.filter((s:any)=>s.status==='DELAYED').length
      };
  }

  private computeWarehouseCapacity(inventories: any[] = []): void {
  if (this.warehouses.length === 0) return;

  const usedByWarehouse: Record<number, number> = {};
  inventories.forEach((inv: any) => {
    // ইনভেন্টরি থেকে ওয়্যারহাউস আইডি এবং পরিমাণ বের করা
    const whId = inv.warehouseId || (inv.warehouse ? inv.warehouse.id : 0);
    if (whId) {
      if (!usedByWarehouse[whId]) usedByWarehouse[whId] = 0;
      usedByWarehouse[whId] += inv.quantityOnHand || inv.availableSellable || 0;
    }
  });

  let totalUsed = 0;
  let totalCap = 0;
  
  this.warehouses = this.warehouses.map((w) => {
    totalCap += Number(w.capacity) || 1000; // ডিফল্ট ক্যাপাসিটি ১০০০ ধরা যেতে পারে যদি না থাকে
    const used = usedByWarehouse[w.id] || 0;
    const usedPercent = w.capacity > 0 ? Math.min(100, Math.round((used / w.capacity) * 100)) : 0;
    
    totalUsed += used;
    return { ...w, used, usedPercent };
  });

  this.warehouseCapacityPercent = totalCap > 0 ? Math.min(100, Math.round((totalUsed / totalCap) * 100)) : 0;
  this.cdr.markForCheck();
}
  

  
  openWarehouseModal(event: Event): void {
    event.preventDefault();
    this.showWarehouseModal = true;
  }

  closeWarehouseModal(): void {
    this.showWarehouseModal = false;
  }
  
  openShipmentModal(event: Event): void {
    event.preventDefault();
    this.showShipmentModal = true;
  }

  closeShipmentModal(): void {
    this.showShipmentModal = false;
  }
  
  openDispatchModal(event: Event): void {
    event.preventDefault();
    this.showDispatchModal = true;
  }

  closeDispatchModal(): void {
    this.showDispatchModal = false;
  }
  
  openScheduleModal(event: Event): void {
    event.preventDefault();
    this.showScheduleModal = true;
  }

  closeScheduleModal(): void {
    this.showScheduleModal = false;
  }
  
  openMapModal(event: Event): void {
    event.preventDefault();
    this.showMapModal = true;
  }

  closeMapModal(): void {
    this.showMapModal = false;
  }

  // ───────────────── QUICK NAV CARD MODALS ─────────────────
  openStockNavModal(event?: Event): void {
    if (event) event.preventDefault();
    this.showStockNavModal = true;
    this.inventoryService.findAll().subscribe({
      next: (data: any) => {
        this.stockList = data || [];
        this.cdr.markForCheck();
      },
      error: () => {}
    });
  }

  closeStockNavModal(): void {
    this.showStockNavModal = false;
  }

  openStockMovementNavModal(event?: Event): void {
    if (event) event.preventDefault();
    this.showStockMovementNavModal = true;
    this.movementForm = {
      movementType: 'INWARD',
      productId: 0,
      quantity: 0,
      sourceWarehouseId: null as any,
      warehouseId: 0,
      referenceId: '',
      remarks: ''
    };
    this.stockMovementService.findAll().subscribe({
      next: (data: any) => {
        this.stockMovementList = data || [];
        this.cdr.markForCheck();
      },
      error: () => {}
    });
    this.inventoryService.findAll().subscribe({
      next: (data: any) => {
        this.stockList = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  closeStockMovementNavModal(): void {
    this.showStockMovementNavModal = false;
    this.movementForm = {
      movementType: 'INWARD',
      productId: 0,
      quantity: 0,
      sourceWarehouseId: null as any,
      warehouseId: 0,
      referenceId: '',
      remarks: ''
    };
  }

  openGRNNavModal(event?: Event): void {
    if (event) event.preventDefault();
    this.showGRNNavModal = true;
    this.grnService.findAll().subscribe({
      next: (data: any) => {
        this.grnList = data || [];
        this.cdr.markForCheck();
      },
      error: () => {}
    });
  }

  closeGRNNavModal(): void {
    this.showGRNNavModal = false;
  }

  openDeliveryTripNavModal(event?: Event): void {
    if (event) event.preventDefault();
    this.showDeliveryTripNavModal = true;
    this.deliveryTripService.findAll().subscribe({
      next: (data: any) => {
        this.deliveryTripList = data || [];
        this.cdr.markForCheck();
      },
      error: () => {}
    });
    this.vehicleService.findAll().subscribe({
      next: (data: any) => {
        this.vehicleList = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  closeDeliveryTripNavModal(): void {
    this.showDeliveryTripNavModal = false;
    this.tripForm = {
      dispatcherId: this.userId,
      customerId: 0,
      vehicleId: 0,
      status: 'PENDING',
      customerAddress: '',
      remarks: ''
    };
    this.selectedVehicleType = '';
    this.filteredVehicles = [];
  }

  openVehicleNavModal(event?: Event): void {
    if (event) event.preventDefault();
    this.showVehicleNavModal = true;
    this.vehicleService.findAll().subscribe({
      next: (data: any) => {
        this.vehicleList = data || [];
        this.cdr.markForCheck();
      },
      error: () => {}
    });
  }

  closeVehicleNavModal(): void {
    this.showVehicleNavModal = false;
  }

  openQCInspectionNavModal(event?: Event): void {
    if (event) event.preventDefault();
    this.showQCInspectionNavModal = true;
    this.qcInspectionService.findAll().subscribe({
      next: (data: any) => {
        this.qcInspectionList = data || [];
        this.cdr.markForCheck();
      },
      error: () => {}
    });
  }

  closeQCInspectionNavModal(): void {
    this.showQCInspectionNavModal = false;
  }

  openDetailsModal(inspection: any): void {
    this.selectedInspectionForView = inspection;
    this.showDetailsModal = true;
    this.cdr.markForCheck();
  }

  closeDetailsModal(): void {
    this.showDetailsModal = false;
    this.selectedInspectionForView = null;
    this.cdr.markForCheck();
  }

  openImageModal(inspection: any): void {
    this.selectedInspectionForView = inspection;
    this.showImageModal = true;
    this.cdr.markForCheck();
  }

  closeImageModal(): void {
    this.showImageModal = false;
    this.selectedInspectionForView = null;
    this.cdr.markForCheck();
  }

  getInspectionImageUrl(filename: string | undefined): string {
    if (!filename) return '';
    return `${this.imageBaseUrl}/${filename}`;
  }
  
  generateDummyTimeline() {
      this.liveTimeline = [
          { order: '#1', status: 'Processing', time: 'ETA: 4h', time2: '10:30 AM', color: 'success' },
          { order: '#2', status: 'Processing', time: 'ETA: 4h', time2: '10:30 AM', color: 'success' }
      ];
  }

  toggleSettings(): void {
    this.showSettings = !this.showSettings;
  }

  closeSettings(): void {
    this.showSettings = false;
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  loadLogisticsOfficer(): void {
    if (this.storage.getRole() === 'ADMIN') return;
    this.logisticsOfficerService.getLogisticsOfficerByUserId(this.userId).subscribe({
      next: (res) => {
        this.logisticsOfficer = res;
        this.storage.saveData(KEYS.LOGISTICS_OFFICER, res);
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  submitStockForm(): void {
    if (!this.stockForm.productId || !this.stockForm.warehouseId) {
      alert('Validation Error: Target Product and Warehouse Node must be specified.');
      return;
    }
    const payload: InventoryRequestModel = {
      productId: +this.stockForm.productId,
      warehouseId: +this.stockForm.warehouseId,
      quantityOnHand: +this.stockForm.quantityOnHand,
      quantityReserved: +this.stockForm.quantityReserved,
      locationStatus: this.stockForm.locationStatus,
      expiryDate: this.stockForm.expiryDate || undefined,
      stockStatus: this.stockForm.stockStatus
    };
    this.inventoryService.save(payload).subscribe({
      next: () => {
        alert('Inventory Stock node allocated and committed successfully.');
        this.closeStockNavModal();
        this.loadDashboardData();
      },
      error: (err: any) => alert(err.error?.message || 'Failed to commit stock ledger.')
    });
  }

  submitMovementForm(): void {
    if (!this.movementForm.productId || !this.movementForm.warehouseId) {
      alert('Validation Error: Product and Target Warehouse Node must be specified.');
      return;
    }

    if (this.movementForm.sourceWarehouseId && +this.movementForm.warehouseId === +this.movementForm.sourceWarehouseId) {
      alert('Business Conflict: Source warehouse and Target destination warehouse cannot be identical.');
      return;
    }

    const payload: StockMovementRequestModel = {
      movementType: this.movementForm.movementType,
      productId: +this.movementForm.productId,
      quantity: +this.movementForm.quantity,
      sourceWarehouseId: this.movementForm.movementType === 'TRANSFER' && this.movementForm.sourceWarehouseId ? +this.movementForm.sourceWarehouseId : null,
      warehouseId: +this.movementForm.warehouseId,
      referenceId: this.movementForm.referenceId.trim(),
      remarks: this.movementForm.remarks?.trim() || '',
      performedBy: this.userId || 0
    };

    this.stockMovementService.logMovement(payload).subscribe({
      next: () => {
        alert('Stock Movement transaction logged successfully.');
        this.closeStockMovementNavModal();
        this.loadDashboardData();
      },
      error: (err: any) => alert(err.error?.message || 'Failed to log stock movement.')
    });
  }

  get availableProductsForMovement(): any[] {
    return this.productList.filter(product => {
      const stockItem = this.stockList.find(s => s.productId === product.id || (s.product && s.product.id === product.id));
      const qty = stockItem ? (stockItem.quantityOnHand || stockItem.availableSellable || 0) : 0;
      return qty >= 1;
    });
  }

  onMovementProductChange(): void {
    if (!this.movementForm.productId || +this.movementForm.productId === 0) {
      this.movementForm.warehouseId = 0;
      return;
    }

    const matchedStock = this.stockList.find(s => 
      s.productId === +this.movementForm.productId || 
      (s.product && s.product.id === +this.movementForm.productId)
    );

    if (matchedStock) {
      const whId = matchedStock.warehouseId || (matchedStock.warehouse ? matchedStock.warehouse.id : 0);
      if (whId) {
        this.movementForm.warehouseId = whId;
      }
    }
    this.cdr.markForCheck();
  }

  getSelectedProductStock(): string {
    if (!this.movementForm.productId || +this.movementForm.productId === 0) {
      return '';
    }
    const matchedStock = this.stockList.find(s => 
      s.productId === +this.movementForm.productId || 
      (s.product && s.product.id === +this.movementForm.productId)
    );
    if (matchedStock) {
      return `${matchedStock.quantityOnHand || matchedStock.availableSellable || 0} Units`;
    }
    return '0 Units';
  }

  getTargetWarehouseName(): string {
    if (!this.movementForm.warehouseId) return 'Auto-filled from inventory stock...';
    const wh = this.warehouses.find(w => w.id === +this.movementForm.warehouseId);
    return wh ? wh.name : 'Selected Inventory Warehouse';
  }

  submitGRNForm(): void {
    if (!this.grnForm.poId || !this.grnForm.warehouseId) {
      alert('Validation Error: Source Purchase Order and Destination Warehouse are required.');
      return;
    }
    const payload: GoodsReceivedNoteRequestModel = {
      poId: +this.grnForm.poId,
      productId: +this.grnForm.productId || null,
      receivedQuantity: +this.grnForm.receivedQuantity,
      receivedBy: this.userId || 0,
      warehouseId: +this.grnForm.warehouseId,
      receivedAt: this.grnForm.receivedAt,
      status: this.grnForm.qcStatus || 'PENDING',
      remarks: this.grnForm.remarks || '',
      inspectedBy: this.grnForm.inspectedBy ? +this.grnForm.inspectedBy : null,
      inspectionDate: this.grnForm.inspectionDate || null,
      lineItems: this.grnForm.lineItems.map((item) => ({
        ...item,
        productId: +item.productId,
        quantityOrdered: +item.quantityOrdered,
        quantityReceived: +item.quantityReceived
      }))
    };
    this.grnService.save(payload).subscribe({
      next: () => {
        alert('Goods Received Note (GRN) created successfully.');
        this.closeGRNNavModal();
        this.loadDashboardData();
      },
      error: (err: any) => alert(err.error?.message || 'Failed to authorize GRN entry.')
    });
  }

  onDashboardPoChange(): void {
    const selectedPo = this.purchaseOrders.find((po: any) => Number(po.id) === Number(this.grnForm.poId));
    if (selectedPo && selectedPo.purchaseRequisitionId) {
      const pr = this.purchaseRequisitions.find((r: any) => Number(r.id) === Number(selectedPo.purchaseRequisitionId));
      if (pr && pr.productIds && pr.productIds.length > 0) {
        this.filteredProducts = this.productList.filter(p => pr.productIds.includes(Number(p.id)));
      } else {
        this.filteredProducts = [];
      }
    } else {
      if (Number(this.grnForm.poId) !== 0) {
        this.filteredProducts = [];
      } else {
        this.filteredProducts = [...this.productList];
      }
    }

    // Reset invalid line items
    this.grnForm.lineItems.forEach(item => {
      if (!this.filteredProducts.find(p => p.id === Number(item.productId))) {
        item.productId = 0;
      }
    });
    this.cdr.markForCheck();
  }

  getLowStockTooltip(): string {
    if (this.lowStockItems.length === 0) {
      return 'No low stock items.';
    }
    const maxShow = 10;
    const itemsToShow = this.lowStockItems.slice(0, maxShow);
    let tooltip = 'Low Stock Items (Reserved <= 5):\n';
    itemsToShow.forEach(item => {
      tooltip += `- ${item.productName || 'Unknown Product'} (ID: #${item.productId || item.id})\n`;
    });
    if (this.lowStockItems.length > maxShow) {
      tooltip += `...and ${this.lowStockItems.length - maxShow} more.`;
    }
    return tooltip;
  }

  addDashboardGrnLineItem(): void {
    this.grnForm.lineItems.push({
      productId: 0,
      quantityOrdered: 0,
      quantityReceived: 0
    });
    this.cdr.markForCheck();
  }

  removeDashboardGrnLineItem(index: number): void {
    this.grnForm.lineItems.splice(index, 1);
    this.cdr.markForCheck();
  }

  onVehicleTypeChange(): void {
    this.tripForm.vehicleId = 0;
    if (!this.selectedVehicleType) {
      this.filteredVehicles = [];
    } else {
      this.filteredVehicles = this.vehicleList.filter(
        (v: any) => v.type.toUpperCase() === this.selectedVehicleType.toUpperCase() && v.driverId != null
      );
    }
    this.cdr.markForCheck();
  }

  submitTripForm(): void {
    if (!this.tripForm.customerId || +this.tripForm.customerId === 0 || !this.tripForm.vehicleId || +this.tripForm.vehicleId === 0) {
      alert('Validation Error: Customer account selection and fleet vehicle mode allocation are required.');
      return;
    }
    const vehicle = this.vehicleList.find(v => +v.id === +this.tripForm.vehicleId);
    const driverId = vehicle ? vehicle.driverId : null;

    const payload: DeliveryTripRequestModel = {
      dispatcherId: this.userId || this.tripForm.dispatcherId,
      customerId: +this.tripForm.customerId,
      vehicleId: +this.tripForm.vehicleId,
      driverId: driverId || 0,
      status: this.tripForm.status,
      customerAddress: this.tripForm.customerAddress,
      remarks: this.tripForm.remarks
    };
    this.deliveryTripService.create(payload).subscribe({
      next: () => {
        alert('New Delivery Trip blueprint deployed successfully.');
        this.closeDeliveryTripNavModal();
        this.loadDashboardData();
      },
      error: (err: any) => alert(err.error?.message || 'Failed to deploy delivery trip.')
    });
  }

  submitVehicleForm(): void {
    if (!this.vehicleForm.vehicleNumber) {
      alert('Validation Error: Registration Number is required.');
      return;
    }
    const payload: VehicleRequestModel = {
      plateNumber: this.vehicleForm.vehicleNumber,
      type: this.vehicleForm.type,
      capacity: +this.vehicleForm.capacity,
      status: this.vehicleForm.status,
      fuelLevel: 100,
      driverId: null
    };
    this.vehicleService.create(payload).subscribe({
      next: () => {
        alert('Fleet Vehicle registered successfully.');
        this.closeVehicleNavModal();
        this.loadDashboardData();
      },
      error: (err: any) => alert(err.error?.message || 'Failed to register fleet vehicle.')
    });
  }

  logout(): void {
    this.storage.clearSession();
    this.router.navigate(['']);
  }
}

