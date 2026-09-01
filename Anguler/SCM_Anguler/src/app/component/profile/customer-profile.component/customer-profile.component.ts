import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CustomerRequestModel, CustomerResponseModel } from '../../shared/model/customerModel';
import { CustomerService } from '../../../service/customer.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';
import { environment } from '../../../../environment/environment';

@Component({
  selector: 'app-customer-profile',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './customer-profile.component.html',
  styleUrl: './customer-profile.component.css',
})
export class CustomerProfileComponent implements OnInit {

  readonly imageBaseUrl = environment.imgUrl + "customer/";

  customerData: CustomerResponseModel | null = null;
  
  editModel: CustomerRequestModel = {
    name: '',
    email: '',
    phone: '',
    address: '',
    gender: 'MALE',
    dob: '',
    nidNumber: '',
    policeStationId: 0
  };

  selectedFile: File | null = null;
  imagePreviewUrl: string | null = null;
  errorMessage: string | null = null;
  imageLoadError: boolean = false;

  profileCompletion: number = 0;
  hasGeneralInfo: boolean = false;
  hasContactInfo: boolean = false;
  hasPhoto: boolean = false;
  hasNid: boolean = false;

  constructor(
    private customerService: CustomerService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadProfileData();
  }

  loadProfileData(): void {
    const cachedCustomer = this.storage.getData(KEYS.CUSTOMER) as any;
    const currentUser = this.storage.getUser();

    if (cachedCustomer && cachedCustomer.id) {
      this.customerService.getById(cachedCustomer.id).subscribe({
        next: (data: CustomerResponseModel) => {
          this.customerData = data;
          this.syncFormModel();
          this.calculateCompletion();
          this.cdr.markForCheck();
        },
        error: (err: any) => {
          this.customerData = cachedCustomer;
          this.syncFormModel();
          this.calculateCompletion();
          this.errorMessage = err.error?.message || "Failed to sync profile data from gateway.";
          this.cdr.markForCheck();
        }
      });
    } else if (currentUser) {
      this.customerService.getCustomerByUserId(currentUser.userId).subscribe({
        next: (data: CustomerResponseModel) => {
          if (data) {
            this.customerData = data;
            this.storage.saveData(KEYS.CUSTOMER, data);
            this.syncFormModel();
            this.calculateCompletion();
          }
          this.cdr.markForCheck();
        },
        error: (err: any) => {
          this.errorMessage = err.error?.message || "Failed to load customer profile.";
          this.cdr.markForCheck();
        }
      });
    }
  }

  syncFormModel(): void {
    if (!this.customerData) return;
    this.editModel = {
      name: this.customerData.name,
      email: this.customerData.email,
      phone: this.customerData.phone,
      address: this.customerData.address,
      gender: this.customerData.gender || 'MALE',
      dob: this.customerData.dob ? this.customerData.dob.split('T')[0] : '',
      nidNumber: this.customerData.nidNumber,
      policeStationId: this.customerData.policeStationId
    };
  }

  calculateCompletion(): void {
    if (!this.customerData) return;
    this.hasGeneralInfo = !!this.customerData.name;
    this.hasContactInfo = !!(this.customerData.phone && this.customerData.email);
    this.hasPhoto = !!this.customerData.image;
    this.hasNid = !!this.customerData.nidNumber;

    let totalPoints = 0;
    if (this.hasGeneralInfo) totalPoints += 30;
    if (this.hasContactInfo) totalPoints += 30;
    if (this.hasPhoto) totalPoints += 20;
    if (this.hasNid) totalPoints += 20;

    this.profileCompletion = totalPoints;
    this.cdr.markForCheck();
  }

  getProfileImage(): string {
    if (this.imagePreviewUrl) {
      return this.imagePreviewUrl;
    }
    if (this.customerData && this.customerData.image && !this.imageLoadError) {
      const cleanName = this.customerData.image.includes('/')
        ? this.customerData.image.substring(this.customerData.image.lastIndexOf('/') + 1)
        : this.customerData.image;
      return this.imageBaseUrl + cleanName;
    }
    return '';
  }

  onImageError(): void {
    this.imageLoadError = true;
    this.cdr.markForCheck();
  }

  getInitials(): string {
    if (!this.customerData || !this.customerData.name) return 'C';
    return this.customerData.name.charAt(0).toUpperCase();
  }

  onFileChange(event: any): void {
    if (event.target.files && event.target.files.length > 0) {
      const file = event.target.files[0];
      if (file) {
        this.selectedFile = file;
        const reader = new FileReader();
        reader.onload = () => {
          this.imagePreviewUrl = reader.result as string;
          this.cdr.markForCheck();
        };
        reader.readAsDataURL(file);
      }
    }
  }

  uploadAvatar(): void {
    if (!this.selectedFile || !this.customerData) return;
    this.errorMessage = null;

    const formData = new FormData();
    formData.append(
      'customer',
      new Blob([JSON.stringify(this.editModel)], { type: 'application/json' }),
    );
    formData.append('image', this.selectedFile);

    this.customerService.update(this.customerData.id, formData).subscribe({
      next: (updatedData: CustomerResponseModel) => {
        alert("Profile avatar updated successfully!");
        this.customerData = updatedData;
        this.storage.saveData(KEYS.CUSTOMER, updatedData);
        this.imagePreviewUrl = null;
        this.selectedFile = null;
        this.calculateCompletion();
        this.cdr.markForCheck();
      },
      error: (err: any) => this.errorMessage = err.error?.message || "Avatar synchronization failure."
    });
  }

  updateProfileData(): void {
    if (!this.customerData) return;
    this.errorMessage = null;

    const formData = new FormData();
    formData.append(
      'customer',
      new Blob([JSON.stringify(this.editModel)], { type: 'application/json' }),
    );

    this.customerService.update(this.customerData.id, formData).subscribe({
      next: (updatedData: CustomerResponseModel) => {
        alert("Customer profile credentials updated successfully!");
        this.customerData = updatedData;
        this.storage.saveData(KEYS.CUSTOMER, updatedData);
        this.syncFormModel();
        this.calculateCompletion();
        this.cdr.markForCheck();
      },
      error: (err: any) => this.errorMessage = err.error?.message || "Profile info mutation error."
    });
  }
}
