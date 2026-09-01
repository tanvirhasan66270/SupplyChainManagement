import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { CountryService } from '../../../service/country.service';
import { DivisionService } from '../../../service/division.service';
import { DistrictService } from '../../../service/district.service';
import { PoliceStationService } from '../../../service/police-station.service';
import { environment } from '../../../../environment/environment';
import { ManagerRequestModel, ManagerResponseModel } from '../../shared/model/manager';
import { ManagerService } from '../../../service/manager.service';

@Component({
  selector: 'app-manager',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './manager.component.html',
  styleUrl: './manager.component.css',
})
export class ManagerComponent implements OnInit {

  managers: ManagerResponseModel[] = [];

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

  readonly imageBaseUrl = environment.imgUrl+"manager/";

  manager: ManagerRequestModel = {
    id: 0,
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
    password: ''
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: ManagerService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadManagers();
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

  loadManagers() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.managers = data || [];
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
    this.manager.policeStationId = 0;

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
    this.manager.policeStationId = 0;

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
    this.manager.policeStationId = 0;

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
    const psName = this.policeStations.find(x => x.id == this.manager.policeStationId)?.name || '';

    this.manager.address = [
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
        this.errorMessage = 'Transaction Aborted: This Email Address is already allocated to another manager node!';
      } else if (errorContext.includes('phone_number')) {
        this.errorMessage = 'Transaction Aborted: This Contact Phone Vector is already active!';
      } else {
        this.errorMessage = 'Transaction Aborted: Duplicate Identity constraints detected (NID/Passport clash).';
      }
    } else if (errorContext.includes('Illegal char') || errorContext.includes('system file upload fault')) {
      this.errorMessage = 'I/O Exception: Avoid punctuation or colons (:) inside the Manager Full Name field!';
    } else {
      this.errorMessage = errorContext || 'An unresolved relational transaction fault popped up inside the SCM layer.';
    }
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null;

    if (!this.isEdit && this.manager.password !== this.confirmPassword) {
      this.errorMessage = 'Validation Fault: Management credentials password verification mismatched.';
      return;
    }

    if (this.manager.policeStationId === 0) {
      this.errorMessage = 'Validation Fault: Local base station terminal configuration hierarchy incomplete.';
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.manager, this.selectedFile).subscribe({
        next: () => {
          alert("Manager profile node mutated successfully!");
          this.closeDrawer();
          this.loadManagers();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.manager, this.selectedFile).subscribe({
        next: () => {
          alert("New Management infrastructure deployed successfully!");
          this.closeDrawer();
          this.loadManagers();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  edit(m: ManagerResponseModel) {
    this.errorMessage = null;
    this.currentEditId = m.id;
    this.isEdit = true;

    this.manager = {
      id: m.id,
      address: m.address,
      nidNumber: m.nidNumber,
      passportNumber: m.passportNumber,
      dob: m.dob,
      gender: m.gender,
      joiningDate: m.joiningDate,
      designation: m.designation,
      language: m.language,
      policeStationId: m.policeStationId,
      name: m.name,
      email: m.email,
      phone: m.phone,
      password: ''
    };

    const addressParts = m.address ? m.address.split(', ') : [];
    this.streetAddress = addressParts[0] || '';
    
    this.imagePreview = m.image ? this.getImageUrl(m.image) : null; 

    this.selectedCountryId = (m as any).countryId ? +(m as any).countryId : null;
    this.selectedDivisionId = (m as any).divisionId ? +(m as any).divisionId : null;
    this.selectedDistrictId = (m as any).districtId ? +(m as any).districtId : null;
    this.manager.policeStationId = m.policeStationId ? +m.policeStationId : 0;

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
    if (confirm("Definitively remove this Management registry signature from corporate architecture?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Manager node successfully purged.");
          this.loadManagers();
        },
        error: (err: any) => alert('Relational transactional mutation constraint broken on target entity.')
      });
    }
  }

  reset() {
    this.manager = {
      id: 0,
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
