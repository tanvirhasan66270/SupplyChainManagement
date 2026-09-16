export enum ActionStatus {
  SUCCESS = 'SUCCESS',
  FAILED = 'FAILED',
  WARNING = 'WARNING',
}

export enum CustomerOrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  SHIPPED = 'SHIPPED',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
}

export enum DeliveryTripStatus {
  PENDING = 'PENDING',
  IN_TRANSIT = 'IN_TRANSIT',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
}

export enum DesignationStatus {
}

export enum EmployeeStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
  TERMINATED = 'TERMINATED',
  RESIGNED = 'RESIGNED',
  RETIRED = 'RETIRED',
}

export enum GenderStatus {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  OTHERS = 'OTHERS',
}

export enum GRNStatus {
  PENDING = 'PENDING',
  PARTIALLY_RECEIVED = 'PARTIALLY_RECEIVED',
  RECEIVED = 'RECEIVED',
  INSPECTED = 'INSPECTED',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export enum InvoiceStatus {
  DRAFT = 'DRAFT',
  ISSUED = 'ISSUED',
  CANCELLED = 'CANCELLED',
}

export enum LanguageStatus {
  BANGLA = 'BANGLA',
  ENGLISH = 'ENGLISH',
  OTHERS = 'OTHERS',
}

export enum LcStatus {
  DRAFT = 'DRAFT',
  OPENED = 'OPENED',
  AMENDED = 'AMENDED',
  EXPIRED = 'EXPIRED',
}

export enum PaymentMethod {
  CASH = 'CASH',
  BANK = 'BANK',
  BKASH = 'BKASH',
  NAGAD = 'NAGAD',
  ROCKET = 'ROCKET',
}

export enum PaymentStatus {
  UNPAID = 'UNPAID',
  PARTIALLY_PAID = 'PARTIALLY_PAID',
  PAID = 'PAID',
  REFUNDED = 'REFUNDED',
}

export enum POLineItemStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  SHIPPED = 'SHIPPED',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
}

export enum PurchaseOrderStatus {
  DRAFT = 'DRAFT',
  ISSUED = 'ISSUED',
  PARTIALLY_RECEIVED = 'PARTIALLY_RECEIVED',
  RECEIVED = 'RECEIVED',
  CANCELLED = 'CANCELLED',
}

export enum PurchaseRequisitionStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  CANCELLED = 'CANCELLED',
}

export enum QuotationStatus {
  PENDING = 'PENDING',
  UNDER_REVIEW = 'UNDER_REVIEW',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  EXPIRED = 'EXPIRED',
}

export enum ReportStatus {
  DRAFT = 'DRAFT',
  SUBMITTED = 'SUBMITTED',
  APPROVED = 'APPROVED',
}

export enum ResultStatus {
  GOOD = 'GOOD',
  VERY_GOOD = 'VERY_GOOD',
  AVERAGE = 'AVERAGE',
  BAD = 'BAD',
}

export enum ServiceType {
  STANDARD = 'STANDARD',
  EXPRESS = 'EXPRESS',
  OVERNIGHT = 'OVERNIGHT',
  SAME_DAY = 'SAME_DAY',
}

export enum StockMovementType {
  INWARD = 'INWARD',
  OUTWARD = 'OUTWARD',
  TRANSFER = 'TRANSFER',
  ADJUSTMENT = 'ADJUSTMENT',
}

