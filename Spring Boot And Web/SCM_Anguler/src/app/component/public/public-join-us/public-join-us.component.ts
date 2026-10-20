import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { CustomerService } from '../../../service/customer.service';
import { CustomerRequestModel } from '../../shared/model/customerModel';
import { CountryService } from '../../../service/country.service';
import { DivisionService } from '../../../service/division.service';
import { DistrictService } from '../../../service/district.service';
import { PoliceStationService } from '../../../service/police-station.service';

@Component({
  selector: 'app-public-join-us',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './public-join-us.component.html',
  styleUrls: ['./public-join-us.component.css']
})
export class PublicJoinUsComponent implements OnInit {
  currentStep = 1;
  isSubmitting = false;
  isSubmitted = false;
  registrationSuccess = false;
  errorMessage: string | null = null;
  confirmPassword = '';
  agreeTerms = true;

  countries: any[] = [];
  divisions: any[] = [];
  districts: any[] = [];
  policeStations: any[] = [];

  selectedCountryId: number | null = null;
  selectedDivisionId: number | null = null;
  selectedDistrictId: number | null = null;

  selectedFile: File | null = null;
  imagePreview: string | ArrayBuffer | null = null;
  streetAddress = '';

  customer: CustomerRequestModel = {
    name: '',
    email: '',
    phone: '',
    password: '',
    address: '',
    gender: '',
    dob: '',
    nidNumber: '',
    policeStationId: 0,
  };

  benefits = [
    'Access global procurement marketplace with 10,000+ suppliers',
    'Real-time freight tracking across 150+ ports worldwide',
    'Automated customs compliance and HS code verification',
    'Manage purchase orders, quotations, and invoices',
    'Warehouse inventory management and stock visibility',
    '24/7 customer support from logistics experts',
  ];

  constructor(
    private service: CustomerService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadCountries();
  }

  loadCountries() {
    this.countryService.getAll().subscribe({
      next: (data) => {
        this.countries = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  onCountryChange() {
    this.divisions = [];
    this.districts = [];
    this.policeStations = [];
    this.selectedDivisionId = null;
    this.selectedDistrictId = null;
    this.customer.policeStationId = 0;

    if (!this.selectedCountryId) return;

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
    this.customer.policeStationId = 0;

    if (!this.selectedDivisionId) return;

    this.districtService.getByDivisionId(this.selectedDivisionId).subscribe((res) => {
      this.districts = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  onDistrictChange() {
    this.policeStations = [];
    this.customer.policeStationId = 0;

    if (!this.selectedDistrictId) return;

    this.stationService.getByDistrictId(this.selectedDistrictId).subscribe((res) => {
      this.policeStations = res || [];
      this.generateFullAddress();
      this.cdr.markForCheck();
    });
  }

  onStationChange() {
    this.generateFullAddress();
  }

  generateFullAddress() {
    const countryName = this.countries.find(x => x.id == this.selectedCountryId)?.name || '';
    const divisionName = this.divisions.find(x => x.id == this.selectedDivisionId)?.name || '';
    const districtName = this.districts.find(x => x.id == this.selectedDistrictId)?.name || '';
    const psName = this.policeStations.find(x => x.id == this.customer.policeStationId)?.name || '';

    this.customer.address = [
      this.streetAddress.trim(),
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

  nextStep(): void {
    this.errorMessage = null;
    if (this.currentStep === 1) {
      if (!this.customer.name || this.customer.name.trim().length < 3) {
        this.errorMessage = 'Please enter a valid full name (minimum 3 characters).';
        return;
      }
      if (!this.customer.email || !this.customer.email.includes('@')) {
        this.errorMessage = 'Please enter a valid email address.';
        return;
      }
      if (!this.customer.phone || this.customer.phone.trim().length < 11) {
        this.errorMessage = 'Please enter a valid 11-digit phone number.';
        return;
      }
      if (!this.customer.password || this.customer.password.length < 6) {
        this.errorMessage = 'Password must be at least 6 characters long.';
        return;
      }
      if (this.customer.password !== this.confirmPassword) {
        this.errorMessage = 'Passwords do not match.';
        return;
      }
    } else if (this.currentStep === 2) {
      if (!this.customer.nidNumber || this.customer.nidNumber.trim().length < 10) {
        this.errorMessage = 'Please enter a valid National ID (NID) number.';
        return;
      }
    }

    if (this.currentStep < 3) {
      this.currentStep++;
      this.cdr.markForCheck();
    }
  }

  prevStep(): void {
    this.errorMessage = null;
    if (this.currentStep > 1) {
      this.currentStep--;
      this.cdr.markForCheck();
    }
  }

  register(): void {
    this.errorMessage = null;
    this.isSubmitted = true;

    if (!this.agreeTerms) {
      this.errorMessage = 'You must agree to the Terms of Service and Privacy Policy.';
      return;
    }

    if (this.customer.password !== this.confirmPassword) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }

    if (!this.customer.policeStationId || Number(this.customer.policeStationId) === 0) {
      this.errorMessage = 'Please complete the location selection (Country -> Division -> District -> Police Station).';
      return;
    }

    this.generateFullAddress();
    this.isSubmitting = true;

    const formData = new FormData();

    const requestDto: CustomerRequestModel = {
      name: (this.customer.name || '').trim(),
      email: (this.customer.email || '').trim(),
      phone: (this.customer.phone || '').trim(),
      password: this.customer.password,
      address: (this.customer.address || '').trim(),
      gender: this.customer.gender || 'MALE',
      dob: this.customer.dob ? this.customer.dob : '',
      nidNumber: (this.customer.nidNumber || '').trim(),
      policeStationId: Number(this.customer.policeStationId),
    };

    formData.append(
      'customer',
      new Blob([JSON.stringify(requestDto)], { type: 'application/json' })
    );

    if (this.selectedFile) {
      formData.append('image', this.selectedFile);
    }

    this.service.save(formData).subscribe({
      next: () => {
        this.registrationSuccess = true;
        this.isSubmitting = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        this.isSubmitting = false;
        const errorContext = err.error?.message || err.message || '';
        
        if (errorContext.toLowerCase().includes('email') || errorContext.includes('@')) {
          this.errorMessage = '⚠️ This Gmail / Email address is already registered! Please use a different email or sign in.';
        } else if (errorContext.toLowerCase().includes('nid')) {
          this.errorMessage = '⚠️ This NID number is already registered in our system!';
        } else if (errorContext.toLowerCase().includes('phone')) {
          this.errorMessage = '⚠️ This phone number is already in use!';
        } else if (errorContext.includes('Duplicate entry')) {
          this.errorMessage = '⚠️ Account with this Email, NID or Phone already exists!';
        } else {
          this.errorMessage = errorContext || 'Registration failed. Please check your data and try again.';
        }
        this.cdr.markForCheck();
      }
    });
  }
}
