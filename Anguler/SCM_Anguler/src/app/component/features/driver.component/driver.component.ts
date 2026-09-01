import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CountryService } from '../../../service/country.service';
import { DivisionService } from '../../../service/division.service';
import { DistrictService } from '../../../service/district.service';
import { PoliceStationService } from '../../../service/police-station.service';
import { WarehouseService } from '../../../service/warehouse.service';
import { environment } from '../../../../environment/environment';
import { DriverRequestModel, DriverResponseModel } from '../../shared/model/driverModel';
import { DriverService } from '../../../service/driver.service';

@Component({
  selector: 'app-driver',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './driver.component.html',
  styleUrl: './driver.component.css',
})
export class DriverComponent implements OnInit {

  drivers: DriverResponseModel[] = [];
  warehouses: any[] = [];
  
  countries: any[] = [];
  divisions: any[] = [];
  districts: any[] = [];
  policeStations: any[] = [];

  selectedCountryId: number | null = null;
  selectedDivisionId: number | null = null;
  selectedDistrictId: number | null = null;

  selectedFile: File | null = null;
  imagePreview: string | ArrayBuffer | null = null;
  streetAddress: string = '';
  confirmPassword = '';
  
  errorMessage: string | null = null;

  readonly imageBaseUrl = environment.imgUrl+"driver/";

  driver: DriverRequestModel = {
    id: 0,
    driverName: '',
    phone: '',
    address: '',
    nidNumber: '',
    gender: '',
    email: '',
    vehicleType: '',
    vehicleNumber: '',
    dob: '',
    rating: 5.0,
    totalDeliveries: 0,
    totalEarnings: 0.0,
    image: '',
    password: '',
    policeStationId: 0,
    warehouseIds: []
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: DriverService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private warehouseService: WarehouseService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadDrivers();
    this.loadCountries();
    this.loadAllWarehouses();
  }

  openDrawer() {
    this.reset();
    this.isEdit = false;
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.reset();
    this.cdr.markForCheck();
  }

