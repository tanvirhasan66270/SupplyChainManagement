import { Routes } from '@angular/router';
import { authGuard, roleGuard } from './auth/guard/auth-guard';

import { CountryComponent } from './component/features/address/country.component/country.component';
import { Division } from './component/features/address/division.component/division.component';
import { DistrictComponent } from './component/features/address/district.component/district.component';
import { PoliceStationComponent } from './component/features/address/police-station.component/police-station.component';
import { LocationComponent } from './component/features/address/location.component/location.component';
import { WarehouseComponent } from './component/features/address/warehouse.component/warehouse.component';
import { CustomerComponent } from './component/features/customer.component/customer.component';
import { CommercialOfficerComponent } from './component/features/commercial-officer.component/commercial-officer.component';
import { DriverComponent } from './component/features/driver.component/driver.component';
import { LogisticsOfficerComponent } from './component/features/logistics-officer.component/logistics-officer.component';
import { ManagerComponent } from './component/features/manager.component/manager.component';
import { QcinspactorComponent } from './component/features/qcinspactor.component/qcinspactor.component';
import { SalesOfficerComponent } from './component/features/sales-officer.component/sales-officer.component';
import { SupplierComponent } from './component/features/supplier.component/supplier.component';
import { CategoryComponent } from './component/features/category.component/category.component';
import { ProcourmentComponent } from './component/features/procourment.component/procourment.component';
import { AddProductComponent } from './component/features/add-product.component/add-product.component';
import { CustomerOrderComponent } from './component/features/customer-order.component/customer-order.component';
import { LoginComponent } from './auth/auth_component/login.component/login.component';
import { ForgetPasswordComponent } from './auth/auth_component/forget-password.component/forget-password.component';
import { ResetPasswordComponent } from './auth/auth_component/reset-password.component/reset-password.component';
import { BlankLayoutComponent } from './component/shared/layout/blank-layout.component/blank-layout.component';
import { MainLayoutComponent } from './component/shared/layout/main-layout.component/main-layout.component';
import { VeryfyEmailComponent } from './auth/auth_component/veryfy-email.component/veryfy-email.component';
import { RoleDeriectComponent } from './auth/auth_component/role-deriect.component/role-deriect.component';
import { CustomerDashboardComponent } from './component/dashboard/customer-dashboard.component/customer-dashboard.component';
import { ManagerDashboardComponent } from './component/dashboard/manager-dashboard/manager-dashboard.component';
import { ProcurementDashboardComponent } from './component/dashboard/procurement-dashboard/procurement-dashboard.component';
import { QCInspectorDashboardComponent } from './component/dashboard/qc-inspector-dashboard/qc-inspector-dashboard.component';
import { LogisticsDashboardComponent } from './component/dashboard/logistics-dashboard/logistics-dashboard.component';
import { CommercialDashboardComponent } from './component/dashboard/commercial-dashboard/commercial-dashboard.component';
import { SalesDashboardComponent } from './component/dashboard/sales-dashboard/sales-dashboard.component';
import { DriverDashboardComponent } from './component/dashboard/driver-dashboard/driver-dashboard.component';
import { SupplierDashboardComponent } from './component/dashboard/supplier-dashboard/supplier-dashboard.component';
import { AdminDashboardComponent } from './component/dashboard/admin-dashboard/admin-dashboard.component';
import { PurchaseRequisitionComponent } from './component/features/purchase-requisition.component/purchase-requisition.component';
import { ProductRequirementComponent } from './component/features/product-requirement.component/product-requirement.component';
import { QuatationComponent } from './component/features/quatation.component/quatation.component';
import { PurchaseOrderComponent } from './component/features/purchase-order.component/purchase-order.component';
import { POLineItemComponent } from './component/features/poline-item.component/poline-item.component';
import { ShipmentComponent } from './component/features/shipment.component/shipment.component';
import { LetterOfCreditComponent } from './component/features/letterofcradit.component/letterofcradit.component';
import { LcbankComponent } from './component/features/lcbank.component/lcbank.component';
import { GoodRecivedNoteComponent } from './component/features/good-recived-note.component/good-recived-note.component';
import { QcInspectionComponent } from './component/features/qc-inspection.component/qc-inspection.component';
import { InventoryComponent } from './component/features/inventory.component/inventory.component';
import { StockMovementComponent } from './component/features/stock-movement.component/stock-movement.component';
import { InvoiceComponent } from './component/features/invoice.component/invoice.component';
import { PaymentStatementComponent } from './component/features/payment-statement.component/payment-statement.component';
import { DeliveryTripComponent } from './component/features/delivery-trip.component/delivery-trip.component';
import { VehicleComponent } from './component/features/vehicle.component/vehicle.component';
import { DailyReportComponent } from './component/features/daley-report.component/daley-report.component';
import { NotificationComponent } from './system/component/notification.component/notification.component';
import { MassageComponent } from './system/component/massage.component/massage.component';
import { ActivityLogComponent } from './component/features/activity.log.component/activity.log.component';
import { PublicLayoutComponent } from './component/public/public-layout/public-layout.component';
import { PublicLandingComponent } from './component/public/public-landing/public-landing.component';
import { PublicAboutComponent } from './component/public/public-about/public-about.component';
import { PublicServicesComponent } from './component/public/public-services/public-services.component';
import { PublicNetworkComponent } from './component/public/public-network/public-network.component';
import { PublicContactComponent } from './component/public/public-contact/public-contact.component';
import { PublicJoinUsComponent } from './component/public/public-join-us/public-join-us.component';
import { SupplierProfileComponent } from './component/profile/supplier-profile.component/supplier-profile.component';
import { CustomerProfileComponent } from './component/profile/customer-profile.component/customer-profile.component';
import { DriverProfileComponent } from './component/profile/driver-profile.component/driver-profile.component';
import { AdminComponent } from './component/features/admin.component/admin.component';

