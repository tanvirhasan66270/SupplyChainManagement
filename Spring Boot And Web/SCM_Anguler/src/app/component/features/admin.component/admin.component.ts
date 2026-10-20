import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminRequest, AdminResponse } from '../../shared/model/adminModel';
import { AdminService } from '../../../service/admin.service';


@Component({
  selector: 'app-admin',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin.component.html',
  styleUrl: './admin.component.css',
})
export class AdminComponent implements OnInit {
  admins: AdminResponse[] = [];
  
  adminForm: AdminRequest = {
    name: '',
    email: '',
    phone: '',
    password: ''
  };

  isEdit = false;
  currentEditId: number | null = null;
  errorMessage: string | null = null;

  constructor(private adminService: AdminService) {}

  ngOnInit(): void {
    this.loadAdmins();
  }

  loadAdmins(): void {
    this.adminService.getAllAdmins().subscribe({ next: (data) => (this.admins = data),
      error: (err: any) => (this.errorMessage = 'Failed to load admins data.') });
  }

  saveAdmin(): void {
    if (this.isEdit && this.currentEditId !== null) {
      this.adminService.updateAdmin(this.currentEditId, this.adminForm).subscribe({
        next: () => {
          alert('Admin updated successfully.');
          this.resetForm();
          this.loadAdmins();
        },
        error: (err: any) => (this.errorMessage = err.error?.message || 'Update failed.')
      });
    } else {
      this.adminService.createAdmin(this.adminForm).subscribe({
        next: () => {
          alert('Admin created successfully.');
          this.resetForm();
          this.loadAdmins();
        },
        error: (err: any) => (this.errorMessage = err.error?.message || 'Creation failed.')
      });
    }
  }

  editAdmin(admin: AdminResponse): void {
    this.isEdit = true;
    this.currentEditId = admin.id;
    this.adminForm = {
      name: admin.name,
      email: admin.email,
      phone: admin.phone || '',
      password: ''
    };
  }

  // deleteAdmin(id: number): void {
  //   if (confirm('Are you sure you want to delete this admin?')) {
  //     this.adminService.deleteAdmin(id).subscribe({
  //       next: () => {
  //         alert('Admin deleted successfully.');
  //         this.loadAdmins();
  //       },
  //       error: (err: any) => alert('Delete failed.')
  //     });
  //   }
  // }

  resetForm(): void {
    this.adminForm = { name: '', email: '', phone: '', password: '' };
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }
}