  loadDrivers() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.drivers = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  loadCountries() {
    this.countryService.getAll().subscribe({
      next: (data) => {
        this.countries = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  loadAllWarehouses() {
    this.warehouseService.getAll().subscribe({
      next: (data) => {
        this.warehouses = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  toggleWarehouseSelection(warehouseId: number, event: Event) {
    const checked = (event.target as HTMLInputElement).checked;
    if (checked) {
      if (!this.driver.warehouseIds.includes(warehouseId)) {
        this.driver.warehouseIds.push(warehouseId);
      }
    } else {
      this.driver.warehouseIds = this.driver.warehouseIds.filter(id => id !== warehouseId);
    }
  }

  onCountryChange() {
    this.divisions = [];
    this.districts = [];
    this.policeStations = [];
    this.selectedDivisionId = null;
    this.selectedDistrictId = null;
    this.driver.policeStationId = 0;

    if (!this.selectedCountryId) {
      this.generateFullAddress();
      return;
    }

    this.divisionService.getByCountryId(this.selectedCountryId).subscribe(res => {
      this.divisions = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  onDivisionChange() {
    this.districts = [];
    this.policeStations = [];
    this.selectedDistrictId = null;
    this.driver.policeStationId = 0;

    if (!this.selectedDivisionId) {
      this.generateFullAddress();
      return;
    }

    this.districtService.getByDivisionId(this.selectedDivisionId).subscribe(res => {
      this.districts = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  onDistrictChange() {
    this.policeStations = [];
    this.driver.policeStationId = 0;

    if (!this.selectedDistrictId) {
      this.generateFullAddress();
      return;
    }

    this.stationService.getByDistrictId(this.selectedDistrictId).subscribe(res => {
      this.policeStations = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  generateFullAddress() {
    const countryName = this.countries.find(x => x.id == this.selectedCountryId)?.name || '';
    const divisionName = this.divisions.find(x => x.id == this.selectedDivisionId)?.name || '';
    const districtName = this.districts.find(x => x.id == this.selectedDistrictId)?.name || '';
    const psName = this.policeStations.find(x => x.id == this.driver.policeStationId)?.name || '';

    this.driver.address = [
      this.streetAddress,
      psName,
      districtName,
      divisionName,
      countryName
    ].filter(v => v && v.trim() !== '').join(', ');
  }

  onFileSelected(event: any) {
    const file: File = event.target.files[0];
    if (!file) return;

    this.selectedFile = file;
    const reader = new FileReader();
    reader.onload = () => {
      this.imagePreview = reader.result;
      this.cdr.markForCheck();
    };
    reader.readAsDataURL(file);
  }

  removeSelectedFile(fileInput: HTMLInputElement) {
    this.selectedFile = null;
    this.imagePreview = null;
    fileInput.value = '';
    this.cdr.markForCheck();
  }

  getImageUrl(imagePath: string | null | undefined): string {
    return imagePath ? `${this.imageBaseUrl}${imagePath}` : '';
  }

  onImageError(event: Event): void {
    const target = event.target as HTMLImageElement | null;
    if (target) {
      target.style.display = 'none';
    }
  }

  // ব্যাকএন্ড এরর মেসেজ পার্স করার মেথড
  private handleBackendError(err: any) {
    console.error('Raw Server Error:', err);
    this.errorMessage = null;

    const errorContext = err.error?.message || err.message || '';

    if (errorContext.includes('Duplicate entry')) {
      if (errorContext.includes('@')) {
        this.errorMessage = 'Deployment Failed: This Email Address is already registered under another account!';
      } else if (errorContext.includes('users.UK9q63snka3mdh91as4io72espi') || errorContext.includes('phone_number')) {
        this.errorMessage = 'Deployment Failed: This Phone Number is already in use!';
      } else {
        this.errorMessage = 'Deployment Failed: Duplicate entry detected (NID/Passport or Identity Constraint violation).';
      }
    } else if (errorContext.includes('Illegal char')) {
      this.errorMessage = 'File System Fault: Special characters or colons (:) are forbidden in Driver Name field!';
    } else {
      this.errorMessage = errorContext || 'An unexpected internal gateway transaction error occurred.';
    }
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null; 

    if (!this.isEdit && this.driver.password !== this.confirmPassword) {
      this.errorMessage = 'Validation Fault: Password and confirm password inputs do not match.';
      return;
    }

    if (this.driver.policeStationId === 0) {
      this.errorMessage = 'Validation Fault: Please complete the region distribution up to Police Station.';
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.driver, this.selectedFile).subscribe({
        next: () => {
          alert("Driver configuration nodes updated successfully!");
          this.closeDrawer();
          this.loadDrivers();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.driver, this.selectedFile).subscribe({
        next: () => {
          alert("Driver logistics station successfully deployed!");
          this.closeDrawer();
          this.loadDrivers();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  edit(d: DriverResponseModel) {
    this.errorMessage = null;
    this.currentEditId = d.id;
    this.isEdit = true;

    this.driver = {
      id: d.id,
      driverName: d.driverName,
      phone: d.phone,
      address: d.address,
      nidNumber: d.nidNumber,
      gender: d.gender,
      email: d.email,
      vehicleType: d.vehicleType,
      vehicleNumber: d.vehicleNumber,
      dob: d.dob,
      rating: d.rating,
      totalDeliveries: d.totalDeliveries,
      totalEarnings: d.totalEarnings,
      image: d.image,
      password: '', 
      policeStationId: d.policeStationId,
      warehouseIds: []
    };

    const addressParts = d.address ? d.address.split(', ') : [];
    this.streetAddress = addressParts[0] || '';
    this.imagePreview = d.image ? this.getImageUrl(d.image) : null; 

    this.selectedCountryId = (d as any).countryId ? +(d as any).countryId : null;
    this.selectedDivisionId = (d as any).divisionId ? +(d as any).divisionId : null;
    this.selectedDistrictId = (d as any).districtId ? +(d as any).districtId : null;
    this.driver.policeStationId = d.policeStationId ? +d.policeStationId : 0;

    if (this.selectedCountryId) {
      this.divisionService.getByCountryId(this.selectedCountryId).subscribe(res => {
        this.divisions = res || [];
        if (this.selectedDivisionId) {
          this.districtService.getByDivisionId(this.selectedDivisionId).subscribe(res2 => {
            this.districts = res2 || [];
            if (this.selectedDistrictId) {
              this.stationService.getByDistrictId(this.selectedDistrictId).subscribe(res3 => {
                this.policeStations = res3 || [];
                this.cdr.markForCheck();
              });
            }
          });
        }
      });
    }

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Definitively remove this driver agent configuration node?")) {
      this.service.delete(id).subscribe({
        next: () => {
          this.loadDrivers();
        },
        error: (err: any) => alert('Delete operation failed.')
      });
    }
  }

  reset() {
    this.driver = {
      id: 0,
      driverName: '',
      phone: '',
      address: '',
      nidNumber: '',
      gender: '',
      email: '',
      vehicleType: '',
      vehicleNumber: '',
      dob: '',
      rating: 5.0,
      totalDeliveries: 0,
      totalEarnings: 0.0,
      image: '',
      password: '',
      policeStationId: 0,
      warehouseIds: []
    };
    this.selectedCountryId = null;
    this.selectedDivisionId = null;
    this.selectedDistrictId = null;
    this.divisions = [];
    this.districts = [];
    this.policeStations = [];
    this.selectedFile = null;
    this.imagePreview = null;
    this.streetAddress = '';
    this.confirmPassword = '';
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }
}
