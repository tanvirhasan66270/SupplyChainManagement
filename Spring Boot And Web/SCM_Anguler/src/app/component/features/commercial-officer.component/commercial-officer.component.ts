import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { CountryService } from '../../../service/country.service';
import { DivisionService } from '../../../service/division.service';
import { DistrictService } from '../../../service/district.service';
import { PoliceStationService } from '../../../service/police-station.service';
import { environment } from '../../../../environment/environment';
import { CommercialOfficerService } from '../../../service/commercial-officer.service';
import {
  CommercialOfficerRequestModel,
  CommercialOfficerResponseModel,
} from '../../shared/model/commercialOfficer';

@Component({
  selector: 'app-commercial-officer',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './commercial-officer.component.html',
  styleUrl: './commercial-officer.component.css',
})
export class CommercialOfficerComponent implements OnInit {
  officers: CommercialOfficerResponseModel[] = [];

  countries: any[] = [];
  divisions: any[] = [];
  districts: any[] = [];
  policeStations: any[] = [];

  selectedCountryId: number | null = null;
  selectedDivisionId: number | null = null;
  selectedDistrictId: number | null = null;

  selectedFile: File | null = null;
  imagePreview: string | ArrayBuffer | null = null;
  errorMessage: string | null = null;
  streetAddress: string = '';
  confirmPassword = '';

  readonly imageBaseUrl = environment.imgUrl + 'commercial_officer/';

  officer: CommercialOfficerRequestModel = {
    address: '',
    nidNumber: '',
    passportNumber: '',
    dob: '',
    gender: '',
    joiningDate: '',
    designation: '',
    language: '',
    policeStationId: 0,
    name: '',
    email: '',
    phone: '',
    password: '',
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: CommercialOfficerService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef,
  ) {}

