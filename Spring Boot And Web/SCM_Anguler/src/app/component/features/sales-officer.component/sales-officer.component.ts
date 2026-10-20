import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { CountryService } from '../../../service/country.service';
import { DivisionService } from '../../../service/division.service';
import { DistrictService } from '../../../service/district.service';
import { PoliceStationService } from '../../../service/police-station.service';
import { environment } from '../../../../environment/environment';
import { SalesOfficerRequestDTO, SalesOfficerResponseDTO } from '../../shared/model/salesOfficerModel';
import { SalesOfficerService } from '../../../service/sales-officer.service';

@Component({
  selector: 'app-sales-officer',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './sales-officer.component.html',
  styleUrl: './sales-officer.component.css',
})
export class SalesOfficerComponent implements OnInit {

  officers: SalesOfficerResponseDTO[] = [];
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

  readonly imageBaseUrl = environment.imgUrl+"sales_officer/";

  officer: SalesOfficerRequestDTO = {
    id: 0,
    address: '',
    nidNumber: '',
    dob: '',
    gender: '',
    joiningDate: '',
    designation: '',
    language: '',
    policeStationId: 0,
    name: '',
    email: '',
    phone: '',
    password: ''
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: SalesOfficerService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef
  ) { }

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
    this.officer.policeStationId = 0;

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
    this.officer.policeStationId = 0;

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
    const psName = this.policeStations.find(x => x.id == this.officer.policeStationId)?.name || '';

    this.officer.address = [
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

  private handleBackendError(err: any) {
    this.errorMessage = null;
    const errorContext = err.error?.message || err.message || '';

    if (errorContext.includes('Duplicate entry')) {
      if (errorContext.includes('@')) {
        this.errorMessage = 'Deployment Failed: This corporate email is already assigned to another staff!';
      } else if (errorContext.includes('phone_number')) {
        this.errorMessage = 'Deployment Failed: Phone index vector already active in SCM system.';
      } else {
        this.errorMessage = 'Deployment Failed: This NID number is already assigned to another staff profile!';
      }
    } else if (errorContext.includes('attachment deployment failure') || errorContext.includes('Illegal char')) {
      this.errorMessage = 'I/O Fault: Avoid punctuation or colons (:) inside the Name fields.';
    } else {
      this.errorMessage = errorContext || 'An unexpected transaction dropped at core persistence layer.';
    }
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null;

    if (!this.isEdit && this.officer.password !== this.confirmPassword) {
      this.errorMessage = 'Validation Fault: Access passwords mismatched.';
      return;
    }

    if (this.officer.policeStationId === 0) {
      this.errorMessage = 'Validation Fault: Complete territorial sequence up to Police Station terminal.';
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.officer, this.selectedFile).subscribe({
        next: () => {
          alert("Sales Officer profile mutated successfully!");
          this.closeDrawer();
          this.loadOfficers();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.officer, this.selectedFile).subscribe({
        next: () => {
          alert("Sales Officer station successfully initialized!");
          this.closeDrawer();
          this.loadOfficers();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  edit(o: SalesOfficerResponseDTO) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;

    this.officer = {
      id: o.id,
      address: o.address,
      nidNumber: o.nidNumber,
      dob: o.dob,
      gender: o.gender,
      joiningDate: o.joiningDate,
      designation: o.designation,
      language: o.language,
      policeStationId: o.policeStationId,
      name: o.name,
      email: o.email,
      phone: o.phone,
      password: ''
    };

    const addressParts = o.address ? o.address.split(', ') : [];
    this.streetAddress = addressParts[0] || '';
    this.imagePreview = o.image ? this.getImageUrl(o.image) : null;

    this.selectedCountryId = (o as any).countryId ? +(o as any).countryId : null;
    this.selectedDivisionId = (o as any).divisionId ? +(o as any).divisionId : null;
    this.selectedDistrictId = (o as any).districtId ? +(o as any).districtId : null;
    this.officer.policeStationId = o.policeStationId ? +o.policeStationId : 0;

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
    if (confirm("Definitively clear this sales officer workstation node?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Sales Officer profile successfully cleared.");
          this.loadOfficers();
        },
        error: (err: any) => alert('Transaction mutation fault abort.')
      });
    }
  }

  reset() {
    this.officer = {
      id: 0,
      address: '',
      nidNumber: '',
      dob: '',
      gender: '',
      joiningDate: '',
      designation: '',
      language: '',
      policeStationId: 0,
      name: '',
      email: '',
      phone: '',
      password: ''
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
