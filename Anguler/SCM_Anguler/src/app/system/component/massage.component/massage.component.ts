import { CommonModule } from '@angular/common';
import { ChangeDetectorRef, Component, OnInit, OnDestroy } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MessageRequestModel, MessageResponseModel } from '../../massageModel';
import { MessageService } from '../../service/massage.service';
import { StorageService } from '../../../auth/auth_service/storage.service';

@Component({
  selector: 'app-massage',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './massage.component.html',
  styleUrl: './massage.component.css',
})
export class MassageComponent implements OnInit, OnDestroy {
  contacts: any[] = [];
  selectedContact: any = null;
  chatMessages: MessageResponseModel[] = [];
  messageText: string = '';
  currentUser: any = null;
  searchQuery: string = '';
  loadingContacts = true;
  loadingHistory = false;
  errorMessage: string | null = null;
  
  private pollInterval: any = null;

  constructor(
    private service: MessageService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef,
  ) {}

  ngOnInit() {
    this.currentUser = this.storage.getUser();
    this.loadContacts();
  }

  ngOnDestroy() {
    this.clearPolling();
  }

  loadContacts() {
    this.loadingContacts = true;
    this.errorMessage = null;
    this.service.getChatlist().subscribe({
      next: (data) => {
        this.contacts = data || [];
        this.loadingContacts = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        this.errorMessage = err.error?.message || 'Unable to retrieve chat list connections.';
        this.loadingContacts = false;
        this.cdr.markForCheck();
      }
    });
  }

  selectContact(contact: any) {
    this.clearPolling();
    this.selectedContact = contact;
    this.chatMessages = [];
    this.loadingHistory = true;
    this.cdr.markForCheck();

    this.loadChatHistory();

    // Poll every 3 seconds for new messages
    this.pollInterval = setInterval(() => {
      this.loadChatHistory(true);
    }, 3000);
  }

  loadChatHistory(isPolling = false) {
    if (!this.selectedContact) return;

    this.service.getChatHistory(this.selectedContact.id.toString()).subscribe({
      next: (data) => {
        this.chatMessages = data || [];
        if (!isPolling) {
          this.loadingHistory = false;
        }
        this.cdr.markForCheck();
      },
      error: () => {
        if (!isPolling) {
          this.loadingHistory = false;
        }
        this.cdr.markForCheck();
      }
    });
  }

  sendChatMessage() {
    if (!this.messageText.trim() || !this.selectedContact) return;

    const req: MessageRequestModel = {
      recipientId: this.selectedContact.id.toString(),
      subject: 'Chat Message',
      body: this.messageText.trim(),
      priority: 'MEDIUM'
    };

    const textToSend = this.messageText;
    this.messageText = ''; // Clear text immediately for snappy UI
    this.cdr.markForCheck();

    this.service.send(req).subscribe({
      next: () => {
        this.loadChatHistory();
      },
      error: (err: any) => {
        alert(err.error?.message || 'Failed to deliver message.');
        this.messageText = textToSend; // Restore text in case of failure
        this.cdr.markForCheck();
      }
    });
  }

  filteredContacts() {
    let allowedContacts = this.contacts;
    
    if (this.currentUser?.role === 'DRIVER') {
      const allowedRoles = ['DRIVER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'CUSTOMER'];
      allowedContacts = this.contacts.filter(c => allowedRoles.includes(c.role));
    }

    if (!this.searchQuery.trim()) {
      return allowedContacts;
    }
    
    return allowedContacts.filter(c =>
      c.name.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
      c.role.toLowerCase().includes(this.searchQuery.toLowerCase())
    );
  }

  getEmptyStatePlaceholder(): string {
    if (this.currentUser?.role === 'SUPPLIER') {
      return 'Choose a Procurement or Manager from the chat list sidebar to pull credentials and retrieve message records.';
    } else if (this.currentUser?.role === 'CUSTOMER') {
      return 'Choose a Sales Officer from the chat list sidebar to pull credentials and retrieve message records.';
    } else if (this.currentUser?.role === 'DRIVER') {
      return 'Choose a Driver, Logistics Officer, Sales Officer, or Customer from the sidebar to chat.';
    } else {
      return 'Choose a contact from the chat list sidebar to pull credentials and retrieve message records.';
    }
  }

  getEmptyStateSubtext(): string {
    if (this.currentUser?.role === 'SUPPLIER') {
      return 'Only connected Procurement and Manager roles are linked in this portal.';
    } else if (this.currentUser?.role === 'CUSTOMER') {
      return 'Only connected Sales Officer roles are linked in this portal.';
    } else if (this.currentUser?.role === 'DRIVER') {
      return 'Drivers can only communicate with Logistics, Sales, Customers, and other Drivers.';
    } else {
      return 'Only connected contact roles are linked in this portal.';
    }
  }

  getRoleBadgeClass(role: string): string {
    const classes: Record<string, string> = {
      CUSTOMER: 'bg-info-subtle text-info border border-info',
      SALES_OFFICER: 'bg-success-subtle text-success border border-success',
      PROCUREMENT: 'bg-warning-subtle text-warning border border-warning',
      MANAGER: 'bg-danger-subtle text-danger border border-danger',
    };
    return classes[role] || 'bg-primary-subtle text-primary border border-primary';
  }

  getInitials(name: string): string {
    if (!name) return 'U';
    const parts = name.trim().split(/\s+/);
    if (parts.length > 1 && parts[1].length > 0) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (parts[0].length > 0) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  private clearPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.pollInterval = null;
    }
  }
}
