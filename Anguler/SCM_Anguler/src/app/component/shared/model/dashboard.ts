export interface KpisModel {
  totalUsers: number;
  onlineUsers: number;
  activeUsers: number;
  inactiveUsers: number;

  customers: number;
  managers: number;
  drivers: number;
  procurementOfficers: number;
  qcInspectors: number;
  logisticsOfficers: number;
  commercialOfficers: number;
  salesOfficers: number;
  suppliers: number;

  totalRequisitions: number;
  pendingRequisitions: number;
  approvedRequisitions: number;
  rejectedRequisitions: number;

  totalQuotations: number;
  pendingQuotations: number;
  approvedQuotations: number;
  rejectedQuotations: number;

  totalPurchaseOrders: number;
  draftOrders: number;
  issuedOrders: number;
  receivedOrders: number;
  cancelledOrders: number;

  totalProducts: number;
  activeProducts: number;
  outOfStock: number;
  lowStock: number;
  totalCategories: number;

  totalWarehouses: number;
  totalInventory: number;
  currentStock: number;
  reservedStock: number;
  availableStock: number;
  todayIncomingGoods: number;
  todayOutgoingGoods: number;

  dispatchPending: number;
  dispatchCompleted: number;
  deliveryTrips: number;
  deliveriesCompleted: number;
  vehiclesRunning: number;
  driversAvailable: number;

  totalBills: number;
  paidBills: number;
  pendingBills: number;
  totalLc: number;
  pendingLc: number;
  approvedLc: number;

  todayReports: number;
  activityLogsToday: number;
  failedActivities: number;
  successfulActivities: number;
}

export interface AnalyticsModel {
  monthlyPurchaseTrend: any[];
  monthlyRevenue: any[];
  monthlyCustomerOrders: any[];
  purchaseOrderStatus: Record<string, number>;
  quotationStatus: Record<string, number>;
  inventoryStatus: Record<string, number>;
  productCategoryDistribution: Record<string, number>;
  warehouseUtilization: any[];
  supplierPerformance: any[];
  customerGrowth: any[];
  billingTrend: any[];
  deliveryPerformance: Record<string, number>;
  dailyTransactions: any[];
  weeklyActivities: any[];
  userRegistrationTrend: any[];
}

export interface NotificationItemModel {
  id: string;
  type: string;
  title: string;
  message: string;
  severity: string;
  time: string;
  relativeTime: string;
  isRead: boolean;
}

export interface NotificationsSummaryModel {
  unreadCount: number;
  list: NotificationItemModel[];
}

export interface RecentTablesModel {
  latestUsers: any[];
  latestProducts: any[];
  latestPurchaseRequisitions: any[];
  latestQuotations: any[];
  latestPurchaseOrders: any[];
  latestDispatch: any[];
  latestDeliveryTrips: any[];
  latestBills: any[];
  latestReports: any[];
  latestActivities: any[];
}

export interface DashboardSummaryModel {
  kpis: KpisModel;
  analytics: AnalyticsModel;
  recentActivities: any[];
  notifications: NotificationsSummaryModel;
  quickActions: string[];
  tables: RecentTablesModel;
}
