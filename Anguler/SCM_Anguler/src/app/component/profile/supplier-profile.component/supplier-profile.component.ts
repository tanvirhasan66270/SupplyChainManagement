import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SupplierRequestDTO, SupplierResponseDTO } from '../../shared/model/supplierModel';
import { SupplierService } from '../../../service/supplier.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';
import { environment } from '../../../../environment/environment';

@Component({
  selector: 'app-supplier-profile',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './supplier-profile.component.html',
  styleUrl: './supplier-profile.component.css',
})
export class SupplierProfileComponent implements OnInit {

  readonly imageBaseUrl = environment.imgUrl + "supplier/";

  supplierData: SupplierResponseDTO | null = null;
  
  // 🎯 SupplierRequestDTO অনুযায়ী ফর্ম মডেল বাফার
  editModel: SupplierRequestDTO = {
    name: '',
    email: '',
    phone: '',
    contactPerson: '',
    address: '',
    nidNumber: '',
    passportNumber: '',
    gender: 'MALE',
    dob: '',
    image: '',
    rating: 0,
    averageLeadTimeDays: 0,
    policeStationId: 0
  };

  selectedFile: File | null = null;
  imagePreviewUrl: string | null = null;
  errorMessage: string | null = null;
  imageLoadError: boolean = false;

  // 📊 ডাইনামিক কমপ্লিশন ভ্যারিয়েবলস
  profileCompletion: number = 0;
  hasGeneralInfo: boolean = false;
  hasContactInfo: boolean = false;
  hasPhoto: boolean = false;
  hasBin: boolean = false; // আপনার প্রজেক্টের রুলস অনুযায়ী চেক থাকবে

  constructor(
    private supplierService: SupplierService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadProfileData();
  }

  loadProfileData(): void {
    const cachedSupplier = this.storage.getData(KEYS.SUPPLIER) as any;
    const currentUser = this.storage.getUser();

    if (cachedSupplier && cachedSupplier.id) {
      this.supplierService.getById(cachedSupplier.id).subscribe({
        next: (data: SupplierResponseDTO) => {
          this.supplierData = data;
          this.syncFormModel();
          this.calculateCompletion();
          this.cdr.markForCheck();
        },
        error: (err: any) => {
          this.supplierData = cachedSupplier;
          this.syncFormModel();
          this.calculateCompletion();
          this.errorMessage = err.error?.message || "Failed to sync profile data from gateway.";
          this.cdr.markForCheck();
        }
      });
    } else if (currentUser) {
      this.supplierService.getSupplierByUserId(currentUser.userId).subscribe({
        next: (data: SupplierResponseDTO) => {
          if (data) {
            this.supplierData = data;
            this.storage.saveData(KEYS.SUPPLIER, data);
            this.syncFormModel();
            this.calculateCompletion();
          }
          this.cdr.markForCheck();
        }
      });
    }
  }

  syncFormModel(): void {
    if (!this.supplierData) return;
    this.editModel = {
      name: this.supplierData.name,
      email: this.supplierData.email,
      phone: this.supplierData.phone,
      contactPerson: this.supplierData.contactPerson,
      address: this.supplierData.address,
      nidNumber: this.supplierData.nidNumber,
      passportNumber: this.supplierData.passportNumber,
      gender: this.supplierData.gender,
      dob: this.supplierData.dob ? this.supplierData.dob.split('T')[0] : '', // HTML date format mapping
      image: this.supplierData.image,
      rating: this.supplierData.rating,
      averageLeadTimeDays: this.supplierData.averageLeadTimeDays,
      policeStationId: this.supplierData.policeStationId
    };
  }

  calculateCompletion(): void {
    if (!this.supplierData) return;
    this.hasGeneralInfo = !!(this.supplierData.name && this.supplierData.contactPerson);
    this.hasContactInfo = !!(this.supplierData.phone && this.supplierData.email);
    this.hasPhoto = !!this.supplierData.image;
    this.hasBin = !!(this.supplierData.nidNumber || this.supplierData.passportNumber);

    let totalPoints = 0;
    if (this.hasGeneralInfo) totalPoints += 30;
    if (this.hasContactInfo) totalPoints += 30;
    if (this.hasPhoto) totalPoints += 20;
    if (this.hasBin) totalPoints += 20;

    this.profileCompletion = totalPoints;
    this.cdr.markForCheck();
  }

  getProfileImage(): string {
    if (this.imagePreviewUrl) {
      return this.imagePreviewUrl;
    }
    if (this.supplierData && this.supplierData.image && !this.imageLoadError) {
      return this.imageBaseUrl + this.supplierData.image;
    }
    return '';
  }

  onImageError(): void {
    this.imageLoadError = true;
    this.cdr.markForCheck();
  }

  getInitials(): string {
    if (!this.supplierData || !this.supplierData.name) return 'S';
    return this.supplierData.name.charAt(0).toUpperCase();
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
    if (!this.selectedFile || !this.supplierData) return;
    this.errorMessage = null;

    this.supplierService.update(this.supplierData.id, this.editModel, this.selectedFile).subscribe({
      next: (updatedData: SupplierResponseDTO) => {
        alert("Profile avatar updated successfully!");
        this.supplierData = updatedData;
        this.storage.saveData(KEYS.SUPPLIER, updatedData);
        this.imagePreviewUrl = null;
        this.selectedFile = null;
        this.calculateCompletion();
        this.cdr.markForCheck();
      },
      error: (err: any) => this.errorMessage = err.error?.message || "Avatar synchronization failure."
    });
  }

  updateProfileData(): void {
    if (!this.supplierData) return;
    this.errorMessage = null;

    // ফাইল ছাড়া শুধুমাত্র টেক্সট DTO ডেটা মেকানিজম আপডেট পাঠানো হচ্ছে
    this.supplierService.update(this.supplierData.id, this.editModel, null).subscribe({
      next: (updatedData: SupplierResponseDTO) => {
        alert("Supplier profile credentials updated successfully!");
        this.supplierData = updatedData;
        this.storage.saveData(KEYS.SUPPLIER, updatedData);
        this.syncFormModel();
        this.calculateCompletion();
        this.cdr.markForCheck();
      },
      error: (err: any) => this.errorMessage = err.error?.message || "Profile info mutation error."
    });
  }
}