  ngOnInit() {
    this.loadOfficers();
    this.loadCountries();
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

  loadOfficers() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.officers = data || [];
        this.cdr.markForCheck();
      },
    });
  }

  loadCountries() {
    this.countryService.getAll().subscribe({
      next: (data) => {
        this.countries = data || [];
        this.cdr.markForCheck();
      },
    });
  }

  onCountryChange() {
    this.divisions = [];
    this.districts = [];
    this.policeStations = [];
    this.selectedDivisionId = null;
    this.selectedDistrictId = null;
    this.officer.policeStationId = 0;

    if (!this.selectedCountryId) {
      this.generateFullAddress();
      return;
    }

    this.divisionService.getByCountryId(this.selectedCountryId).subscribe((res) => {
      this.divisions = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  onDivisionChange() {
    this.districts = [];
    this.policeStations = [];
    this.selectedDistrictId = null;
    this.officer.policeStationId = 0;

    if (!this.selectedDivisionId) {
      this.generateFullAddress();
      return;
    }

    this.districtService.getByDivisionId(this.selectedDivisionId).subscribe((res) => {
      this.districts = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  onDistrictChange() {
    this.policeStations = [];
    this.officer.policeStationId = 0;

    if (!this.selectedDistrictId) {
      this.generateFullAddress();
      return;
    }

    this.stationService.getByDistrictId(this.selectedDistrictId).subscribe((res) => {
      this.policeStations = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  onDivisionOrDistrictEditPipeline(countryId: number, divisionId: number, districtId: number) {
    this.divisionService.getByCountryId(countryId).subscribe((res) => {
      this.divisions = res || [];
      this.districtService.getByDivisionId(divisionId).subscribe((res2) => {
        this.districts = res2 || [];
        this.stationService.getByDistrictId(districtId).subscribe((res3) => {
          this.policeStations = res3 || [];
          this.cdr.markForCheck();
        });
      });
    });
  }

  generateFullAddress() {
    const countryName = this.countries.find((x) => x.id == this.selectedCountryId)?.name || '';
    const divisionName = this.divisions.find((x) => x.id == this.selectedDivisionId)?.name || '';
    const districtName = this.districts.find((x) => x.id == this.selectedDistrictId)?.name || '';
    const psName =
      this.policeStations.find((x) => x.id == this.officer.policeStationId)?.name || '';

    this.officer.address = [
      this.streetAddress.trim(),
      psName,
      districtName,
      divisionName,
      countryName,
    ]
      .filter((v) => v && v.trim() !== '')
      .join(', ');
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

  getImageUrl(imageName: string | null | undefined): string {
    return imageName ? `${this.imageBaseUrl}${imageName}` : '';
  }

  onImageError(event: Event): void {
    const target = event.target as HTMLImageElement | null;
    if (target) {
      target.style.display = 'none';
    }
  }

  private handleBackendError(err: any) {
    this.errorMessage = null;
    const errorContext = err.error?.message || err.message || '';

    if (errorContext.includes('Duplicate entry')) {
      if (errorContext.includes('@')) {
        this.errorMessage = 'Deployment Failed: This Email Address is already registered!';
      } else if (errorContext.includes('phone_number') || errorContext.includes('phone')) {
        this.errorMessage = 'Deployment Failed: This Phone Number is already in use!';
      } else {
        this.errorMessage = 'Deployment Failed: This NID or Passport number is already assigned!';
      }
    } else if (errorContext.includes('Illegal char') || errorContext.includes('file system node')) {
      this.errorMessage =
        'File System Fault: Special characters or colons (:) are forbidden in Name fields!';
    } else {
      this.errorMessage = errorContext || 'An unexpected server gateway error occurred.';
    }
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null;

    if (!this.isEdit && this.officer.password !== this.confirmPassword) {
      this.errorMessage = 'Validation Fault: Password and confirm password inputs do not match.';
      return;
    }

    if (this.officer.policeStationId === 0) {
      this.errorMessage =
        'Validation Fault: Please complete the location hierarchy up to Police Station.';
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.officer, this.selectedFile).subscribe({
        next: () => {
          alert('Commercial Officer profile updated successfully!');
          this.closeDrawer();
          this.loadOfficers();
        },
        error: (err: any) => this.handleBackendError(err),
      });
    } else {
      this.service.save(this.officer, this.selectedFile).subscribe({
        next: () => {
          alert('Commercial Officer deployed successfully!');
          this.closeDrawer();
          this.loadOfficers();
        },
        error: (err: any) => this.handleBackendError(err),
      });
    }
  }

  edit(o: CommercialOfficerResponseModel) {
    this.currentEditId = o.id;
    this.isEdit = true;
    this.errorMessage = null;

    this.officer = {
      name: o.name,
      email: o.email,
      phone: o.phone,
      password: '',
      address: o.address || '',
      gender: o.gender || '',
      dob: o.dob || '',
      nidNumber: o.nidNumber || '',
      passportNumber: o.passportNumber || '',
      designation: o.designation || '',
      joiningDate: o.joiningDate || '',
      language: o.language || '',
      policeStationId: o.policeStationId || 0,
    };

    const addressParts = o.address ? o.address.split(', ') : [];
    this.streetAddress = addressParts[0] || '';

    this.imagePreview = o.image ? this.getImageUrl(o.image) : null;

    // Handle incoming locations mapping safely explicitly typing target object variables
    this.selectedCountryId = (o as any).countryId ? +(o as any).countryId : null;
    this.selectedDivisionId = (o as any).divisionId ? +(o as any).divisionId : null;
    this.selectedDistrictId = (o as any).districtId ? +(o as any).districtId : null;
    this.officer.policeStationId = o.policeStationId ? +o.policeStationId : 0;

    if (this.selectedCountryId && this.selectedDivisionId && this.selectedDistrictId) {
      this.onDivisionOrDistrictEditPipeline(
        this.selectedCountryId,
        this.selectedDivisionId,
        this.selectedDistrictId,
      );
    }

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm('Purge this commercial officer node definitively?')) {
      this.service.delete(id).subscribe({
        next: () => {
          alert('Officer record successfully purged.');
          this.loadOfficers();
        },
        error: (err: any) => this.handleBackendError(err),
      });
    }
  }

  reset() {
    this.officer = {
      name: '',
      email: '',
      phone: '',
      password: '',
      address: '',
      gender: '',
      dob: '',
      nidNumber: '',
      passportNumber: '',
      designation: '',
      joiningDate: '',
      language: '',
      policeStationId: 0,
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