export enum UrgencyLevel {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

export enum VehicleStatus {
  AVAILABLE = 'AVAILABLE',
  ON_TRIP = 'ON_TRIP',
  MAINTENANCE = 'MAINTENANCE',
  OUT_OF_SERVICE = 'OUT_OF_SERVICE',
}

export enum VehicleType {
  TRUCK = 'TRUCK',
  VAN = 'VAN',
  BIKE = 'BIKE',
  AIR = 'AIR',
  RIVER_ROUTE = 'RIVER_ROUTE',
}

export enum Role {
  ADMIN = 'ADMIN',
  MANAGER = 'MANAGER',
  DRIVER = 'DRIVER',
  PROCUREMENT = 'PROCUREMENT',
  QC_INSPECTOR = 'QC_INSPECTOR',
  LOGISTICS_OFFICER = 'LOGISTICS_OFFICER',
  COMMERCIAL_OFFICER = 'COMMERCIAL_OFFICER',
  CUSTOMER = 'CUSTOMER',
  SUPPLIER = 'SUPPLIER',
  SALES_OFFICER = 'SALES_OFFICER',
}

export interface CategoryRequestDTO {
  categoryName: string;
  description: string;
}

export interface CommercialOfficerRequestDTO {
  id: number;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  name: string;
  email: string;
  phone: string;
  password: string;
}

export interface CountryRequestDTO {
  id: number;
  name: string;
  code: string;
  phoneCode: string;
  active: boolean;
}

export interface CustomerOrderRequestDTO {
  customerId: number;
  deliveryAddress: string;
  estimatedDelivery: string;
  serviceType: string;
  codAmount: number;
  status: string;
  items: OrderLineItemRequestDTO[];
}

export interface CustomerRequestDTO {
  name: string;
  email: string;
  phone: string;
  password: string;
  address: string;
  gender: string;
  dob: string;
  nidNumber: string;
  image: string;
  policeStationId: number;
}

export interface DailyReportRequestDTO {
  warehouseId: string;
  reportDate: string;
  totalTasksDone: number;
  issuesLogged: number;
  summary: string;
  attachmentUrl: string;
}

export interface DeliveryTripRequestDTO {
  id: number;
  sendBy: string;
  customerId: number;
  driverId: number;
  status: string;
  recipientSignature: string;
  deliveryPhotoUrl: string;
  customerAddress: string;
  vehicleId: number;
  vehicleInfo: string;
  destinationInfo: string;
  scheduleInfo: string;
  tripInfo: string;
}

export interface DistrictRequestDTO {
  id: number;
  name: string;
  nameBn: string;
  districtCode: string;
  active: boolean;
  divisionId: number;
}

export interface DivisionRequestDTO {
  id: number;
  name: string;
  nameBn: string;
  active: boolean;
  countryId: number;
}

export interface DriverRequestDTO {
  id: number;
  driverName: string;
  phone: string;
  address: string;
  nidNumber: string;
  gender: string;
  email: string;
  vehicleType: string;
  vehicleNumber: string;
  dob: string;
  rating: number;
  totalDeliveries: number;
  totalEarnings: number;
  image: string;
  password: string;
  policeStationId: number;
  warehouseIds: number[];
}

export interface ForgotPasswordRequestDTO {
  email: string;
}

export interface GoodsReceivedNoteRequestDTO {
  poId: number;
  productId: number;
  receivedQuantity: number;
  receivedBy: number;
  warehouseId: number;
  receivedAt: string;
  status: string;
  remarks: string;
  inspectedBy: number;
  inspectionDate: string;
  lineItems: GRNLineItemRequestDTO[];
}

export interface GRNLineItemRequestDTO {
  id: number;
  grnId: number;
  productId: number;
  quantityOrdered: number;
  quantityReceived: number;
}

export interface InventoryRequestDTO {
  productId: number;
  warehouseId: number;
  quantityOnHand: number;
  quantityReserved: number;
  locationStatus: string;
  expiryDate: string;
  stockStatus: string;
}

export interface InvoiceRequestDTO {
  customerOrderId: number;
  salesOfficerId: number;
  subtotal: number;
  taxRate: number;
  discountAmount: number;
  discountPercentage: number;
  shippingFees: number;
  paidAmount: number;
  paymentMethod: string;
  transactionReference: string;
  invoiceStatus: string;
  deliveryDate: string;
  deliveryAddress: string;
  notes: string;
  cancelledReason: string;
}

export interface LetterOfCreditRequestDTO {
  purchaseOrderId: number;
  issuingBank: string;
  shipmentIncoTerms: string;
  latestShipmentDate: string;
  portOfLoading: string;
  portOfDischarge: string;
  amount: number;
  supplierId: number;
  currency: string;
  expiryDate: string;
  lcStatus: string;
  documentVaultUrl: string;
}

export interface LoginRequestDTO {
  email: string;
  password: string;
}

export interface LogisticsOfficerRequestDTO {
  id: number;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  name: string;
  email: string;
  phone: string;
  password: string;
}

export interface ManagerRequestDTO {
  id: number;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  name: string;
  email: string;
  phone: string;
  password: string;
}

export interface OrderLineItemRequestDTO {
  id: number;
  productId: number;
  quantity: number;
  unitPrice: number;
  remarks: string;
}

export interface PoliceStationRequestDTO {
  id: number;
  name: string;
  nameBn: string;
  postalCode: string;
  active: boolean;
  districtId: number;
}

export interface POLineItemRequestDTO {
  poId: number;
  productId: number;
  quantity: number;
  unitPrice: number;
  quotationRef: string;
  poNumber: string;
  deliveryDate: string;
  shipmentMethod: string;
  notes: string;
  status: string;
}

export interface ProcurementRequestDTO {
  id: number;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  isActive: boolean;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  name: string;
  email: string;
  phone: string;
  password: string;
}

export interface ProductRequestDTO {
  id: number;
  productCode: string;
  name: string;
  unit: string;
  reorderPoint: number;
  unitCost: number;
  quantity: number;
  sellingPrice: number;
  hasExpiryDate: string;
  weight: number;
  isActive: boolean;
  availability: string;
  image: string;
  categoryId: number;
}

export interface PurchaseOrderRequestDTO {
  quotationId: number;
  issuedBy: number;
  totalAmount: number;
  currency: string;
  expectedDeliveryDate: string;
  status: string;
}

export interface PurchaseRequisitionRequestDTO {
  requestedBy: number;
  productIds: number[];
  supplierIds: number[];
  currency: string;
  quantityRequired: number;
  urgencyLevel: string;
  requiredByDate: string;
  remarks: string;
}

export interface QCChecklistRequestDTO {
  id: number;
  inspectionId: number;
  checkpointName: string;
  isPassed: boolean;
  remarks: string;
}

export interface QCInspectionRequestDTO {
  id: number;
  grnId: number;
  productId: number;
  inspectionType: string;
  inspectedBy: number;
  sampleSize: number;
  defectsFound: number;
  defectDescription: string;
  result: string;
  certificateRef: string;
  labTestReport: string;
  inspectedAt: string;
  checklists: QCChecklistRequestDTO[];
}

export interface QCInspectorRequestDTO {
  name: string;
  email: string;
  phone: string;
  password: string;
  userActive: boolean;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  image: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
}

export interface QuotationRequestDTO {
  supplierId: number;
  productIds: number;
  productName: string;
  purchaseRequisitionId: number;
  validUntil: string;
  leadTimeDays: number;
  isSelected: boolean;
  receivedAt: string;
  status: string;
  productDescription: string;
  unitPrice: number;
  quantity: number;
  deliveryTime: string;
  warranty: string;
  notes: string;
  attachmentUrl: string;
}

export interface ResetPasswordRequestDTO {
  token: string;
  newPassword: string;
}

export interface SalesOfficerRequestDTO {
  id: number;
  address: string;
  nidNumber: string;
  dob: string;
  gender: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  name: string;
  email: string;
  phone: string;
  password: string;
}

export interface ShipmentRequestDTO {
  id: number;
  poId: number;
  supplierId: number;
  vehicleNumber: string;
  captainRegistrationNumber: string;
  assignedByEmail: string;
  origin: string;
  sendByAddress: string;
  estimatedDelivery: string;
  transportCost: number;
  podFileUrl: string;
}

export interface StockMovementRequestDTO {
  productId: number;
  warehouseId: number;
  sendWarehouse: string;
  movementType: string;
  quantity: number;
  referenceId: string;
  performedBy: number;
  remarks: string;
}

export interface SupplierRequestDTO {
  name: string;
  email: string;
  phone: string;
  password: string;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  gender: string;
  dob: string;
  image: string;
  rating: number;
  averageLeadTimeDays: number;
  policeStationId: number;
}

export interface VehicleRequestDTO {
  id: number;
  plateNumber: string;
  type: string;
  capacity: number;
  status: string;
  lastServiceDate: string;
  fuelLevel: number;
  driverId: number;
}

export interface WarehouseRequestDTO {
  name: string;
  email: string;
  location: string;
  capacity: number;
  managerId: number;
  isActive: boolean;
  policeStationId: number;
}

export interface CategoryResponseDTO {
  id: number;
  categoryName: string;
  description: string;
}

export interface CommercialOfficerResponseDTO {
  id: number;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  image: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  policeStationName: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
}

export interface CountryResponseDTO {
  id: number;
  name: string;
  code: string;
  phoneCode: string;
  active: boolean;
  divisions: string[];
}

export interface CustomerOrderResponseDTO {
  id: number;
  orderNumber: string;
  customerId: number;
  customerName: string;
  customerEmail: string;
  itemSubtotal: number;
  weight: number;
  serviceType: string;
  codAmount: number;
  deliveryCharge: number;
  totalAmount: number;
  paidAmount: string;
  currency: string;
  status: string;
  deliveryAddress: string;
  estimatedDelivery: string;
  createdAt: string;
  lineItems: OrderLineItemResponseDTO[];
}

export interface CustomerResponseDTO {
  id: number;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
  address: string;
  gender: string;
  dob: string;
  nidNumber: string;
  image: string;
  createdAt: string;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
}

export interface DailyReportResponseDTO {
  id: number;
  userId: string;
  warehouseId: string;
  reportDate: string;
  totalTasksDone: number;
  issuesLogged: number;
  summary: string;
  reportStatus: string;
  attachmentUrl: string;
  generatedAt: string;
  updatedAt: string;
}

export interface DeliveryTripResponseDTO {
  id: number;
  sendBy: string;
  status: string;
  startedAt: string;
  completedAt: string;
  recipientSignature: string;
  deliveryPhotoUrl: string;
  customerAddress: string;
  vehicleInfo: string;
  destinationInfo: string;
  scheduleInfo: string;
  tripInfo: string;
  createdAt: string;
  updatedAt: string;
  customerId: number;
  recipientName: string;
  driverId: number;
  driverName: string;
  driverEmail: string;
  vehicleId: number;
  vehiclePlateNumber: string;
}

export interface DistrictResponseDTO {
  id: number;
  name: string;
  nameBn: string;
  districtCode: string;
  active: boolean;
  divisionId: number;
  divisionName: string;
  countryName: string;
  policeStations: string[];
}

export interface DivisionResponseDTO {
  id: number;
  name: string;
  nameBn: string;
  active: boolean;
  countryId: number;
  countryName: string;
  districts: string[];
}

export interface DriverResponseDTO {
  id: number;
  driverName: string;
  phone: string;
  address: string;
  nidNumber: string;
  gender: string;
  email: string;
  vehicleType: string;
  vehicleNumber: string;
  dob: string;
  rating: number;
  totalDeliveries: number;
  totalEarnings: number;
  image: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  role: string;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
  warehouseNames: string[];
}

export interface GoodsReceivedNoteResponseDTO {
  id: number;
  grnNumber: string;
  quantity: number;
  receivedQuantity: number;
  receivedAt: string;
  status: GRNStatus;
  remarks: string;
  inspectionDate: string;
  createdAt: string;
  updatedAt: string;
  poId: number;
  poNumber: string;
  productId: number;
  productName: string;
  warehouseId: number;
  warehouseName: string;
  receivedBy: number;
  receivedByName: string;
  inspectedBy: number;
  inspectedByName: string;
}

export interface GRNLineItemResponseDTO {
  id: number;
  quantityOrdered: number;
  quantityReceived: number;
  grnId: number;
  grnNumber: string;
  productId: number;
  productName: string;
}

export interface InventoryResponseDTO {
  id: number;
  productId: number;
  productCode: string;
  productName: string;
  warehouseId: number;
  warehouseName: string;
  quantityOnHand: number;
  quantityReserved: number;
  availableQuantity: number;
  locationStatus: string;
  expiryDate: string;
  stockStatus: string;
  lastUpdated: string;
}

export interface InvoiceResponseDTO {
  id: number;
  invoiceNumber: string;
  customerOrderId: number;
  customerEmail: string;
  salesOfficerId: number;
  issuedToName: string;
  currency: string;
  subtotal: number;
  taxRate: number;
  taxAmount: number;
  discountAmount: number;
  discountPercentage: number;
  shippingFees: number;
  totalAmount: number;
  paidAmount: number;
  dueAmount: number;
  paymentStatus: string;
  paymentMethod: string;
  transactionReference: string;
  invoiceStatus: string;
  deliveryDate: string;
  deliveryAddress: string;
  notes: string;
  cancelledReason: string;
  issuedAt: string;
  createdAt: string;
  updatedAt: string;
  cancelledAt: string;
}

export interface LetterOfCreditResponseDTO {
  id: number;
  lcNumber: string;
  purchaseOrderId: number;
  poNumber: string;
  issuingBank: string;
  shipmentIncoTerms: string;
  latestShipmentDate: string;
  portOfLoading: string;
  portOfDischarge: string;
  amendmentCount: number;
  amount: number;
  supplierId: number;
  supplierName: string;
  supplierEmail: string;
  currency: string;
  expiryDate: string;
  lcStatus: string;
  documentVaultUrl: string;
  openedAt: string;
  createdAt: string;
  updatedAt: string;
}

export interface LoginResponseDTO {
  token: string;
  tokenType: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
}

export interface LogisticsOfficerResponseDTO {
  id: number;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  image: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  policeStationName: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
}

export interface ManagerResponseDTO {
  id: number;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  image: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  policeStationName: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
}

export interface OrderLineItemResponseDTO {
  id: number;
  productId: number;
  productName: string;
  productCode: string;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
  itemWeightTotal: number;
  remarks: string;
}

export interface PoliceStationResponseDTO {
  id: number;
  name: string;
  nameBn: string;
  postalCode: string;
  active: boolean;
  districtId: number;
  districtName: string;
  divisionName: string;
  countryName: string;
}

export interface POLineItemResponseDTO {
  id: number;
  poId: number;
  productId: number;
  productName: string;
  productCode: string;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
  totalAmount: number;
  quotationRef: string;
  poNumber: string;
  deliveryDate: string;
  shipmentMethod: string;
  trackingNumber: string;
  notes: string;
  status: POLineItemStatus;
  createdAt: string;
}

export interface ProcurementResponseDTO {
  id: number;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  image: string;
  isActive: boolean;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  policeStationName: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
}

export interface ProductResponseDTO {
  id: number;
  productCode: string;
  name: string;
  unit: string;
  reorderPoint: number;
  unitCost: number;
  quantity: number;
  sellingPrice: number;
  hasExpiryDate: string;
  weight: number;
  isActive: boolean;
  availability: string;
  image: string;
  categoryId: number;
  categoryName: string;
}

export interface PurchaseOrderResponseDTO {
  id: number;
  poNumber: string;
  quantity: number;
  totalAmount: number;
  currency: string;
  expectedDeliveryDate: string;
  status: PurchaseOrderStatus;
  issuedBy: number;
  createdAt: string;
  updatedAt: string;
  supplierId: number;
  supplierName: string;
  supplierEmail: string;
  purchaseRequisitionId: number;
  quotationId: number;
}

export interface PurchaseRequisitionResponseDTO {
  id: number;
  requestedBy: number;
  currency: string;
  quantityRequired: number;
  urgencyLevel: UrgencyLevel;
  requiredByDate: string;
  approvalStatus: PurchaseRequisitionStatus;
  approvedBy: number;
  remarks: string;
  createdAt: string;
  productIds: number[];
  productNames: string[];
  supplierIds: number[];
  supplierNames: string[];
}

export interface QCChecklistResponseDTO {
  id: number;
  checkpointName: string;
  isPassed: boolean;
  remarks: string;
  createdAt: string;
  updatedAt: string;
  inspectionId: number;
  inspectionType: string;
}

export interface QCInspectionResponseDTO {
  id: number;
  inspectionType: string;
  sampleSize: number;
  defectsFound: number;
  defectDescription: string;
  result: string;
  certificateRef: string;
  labTestReport: string;
  inspectedAt: string;
  createdAt: string;
  updatedAt: string;
  grnId: number;
  grnNumber: string;
  productId: number;
  productName: string;
  inspectedBy: number;
  inspectedByName: string;
  checklists: QCChecklistResponseDTO[];
}

export interface QCInspectorResponseDTO {
  id: number;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: GenderStatus;
  image: string;
  joiningDate: string;
  designation: string;
  language: LanguageStatus;
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: Role;
  userActive: boolean;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
}

export interface QuotationResponseDTO {
  id: number;
  quotationNumber: string;
  validUntil: string;
  leadTimeDays: number;
  isSelected: boolean;
  receivedAt: string;
  status: QuotationStatus;
  productDescription: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  deliveryTime: string;
  warranty: string;
  notes: string;
  attachmentUrl: string;
  createdAt: string;
  supplierId: number;
  supplierName: string;
  productIds: number;
  productName: string;
  purchaseRequisitionId: number;
}

export interface SalesOfficerResponseDTO {
  id: number;
  address: string;
  nidNumber: string;
  dob: string;
  gender: string;
  image: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  policeStationName: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
}

export interface ShipmentResponseDTO {
  id: number;
  shipmentNumber: string;
  poId: number;
  poQuantity: number;
  poTotalAmount: number;
  supplierId: number;
  supplierName: string;
  supplierContactPerson: string;
  supplierEmail: string;
  supplierPhone: string;
  supplierAddress: string;
  vehicleNumber: string;
  captainRegistrationNumber: string;
  assignedByEmail: string;
  origin: string;
  sendByAddress: string;
  estimatedDelivery: string;
  transportCost: number;
  podFileUrl: string;
  createdAt: string;
  updatedAt: string;
}

export interface StockMovementResponseDTO {
  id: number;
  productId: number;
  productName: string;
  warehouseId: number;
  warehouseName: string;
  sendWarehouse: string;
  movementType: string;
  quantity: number;
  referenceId: string;
  performedBy: number;
  movedAt: string;
  remarks: string;
}

export interface SupplierResponseDTO {
  id: number;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  gender: string;
  dob: string;
  image: string;
  rating: number;
  averageLeadTimeDays: number;
  createdAt: string;
  updatedAt: string;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
}

export interface VehicleResponseDTO {
  id: number;
  plateNumber: string;
  type: string;
  capacity: number;
  status: string;
  lastServiceDate: string;
  fuelLevel: number;
  driverId: number;
  driverName: string;
  driverPhone: string;
}

export interface WarehouseResponseDTO {
  id: number;
  name: string;
  email: string;
  location: string;
  capacity: number;
  managerId: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
}

export interface DivisionDTO {
  divisionId: number;
  divisionName: string;
  countryName: string;
  countryId: number;
}

