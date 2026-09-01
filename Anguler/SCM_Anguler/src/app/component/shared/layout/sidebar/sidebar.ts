import { Component, OnInit, OnDestroy, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { StorageService } from '../../../../auth/auth_service/storage.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  templateUrl: './sidebar.html',
  styleUrls: ['./sidebar.css'],
})
export class SidebarComponent implements OnInit, OnDestroy {
  @Output() toggleSidebar = new EventEmitter<void>();

  activeRole: string = 'CUSTOMER';
  usersOpen = false;
  private roleSubscription!: Subscription;

  constructor(private storage: StorageService) {}

  ngOnInit(): void {
    this.roleSubscription = this.storage.role$.subscribe((role) => {
      if (role) {
        this.activeRole = role.toUpperCase();
      } else {
        this.activeRole = this.storage.getActiveRole()?.toUpperCase();
      }
    });
  }

  ngOnDestroy(): void {
    if (this.roleSubscription) {
      this.roleSubscription.unsubscribe();
    }
  }

  toggleUsersMenu(): void {
    this.usersOpen = !this.usersOpen;
  }

  dashboardsOpen = false;
  toggleDashboardsMenu(): void {
    this.dashboardsOpen = !this.dashboardsOpen;
  }

  hasAccess(allowedRoles: string[]): boolean {
    if (this.activeRole === 'ADMIN') return true;
    return allowedRoles.includes(this.activeRole);
  }

 
 showPoLineItemMenu(): boolean {
  // ১. যদি ইউজার PROCUREMENT অথবা COMMERCIAL_OFFICER হয়, তবে মেনুটি সব সময় দেখাবে
  if (this.activeRole === 'PROCUREMENT' ) {
    return true;
  }

  // ২. অন্য রোলের ক্ষেত্রে আগের কন্ডিশন (localStorage) কাজ করবে
  return localStorage.getItem('hasReceivedPO') === 'true';
}
}