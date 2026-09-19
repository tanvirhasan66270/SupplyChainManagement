import { CommonModule } from '@angular/common';
import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NotificationModel } from '../../NotificationModel';
import { NotificationService } from '../../service/notification.service';

@Component({
  selector: 'app-notification',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './notification.component.html',
  styleUrl: './notification.component.css',
})
export class NotificationComponent implements OnInit {

  notifications: NotificationModel[] = [];
  unreadCount = 0;
  errorMessage: string | null = null;
  searchQuery: string = '';

  get filteredNotifications(): NotificationModel[] {
    if (!this.searchQuery) return this.notifications;
    const lowerQuery = this.searchQuery.toLowerCase();
    return this.notifications.filter(n => 
      (n.title && n.title.toLowerCase().includes(lowerQuery)) || 
      (n.message && n.message.toLowerCase().includes(lowerQuery)) ||
      (n.type && n.type.toLowerCase().includes(lowerQuery))
    );
  }

  constructor(
    private service: NotificationService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadNotifications();
  }

 loadNotifications() {
  this.errorMessage = null;
  this.service.findAll().subscribe({
    next: (data) => {
      this.notifications = data || [];
      this.updateUnreadCount();
      
      this.cdr.detectChanges(); 
    },
    error: (err: any) => this.handleError(err)
  });
}

  updateUnreadCount() {
    this.service.getUnreadCount().subscribe({
      next: (count) => {
        this.unreadCount = count;
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleError(err)
    });
  }

  
  toggleRead(notification: NotificationModel) {
    if (notification.isRead || !notification.id) return;

    this.service.markAsRead(notification.id).subscribe({
      next: () => {
        notification.isRead = true;
        this.updateUnreadCount(); 
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleError(err)
    });
  }


  clearAllUnread() {
    if (this.unreadCount === 0) return;

    this.service.markAllAsRead().subscribe({
      next: () => {
        this.notifications.forEach(n => n.isRead = true);
        this.unreadCount = 0;
        this.cdr.markForCheck();
        alert("All notifications marked as read.");
      },
      error: (err: any) => this.handleError(err)
    });
  }

 
  private handleError(err: any) {
    this.errorMessage = err.error?.message || err.message || "Notification Gateway Connection Timeout.";
    this.cdr.markForCheck();
  }
}