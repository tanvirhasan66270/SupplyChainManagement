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
      
      // 🎯 ফোর্সফুলি চেঞ্জ ডিটেকশন পুশ করা হলো যাতে অ্যাসিনক্রোনাস ডাটা আসার সাথে সাথে UI রেন্ডার হয়
      this.cdr.detectChanges(); 
    },
    error: (err: any) => this.handleError(err)
  });
}

  /**
   * 🔔 ড্যাশবোর্ড বা কম্পোনেন্টের জন্য কারেন্ট আনরিড কাউন্ট সিঙ্ক করা
   * (🎯 কোনো প্যারামিটার ছাড়াই সার্ভিস কল হবে, যা ৪০০ এরর প্রতিরোধ করবে)
   */
  updateUnreadCount() {
    this.service.getUnreadCount().subscribe({
      next: (count) => {
        this.unreadCount = count;
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleError(err)
    });
  }

  /**
   * 🔄 নির্দিষ্ট কোনো নোটিফিকেশনে ক্লিক করলে সেটি রিড (Read) হিসেবে স্ট্যাম্প করা
   */
  toggleRead(notification: NotificationModel) {
    if (notification.isRead || !notification.id) return;

    this.service.markAsRead(notification.id).subscribe({
      next: () => {
        notification.isRead = true;
        this.updateUnreadCount(); // কাউন্টার রি-ফ্রেশ
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleError(err)
    });
  }

  /**
   * 🧹 এক ক্লিকে ইনবক্সের সমস্ত আনরিড নোটিফিকেশন ক্লিয়ার করা
   */
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

  /**
   * ⚠️ গ্লোবাল এরর হ্যান্ডলিং ম্যাট্রিক্স
   */
  private handleError(err: any) {
    this.errorMessage = err.error?.message || err.message || "Notification Gateway Connection Timeout.";
    this.cdr.markForCheck();
  }
}