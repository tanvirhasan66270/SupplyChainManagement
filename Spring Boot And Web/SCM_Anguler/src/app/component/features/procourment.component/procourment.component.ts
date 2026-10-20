import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { CountryService } from '../../../service/country.service';
import { DivisionService } from '../../../service/division.service';
import { DistrictService } from '../../../service/district.service';
import { PoliceStationService } from '../../../service/police-station.service';
import { environment } from '../../../../environment/environment';
import { ProcurementRequestModel, ProcurementResponseDTO } from '../../shared/model/procourmentModel';
import { ProcurementService } from '../../../service/procourment.service';

@Component({
  selector: 'app-procurement',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './procourment.component.html',
  styleUrls: ['./procourment.component.css'],
})
export class ProcourmentComponent implements OnInit {

  procurements: ProcurementResponseDTO[] = [];
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

readonly imageBaseUrl = environment.imgUrl + "procurement/";
  procurement: ProcurementRequestModel = {
    id: 0,
    address: '',
    nidNumber: '',
    passportNumber: '',
    dob: '',
    gender: '',
    isActive: false,
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
    private service: ProcurementService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadProcurements();
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

  loadProcurements() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.procurements = data || [];
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

  // =====================================================
  // CASCADING LOCATION LOGICS 
  // =====================================================
  onCountryChange() {
    this.divisions = [];
    this.districts = [];
    this.policeStations = [];
    this.selectedDivisionId = null;
    this.selectedDistrictId = null;
    this.procurement.policeStationId = 0;

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
    this.procurement.policeStationId = 0;

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
    this.procurement.policeStationId = 0;

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

  onDivisionOrDistrictEditPipeline(countryId: number, divisionId: number, districtId: number) {
    this.divisionService.getByCountryId(countryId).subscribe(res => {
      this.divisions = res || [];
      this.districtService.getByDivisionId(divisionId).subscribe(res2 => {
        this.districts = res2 || [];
        this.stationService.getByDistrictId(districtId).subscribe(res3 => {
          this.policeStations = res3 || [];
          this.cdr.markForCheck();
        });
      });
    });
  }

  // =====================================================
  // AUTO ADDRESS COMPILER
  // =====================================================
  generateFullAddress() {
    const countryName = this.countries.find(x => x.id == this.selectedCountryId)?.name || '';
    const divisionName = this.divisions.find(x => x.id == this.selectedDivisionId)?.name || '';
    const districtName = this.districts.find(x => x.id == this.selectedDistrictId)?.name || '';
    const psName = this.policeStations.find(x => x.id == this.procurement.policeStationId)?.name || '';

    this.procurement.address = [
      this.streetAddress.trim(),
      psName,
      districtName,
      divisionName,
      countryName
    ].filter(v => v && v.trim() !== '').join(', ');
  }

  // =====================================================
  // FILE CAPTURE HANDLER
  // =====================================================
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

 
  private handleBackendError(err: any) {
    this.errorMessage = null;
    const errorContext = err.error?.message || err.message || '';

    if (errorContext.includes('Duplicate entry')) {
      if (errorContext.includes('@')) {
        this.errorMessage = 'Integration Broken: This corporate email is already allocated to another profile!';
      } else if (errorContext.includes('Passport')) {
        this.errorMessage = 'Integration Broken: This Passport number is already registered under another officer!';
      } else {
        this.errorMessage = 'Integration Broken: This NID number is already registered under another officer!';
      }
    } else if (errorContext.includes('storage node allocation failure') || errorContext.includes('Illegal char')) {
      this.errorMessage = 'I/O Exception: Avoid using colons (:) or non-alphanumeric symbols in Name fields.';
    } else {
      this.errorMessage = errorContext || 'An unexpected runtime operational mutation exception occurred.';
    }
    this.cdr.markForCheck();
  }

  removeSelectedFile(fileInput: HTMLInputElement) {
    this.selectedFile = null;
    this.imagePreview = null;
    fileInput.value = '';
    this.cdr.markForCheck();
  }

  getImageUrl(imagePath: string | null | undefined): string {
    if (!imagePath) return '';
    if (imagePath.startsWith('http')) return imagePath;

    const baseUrl = this.imageBaseUrl.replace(/\/$/, '');
    const cleanImagePath = imagePath.replace(/^\//, '');

    return `${baseUrl}/${cleanImagePath}`;
  }

  onImageError(event: Event): void {
    const target = event.target as HTMLImageElement | null;
    if (target) {
      target.style.display = 'none';
    }
  }

  // =====================================================
  // SAVE / UPDATE MATRIX HANDLER
  // =====================================================
  save() {
    this.errorMessage = null;

    if (!this.isEdit && this.procurement.password !== this.confirmPassword) {
      this.errorMessage = 'Validation Fault: Gate access configuration passwords do not match.';
      return;
    }

    if (this.procurement.policeStationId === 0) {
      this.errorMessage = 'Validation Fault: Complete territorial sequence up to active Police Station.';
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.procurement, this.selectedFile).subscribe({
        next: () => {
          alert("Procurement profile node mutated successfully!");
          this.closeDrawer();
          this.loadProcurements();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.procurement, this.selectedFile).subscribe({
        next: () => {
          alert("Procurement Officer successfully initialized!");
          this.closeDrawer();
          this.loadProcurements();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  // =====================================================
  // EDIT ENTRY ROW MAPPING
  // =====================================================
  edit(o: ProcurementResponseDTO) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;

    this.procurement = {
      id: o.id,
      address: o.address,
      nidNumber: o.nidNumber,
      passportNumber: o.passportNumber,
      dob: o.dob,
      gender: o.gender,
      isActive: o.isActive,
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

    this.selectedCountryId = (o as any).countryId ? +(o as any).countryId : ((o as any).policeStation?.district?.division?.country?.id || null);
    this.selectedDivisionId = (o as any).divisionId ? +(o as any).divisionId : ((o as any).policeStation?.district?.division?.id || null);
    this.selectedDistrictId = (o as any).districtId ? +(o as any).districtId : ((o as any).policeStation?.district?.id || null);
    this.procurement.policeStationId = o.policeStationId ? +o.policeStationId : 0;

    if (!this.selectedCountryId && (o as any).country) { this.selectedCountryId = +(o as any).country.id; }
    if (!this.selectedDivisionId && (o as any).division) { this.selectedDivisionId = +(o as any).division.id; }
    if (!this.selectedDistrictId && (o as any).district) { this.selectedDistrictId = +(o as any).district.id; }

    if (this.selectedCountryId && this.selectedDivisionId && this.selectedDistrictId) {
      this.onDivisionOrDistrictEditPipeline(this.selectedCountryId, this.selectedDivisionId, this.selectedDistrictId);
    }

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Definitively remove this procurement matrix node from logistics cluster?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Procurement workstation signature safely cleared.");
          this.loadProcurements();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  reset() {
    this.procurement = {
      id: 0,
      address: '',
      nidNumber: '',
      passportNumber: '',
      dob: '',
      gender: '',
      isActive: false,
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