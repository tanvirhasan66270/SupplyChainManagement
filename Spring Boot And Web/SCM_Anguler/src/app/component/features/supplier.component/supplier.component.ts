import { CommonModule } from "@angular/common";
import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import { FormsModule } from "@angular/forms";
import { SupplierRequestDTO, SupplierResponseDTO } from "../../shared/model/supplierModel";
import { environment } from "../../../../environment/environment";
import { SupplierService } from "../../../service/supplier.service";
import { CountryService } from "../../../service/country.service";
import { DivisionService } from "../../../service/division.service";
import { DistrictService } from "../../../service/district.service";
import { PoliceStationService } from "../../../service/police-station.service";


@Component({
  selector: 'app-supplier',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './supplier.component.html',
  styleUrl: './supplier.component.css',
})
export class SupplierComponent implements OnInit {

  suppliers: SupplierResponseDTO[] = [];
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

  readonly imageBaseUrl = environment.imgUrl+"supplier/";
  

  supplier: SupplierRequestDTO = {
    name: '',
    email: '',
    phone: '',
    password: '',
    contactPerson: '',
    address: '',
    nidNumber: '',
    passportNumber: '',
    gender: '',
    dob: '',
    image: '',
    rating: 5.0,
    averageLeadTimeDays: 1,
    policeStationId: 0
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: SupplierService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadSuppliers();
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

  loadSuppliers() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.suppliers = data || [];
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
    this.supplier.policeStationId = 0;

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
    this.supplier.policeStationId = 0;

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
    this.supplier.policeStationId = 0;

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
    const psName = this.policeStations.find(x => x.id == this.supplier.policeStationId)?.name || '';

    this.supplier.address = [
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
        this.errorMessage = 'Deployment Failed: This corporate Email Address is already registered!';
      } else if (errorContext.includes('phone_number')) {
        this.errorMessage = 'Deployment Failed: Phone index vector already active.';
      } else {
        this.errorMessage = 'Deployment Failed: This National ID (NID) is already assigned to another profile!';
      }
    } else if (errorContext.includes('upload failed') || errorContext.includes('Illegal char')) {
      this.errorMessage = 'I/O Exception: Remove punctuation or colons (:) inside the Supplier Name field!';
    } else {
      this.errorMessage = errorContext || 'An unexpected error occurred during profile synchronization.';
    }
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null;

    if (!this.isEdit && this.supplier.password !== this.confirmPassword) {
      this.errorMessage = 'Validation Fault: Access passwords do not match.';
      return;
    }

    if (this.supplier.policeStationId === 0) {
      this.errorMessage = 'Validation Fault: Local base station terminal configuration hierarchy incomplete.';
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      const updatePayload = { ...this.supplier };
      if (!updatePayload.password || updatePayload.password.trim() === '') {
        delete updatePayload.password; 
      }

      this.service.update(this.currentEditId, updatePayload, this.selectedFile).subscribe({
        next: () => {
          alert("Supplier profile updated successfully!");
          this.closeDrawer();
          this.loadSuppliers();
              this.cdr.markForCheck();

        },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.supplier, this.selectedFile).subscribe({
        next: () => {
          alert("Supplier station node successfully initialized!");
          this.closeDrawer();
          this.loadSuppliers();
           this.cdr.markForCheck();

        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }
  edit(s: SupplierResponseDTO) {
    this.errorMessage = null;
    this.currentEditId = s.id;
    this.isEdit = true;

    this.supplier = {
      name: s.name,
      email: s.email,
      phone: s.phone,
      password: '',
      contactPerson: s.contactPerson,
      address: s.address,
      nidNumber: s.nidNumber,
      passportNumber: s.passportNumber,
      gender: s.gender,
      dob: s.dob,
      image: s.image,
      rating: s.rating,
      averageLeadTimeDays: s.averageLeadTimeDays,
      policeStationId: s.policeStationId
    };

    const addressParts = s.address ? s.address.split(', ') : [];
    this.streetAddress = addressParts[0] || '';
    this.imagePreview = s.image ? this.getImageUrl(s.image) : null;

    this.selectedCountryId = (s as any).countryId ? +(s as any).countryId : null;
    this.selectedDivisionId = (s as any).divisionId ? +(s as any).divisionId : null;
    this.selectedDistrictId = (s as any).districtId ? +(s as any).districtId : null;
    this.supplier.policeStationId = s.policeStationId ? +s.policeStationId : 0;

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
    if (confirm("Wipe this Supplier registry signature definitively from cluster systems?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Supplier workstation profile purged successfully.");
          this.loadSuppliers();
          this.cdr.markForCheck();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  reset() {
    this.supplier = {
      name: '',
      email: '',
      phone: '',
      password: '',
      contactPerson: '',
      address: '',
      nidNumber: '',
      passportNumber: '',
      gender: '',
      dob: '',
      image: '',
      rating: 5.0,
      averageLeadTimeDays: 1,
      policeStationId: 0
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
