import { Component, OnInit, Input, Output, EventEmitter, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';
import { LoginResponse } from '../../../auth/Model/authModel';
import { NotificationService } from '../../../system/service/notification.service';
import { NotificationModel } from '../../../system/NotificationModel';
import { environment } from '../../../../environment/environment';

import { AuthService } from '../../../auth/auth_service/auth-service';

@Component({
  selector: 'app-dashboard-settings',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard-settings.component.html',
  styleUrls: ['./dashboard-settings.component.css'],
})
export class DashboardSettingsComponent implements OnInit {
  @Input() isOpen = false;
  @Output() close = new EventEmitter<void>();
  @Output() onEditProfile = new EventEmitter<void>(); // 🎯 প্যারেন্ট ড্যাশবোর্ডকে রাউটিং ট্রিগার পাঠানোর গেটওয়ে

  user: LoginResponse | null = null;
  activeTab = 'profile';
  isDarkMode = false;
  sidebarCollapsed = false;
  notificationsEnabled = true;
  emailNotifications = true;
  showWidgets = true;
  language = 'en';
  dateFormat = 'MM/dd/yyyy';
  timeZone = 'Asia/Dhaka';
  imageUrl = environment.imgUrl;

  notifications: NotificationModel[] = [];
  unreadCount = 0;

  // ❌ লোকাল এডিট মোড ও ফর্মের ভ্যারিয়েবলসমূহ সম্পূর্ণ বাদ দেওয়া হয়েছে

  changePasswordMode = false;
  currentPassword = '';
  newPassword = '';
  confirmPassword = '';

  constructor(
    private storage: StorageService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private notificationService: NotificationService,
    private authService: AuthService,
  ) {}

  ngOnInit(): void {
    this.user = this.storage.getUser();
    this.isDarkMode = document.body.classList.contains('dark-theme');
    this.loadSettings();
    this.loadNotifications();
  }

  loadSettings(): void {
    const settings = this.storage.getData<any>('dashboard_settings');
    if (settings) {
      this.sidebarCollapsed = settings.sidebarCollapsed ?? false;
      this.notificationsEnabled = settings.notificationsEnabled ?? true;
      this.emailNotifications = settings.emailNotifications ?? true;
      this.showWidgets = settings.showWidgets ?? true;
      this.language = settings.language ?? 'en';
      this.dateFormat = settings.dateFormat ?? 'MM/dd/yyyy';
      this.timeZone = settings.timeZone ?? 'Asia/Dhaka';
    }
  }

  saveSettings(): void {
    const settings = {
      sidebarCollapsed: this.sidebarCollapsed,
      notificationsEnabled: this.notificationsEnabled,
      emailNotifications: this.emailNotifications,
      showWidgets: this.showWidgets,
      language: this.language,
      dateFormat: this.dateFormat,
      timeZone: this.timeZone,
    };
    this.storage.saveData('dashboard_settings', settings);
  }

  loadNotifications(): void {
    this.notificationService.findAll().subscribe({
      next: (data) => {
        this.notifications = (data || []).slice(0, 10);
        this.unreadCount = this.notifications.filter((n) => !n.isRead).length;
        this.cdr.markForCheck();
      },
      error: () => {},
    });
  }

  markAsRead(id: number): void {
    this.notificationService.markAsRead(id).subscribe({
      next: () => {
        const notif = this.notifications.find((n) => n.id === id);
        if (notif) notif.isRead = true;
        this.unreadCount = this.notifications.filter((n) => !n.isRead).length;
        this.cdr.markForCheck();
      },
    });
  }

  markAllAsRead(): void {
    this.notificationService.markAllAsRead().subscribe({
      next: () => {
        this.notifications.forEach((n) => (n.isRead = true));
        this.unreadCount = 0;
        this.cdr.markForCheck();
      },
    });
  }

  toggleTheme(): void {
    this.isDarkMode = !this.isDarkMode;
    document.body.classList.toggle('dark-theme', this.isDarkMode);
    localStorage.setItem('theme', this.isDarkMode ? 'dark' : 'light');
    this.saveSettings();
  }

  onSettingsChange(): void {
    this.saveSettings();
  }

  closePanel(): void {
    this.close.emit();
  }

  setTab(tab: string): void {
    this.activeTab = tab;
    this.cdr.markForCheck();
  }

  // "Edit Profile" বাটনে ক্লিক করলে প্যারেন্টকে সিগন্যাল পাঠানোর মেথড
  triggerEditProfileRouting(): void {
    this.onEditProfile.emit();
  }

  currentPasswordError: string | null = null;

  changePassword(): void {
    this.currentPasswordError = null; // reset error

    if (this.newPassword !== this.confirmPassword) {
      alert('Passwords do not match');
      return;
    }

    if (this.newPassword.length < 6 || this.newPassword.length > 20) {
      alert('Password must be between 6 and 20 characters');
      return;
    }

    const dto = {
      currentPassword: this.currentPassword,
      newPassword: this.newPassword
    };

    this.authService.changePassword(dto).subscribe({
      next: (res) => {
        alert(res || 'Password changed successfully.');
        this.changePasswordMode = false;
        this.currentPassword = '';
        this.newPassword = '';
        this.confirmPassword = '';
        this.cdr.markForCheck();
      },
      error: (err) => {
        console.error(err);
        const errorMsg = err.error || '';
        if (errorMsg.includes('Current password is incorrect')) {
          this.currentPasswordError = 'wrong password';
          this.cdr.markForCheck();
        } else {
          alert(errorMsg || 'Failed to change password. Please check your current password.');
        }
      }
    });
  }

  getRoleDisplayName(role: string): string {
    const roleMap: Record<string, string> = {
      ADMIN: 'Administrator',
      MANAGER: 'Manager',
      DRIVER: 'Driver',
      PROCUREMENT: 'Procurement Officer',
      QC_INSPECTOR: 'QC Inspector',
      LOGISTICS_OFFICER: 'Logistics Officer',
      COMMERCIAL_OFFICER: 'Commercial Officer',
      CUSTOMER: 'Customer',
      SUPPLIER: 'Supplier',
      SALES_OFFICER: 'Sales Officer',
    };
    return roleMap[role] || role;
  }

  getInitials(): string {
    if (!this.user?.name) return 'U';
    const parts = this.user.name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}