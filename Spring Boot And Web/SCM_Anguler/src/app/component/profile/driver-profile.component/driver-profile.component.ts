import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DriverRequestModel, DriverResponseModel } from '../../shared/model/driverModel';
import { DriverService } from '../../../service/driver.service';
import { StorageService, KEYS } from '../../../auth/auth_service/storage.service';
import { environment } from '../../../../environment/environment';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-driver-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './driver-profile.component.html',
  styleUrl: './driver-profile.component.css',
})
export class DriverProfileComponent implements OnInit {

  readonly imageBaseUrl = environment.imgUrl + "drivers/";

  driverData: DriverResponseModel | null = null;
  
  editModel: DriverRequestModel = {
    id: 0,
    driverName: '',
    email: '',
    phone: '',
    address: '',
    gender: 'MALE',
    dob: '',
    nidNumber: '',
    vehicleType: '',
    vehicleNumber: '',
    rating: 0,
    totalDeliveries: 0,
    totalEarnings: 0,
    image: '',
    password: '',
    policeStationId: 0,
    warehouseIds: []
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
  hasVehicleInfo: boolean = false;

  constructor(
    private driverService: DriverService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadProfileData();
  }

  loadProfileData(): void {
    const cachedDriver = this.storage.getData(KEYS.DRIVER) as any;
    const currentUser = this.storage.getUser();

    if (cachedDriver && cachedDriver.id) {
      this.driverService.getById(cachedDriver.id).subscribe({
        next: (data: DriverResponseModel) => {
          this.driverData = data;
          this.syncFormModel();
          this.calculateCompletion();
          this.cdr.markForCheck();
        },
        error: (err: any) => {
          this.driverData = cachedDriver;
          this.syncFormModel();
          this.calculateCompletion();
          this.errorMessage = err.error?.message || "Failed to sync profile data from gateway.";
          this.cdr.markForCheck();
        }
      });
    } else if (currentUser) {
      this.driverService.getDriverByUserId(currentUser.userId).subscribe({
        next: (data: DriverResponseModel) => {
          if (data) {
            this.driverData = data;
            this.storage.saveData(KEYS.DRIVER, data);
            this.syncFormModel();
            this.calculateCompletion();
          }
          this.cdr.markForCheck();
        },
        error: (err: any) => {
          this.errorMessage = err.error?.message || "Failed to load driver profile.";
          this.cdr.markForCheck();
        }
      });
    }
  }

  syncFormModel(): void {
    if (!this.driverData) return;
    this.editModel = {
      id: this.driverData.id,
      driverName: this.driverData.driverName,
      email: this.driverData.email,
      phone: this.driverData.phone,
      address: this.driverData.address,
      gender: this.driverData.gender || 'MALE',
      dob: this.driverData.dob ? this.driverData.dob.split('T')[0] : '',
      nidNumber: this.driverData.nidNumber,
      vehicleType: this.driverData.vehicleType,
      vehicleNumber: this.driverData.vehicleNumber,
      rating: this.driverData.rating,
      totalDeliveries: this.driverData.totalDeliveries,
      totalEarnings: this.driverData.totalEarnings,
      image: this.driverData.image,
      password: '',
      policeStationId: this.driverData.policeStationId,
      warehouseIds: []
    };
  }

  calculateCompletion(): void {
    if (!this.driverData) return;
    this.hasGeneralInfo = !!this.driverData.driverName;
    this.hasContactInfo = !!(this.driverData.phone && this.driverData.email);
    this.hasPhoto = !!this.driverData.image;
    this.hasNid = !!this.driverData.nidNumber;
    this.hasVehicleInfo = !!(this.driverData.vehicleType && this.driverData.vehicleNumber);

    let totalPoints = 0;
    if (this.hasGeneralInfo) totalPoints += 20;
    if (this.hasContactInfo) totalPoints += 20;
    if (this.hasPhoto) totalPoints += 20;
    if (this.hasNid) totalPoints += 20;
    if (this.hasVehicleInfo) totalPoints += 20;

    this.profileCompletion = totalPoints;
    this.cdr.markForCheck();
  }

  getProfileImage(): string {
    if (this.imagePreviewUrl) {
      return this.imagePreviewUrl;
    }
    if (this.driverData && this.driverData.image && !this.imageLoadError) {
      const cleanName = this.driverData.image.includes('/')
        ? this.driverData.image.substring(this.driverData.image.lastIndexOf('/') + 1)
        : this.driverData.image;
      return this.imageBaseUrl + cleanName;
    }
    return '';
  }

  onImageError(): void {
    this.imageLoadError = true;
    this.cdr.markForCheck();
  }

  getInitials(): string {
    if (!this.driverData || !this.driverData.driverName) return 'D';
    return this.driverData.driverName.charAt(0).toUpperCase();
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
    if (!this.selectedFile || !this.driverData) return;
    this.errorMessage = null;

    this.driverService.update(this.driverData.id, this.editModel, this.selectedFile).subscribe({
      next: (updatedData: DriverResponseModel) => {
        alert("Profile avatar updated successfully!");
        this.driverData = updatedData;
        this.storage.saveData(KEYS.DRIVER, updatedData);
        this.imagePreviewUrl = null;
        this.selectedFile = null;
        this.calculateCompletion();
        this.cdr.markForCheck();
      },
      error: (err: any) => this.errorMessage = err.error?.message || "Avatar synchronization failure."
    });
  }

  updateProfileData(): void {
    if (!this.driverData) return;
    this.errorMessage = null;

    this.driverService.update(this.driverData.id, this.editModel, null).subscribe({
      next: (updatedData: DriverResponseModel) => {
        alert("Driver profile credentials updated successfully!");
        this.driverData = updatedData;
        this.storage.saveData(KEYS.DRIVER, updatedData);
        this.syncFormModel();
        this.calculateCompletion();
        this.cdr.markForCheck();
      },
      error: (err: any) => this.errorMessage = err.error?.message || "Profile info mutation error."
    });
  }
}