const ALL_ROLES = [
  'ADMIN',
  'MANAGER',
  'DRIVER',
  'PROCUREMENT',
  'QC_INSPECTOR',
  'LOGISTICS_OFFICER',
  'COMMERCIAL_OFFICER',
  'CUSTOMER',
  'SUPPLIER',
  'SALES_OFFICER',
];

export const routes: Routes = [
  {
    path: '',
    component: PublicLayoutComponent,
    children: [
      { path: '', component: PublicLandingComponent },
      { path: 'about', component: PublicAboutComponent },
      { path: 'services', component: PublicServicesComponent },
      { path: 'network', component: PublicNetworkComponent },
      { path: 'contact', component: PublicContactComponent },
      { path: 'join-us', component: PublicJoinUsComponent },
      { path: 'products', loadComponent: () => import('./component/public/public-products/public-products.component').then(m => m.PublicProductsComponent) },
    ],
  },
  {
    path: '',
    component: BlankLayoutComponent,
    children: [
      { path: 'login', component: LoginComponent },
      { path: 'forgot-password', component: ForgetPasswordComponent },
      { path: 'reset-password', component: ResetPasswordComponent },
      { path: 'verify-email', component: VeryfyEmailComponent },
      {
        path: 'customer',
        component: CustomerComponent
     
      },
      {
        path: 'commercial-officer',
        component: CommercialOfficerComponent,
      
      },
      {
        path: 'driver',
        component: DriverComponent,
     
      },
      {
        path: 'logistics-officer',
        component: LogisticsOfficerComponent
      
      },
      {
        path: 'manager',
        component: ManagerComponent
      
      },
      {
        path: 'qc-inspector',
        component: QcinspactorComponent
      
      },
      {
        path: 'sales-officer',
        component: SalesOfficerComponent
     
      },
      {
        path: 'supplier',
        component: SupplierComponent
       
      },
      {
        path: 'procurement',
        component: ProcourmentComponent
       
      },
      {
        path: 'admin',
        component: AdminComponent
       
      },
    ],
  },
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    children: [
      { path: 'dashboard', component: RoleDeriectComponent },
      { path: 'dashboard/admin', component: AdminDashboardComponent },
      {
        path: 'dashboard/customer',
        component: CustomerDashboardComponent,
        children: [
          { path: 'customer_profile', component: CustomerProfileComponent }
        ]
      },
      { path: 'dashboard/manager', component: ManagerDashboardComponent },
      { path: 'dashboard/procurement', component: ProcurementDashboardComponent },
      { path: 'dashboard/qc-inspector', component: QCInspectorDashboardComponent },
      { path: 'dashboard/logistics', component: LogisticsDashboardComponent },
      { path: 'dashboard/commercial', component: CommercialDashboardComponent },
      { path: 'dashboard/sales', component: SalesDashboardComponent },
      {
        path: 'dashboard/driver',
        component: DriverDashboardComponent,
        children: [
          { path: 'driver_profile', component: DriverProfileComponent }
        ]
      },
     {
    path: 'dashboard/supplier', 
    component: SupplierDashboardComponent, 
    children: [
      { path: 'supplier_profile', component: SupplierProfileComponent }
    ]
  },
      { path: 'product', component: AddProductComponent },
      { path: 'customer-requirements', loadComponent: () => import('./component/features/customer-requirements/customer-requirements.component').then(m => m.CustomerRequirementsComponent) },
      { path: 'category', component: CategoryComponent },
      { path: 'order', component: CustomerOrderComponent },
      { path: 'country', component: CountryComponent },
      { path: 'division', component: Division },
      { path: 'district', component: DistrictComponent },
      { path: 'police-station', component: PoliceStationComponent },
      { path: 'location', component: LocationComponent },
      { path: 'warehouse', component: WarehouseComponent },
      { path: 'order-dashboard', component: CustomerDashboardComponent },
      { path: 'purchase-requisition', component: PurchaseRequisitionComponent },
      { path: 'product-requirement', component: ProductRequirementComponent },
      { path: 'quotation', component: QuatationComponent },
      { path: 'purchase-order', component: PurchaseOrderComponent },
      { path: 'poline-item', component: POLineItemComponent },
      { path: 'shipment', component: ShipmentComponent },
      { path: 'letter-of-credit', component: LetterOfCreditComponent },
      { path: 'lcbank', component: LcbankComponent },
      { path: 'good-received-note', component: GoodRecivedNoteComponent },
      { path: 'qc-inspection', component: QcInspectionComponent },
      { path: 'inventory', component: InventoryComponent },
      { path: 'stock-movement', component: StockMovementComponent },
      { path: 'invoice', component: InvoiceComponent },
      { path: 'payment-statement', component: PaymentStatementComponent },
      { path: 'delivery-trip', component: DeliveryTripComponent },
      { path: 'vehicles', component: VehicleComponent },
      { path: 'daily-report', component: DailyReportComponent },
      { path: 'notifications', component: NotificationComponent },
      { path: 'messages', component: MassageComponent },
      { path: 'activity-log', component: ActivityLogComponent },

    ],
  },
];
