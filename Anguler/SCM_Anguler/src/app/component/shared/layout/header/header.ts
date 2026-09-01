import { Component, OnInit, OnDestroy, ChangeDetectorRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { NotificationService } from '../../../../system/service/notification.service';
import { StorageService } from '../../../../auth/auth_service/storage.service';
import { AuthService } from '../../../../auth/auth_service/auth-service';
import { FormsModule } from '@angular/forms';
import { CustomerOrderService } from '../../../../service/customer-order.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './header.html',
  styleUrls: ['./header.css'],
})
export class Header implements OnInit, OnDestroy {

  unreadNotificationCount = 0;

  user: any = null;

  showDropdown = false;
  showLogoutModal = false;

  onlineStatus = true;

  currentDateTime = '';

  private clockInterval: any;

  employeeId = '';
  departmentName = 'SCM Corporate Node';

  activeRole = 'CUSTOMER';
  walletBalance = 0;
  dueAmountTotal = 0;
  private roleSubscription!: any;

  constructor(
    private notificationService: NotificationService,
    private storage: StorageService,
    private authService: AuthService,
    private cdr: ChangeDetectorRef,
    private orderService: CustomerOrderService
  ) {}

  ngOnInit(): void {

    this.user = this.storage.getUser();

    if (this.user) {
      this.employeeId = `EMP-${this.user.userId}`;
      this.departmentName = this.getDepartmentName(this.user.role);
    }

    this.roleSubscription = this.storage.role$.subscribe((role) => {
      if (role) {
        this.activeRole = role.toUpperCase();
      } else {
        this.activeRole = this.storage.getActiveRole()?.toUpperCase() || 'CUSTOMER';
      }
      if (this.activeRole === 'CUSTOMER') {
        this.loadCustomerFinanceData();
      }
    });

    this.loadUnreadCount();

    this.updateTime();

    this.clockInterval = setInterval(() => {
      this.updateTime();
    }, 1000);
  }

  ngOnDestroy(): void {
    if (this.clockInterval) {
      clearInterval(this.clockInterval);
    }
    if (this.roleSubscription) {
      this.roleSubscription.unsubscribe();
    }
  }

  loadCustomerFinanceData() {
    this.orderService.findAll().subscribe({
      next: (orders) => {
        const customerOrders = orders ? orders.filter((o) => o.customerId === this.user?.userId) : [];
        this.walletBalance = customerOrders
          .filter((o) => o.paymentStatus === 'PAID')
          .reduce((sum, o) => sum + (o.codAmount || 0), 0);

        this.dueAmountTotal = customerOrders
          .filter((o) => o.paymentStatus !== 'PAID')
          .reduce((sum, o) => sum + (parseFloat(o.dueAmount as any) || 0), 0);
        this.cdr.markForCheck();
      }
    });
  }

  loadUnreadCount() {
    this.notificationService.getUnreadCount().subscribe({
      next: (count) => {
        this.unreadNotificationCount = count;
        this.cdr.markForCheck();
      }
    });
  }

  updateTime() {
    this.currentDateTime = new Date().toLocaleString();
    this.cdr.markForCheck();
  }

  toggleDropdown() {
    this.showDropdown = !this.showDropdown;
  }

  toggleOnlineStatus() {
    this.onlineStatus = !this.onlineStatus;
  }

  getInitials(): string {

    if (!this.user?.name) {
      return 'U';
    }

    const names = this.user.name.split(' ');

    if (names.length > 1) {
      return (names[0][0] + names[1][0]).toUpperCase();
    }

    return names[0][0].toUpperCase();
  }

  handleDropdownAction(action: string) {

    this.showDropdown = false;

    switch (action) {

      case 'logout':
        this.showLogoutModal = true;
        break;

      case 'theme':
        this.toggleTheme();
        break;

    }

    this.cdr.markForCheck();
  }

  toggleTheme() {

    const dark = document.body.classList.toggle('dark-theme');

    localStorage.setItem(
      'theme',
      dark ? 'dark' : 'light'
    );
  }

  closeLogoutModal() {

    this.showLogoutModal = false;

    this.cdr.markForCheck();
  }

  confirmLogout() {

    this.showLogoutModal = false;

    this.authService.logout();
  }

  private getDepartmentName(role: string): string {

    const departments: Record<string, string> = {

      ADMIN: 'SCM Administration',
      MANAGER: 'SCM Management',
      PROCUREMENT: 'Procurement Division',
      QC_INSPECTOR: 'Quality Control',
      LOGISTICS_OFFICER: 'Logistics',
      COMMERCIAL_OFFICER: 'Commercial',
      DRIVER: 'Delivery',
      SUPPLIER: 'Supplier Portal',
      CUSTOMER: 'Customer Portal'

    };

    return departments[role] || 'SCM Corporate Node';
  }

}