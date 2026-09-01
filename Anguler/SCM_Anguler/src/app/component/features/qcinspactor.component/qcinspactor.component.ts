import { CommonModule } from "@angular/common";
import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import { FormsModule } from "@angular/forms";
import { QCInspectorRequestModel, QCInspectorResponseModel } from "../../shared/model/qcInspactorModel";
import { environment } from "../../../../environment/environment";
import { QcInspectorService } from "../../../service/qc-inspactor.service";
import { CountryService } from "../../../service/country.service";
import { DivisionService } from "../../../service/division.service";
import { DistrictService } from "../../../service/district.service";
import { PoliceStationService } from "../../../service/police-station.service";

@Component({
  selector: 'app-qc-inspector',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './qcinspactor.component.html',
  styleUrl: './qcinspactor.component.css',
})
export class QcinspactorComponent implements OnInit {

  inspectors: QCInspectorResponseModel[] = [];
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

  readonly imageBaseUrl = environment.imgUrl+"qc_inspector/";

  inspector: QCInspectorRequestModel = {
    name: '',
    email: '',
    phone: '',
    password: '',
    userActive: false,
    contactPerson: '',
    address: '',
    nidNumber: '',
    passportNumber: '',
    dob: '',
    gender: '',
    image: '',
    joiningDate: '',
    designation: '',
    language: '',
    policeStationId: 0
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: QcInspectorService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadInspectors();
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

  loadInspectors() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.inspectors = data || [];
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
    this.inspector.policeStationId = 0;

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
    this.inspector.policeStationId = 0;

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
    this.inspector.policeStationId = 0;

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
    const psName = this.policeStations.find(x => x.id == this.inspector.policeStationId)?.name || '';

    this.inspector.address = [
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
        this.errorMessage = 'QC Deployment Broken: This corporate email is already allocated to another inspector node.';
      } else if (errorContext.includes('phone_number')) {
        this.errorMessage = 'QC Deployment Broken: Phone index vector already active.';
      } else {
        this.errorMessage = 'QC Deployment Broken: Duplicate Identity entry tracked (NID or Passport constraint violation).';
      }
    } else if (errorContext.includes('Image upload failed') || errorContext.includes('file system')) {
      this.errorMessage = 'Filesystem I/O Fault: Clean out colons (:) or special symbols from Name fields.';
    } else {
      this.errorMessage = errorContext || 'An unmapped transactional error occurred.';
    }
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null;

    if (!this.isEdit && this.inspector.password !== this.confirmPassword) {
      this.errorMessage = 'Validation Error: Passwords do not match.';
      return;
    }

    if (this.inspector.policeStationId === 0) {
      this.errorMessage = 'Validation Error: Regional station terminal configuration sequence left incomplete.';
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.inspector, this.selectedFile).subscribe({
        next: () => {
          alert("QC Inspector matrix updated successfully!");
          this.closeDrawer();
          this.loadInspectors();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.inspector, this.selectedFile).subscribe({
        next: () => {
          alert("QC Inspector instance successfully deployed!");
          this.closeDrawer();
          this.loadInspectors();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  edit(o: QCInspectorResponseModel) {
    this.errorMessage = null;
    this.currentEditId = o.id;
    this.isEdit = true;

    this.inspector = {
      name: o.name,
      email: o.email,
      phone: o.phone,
      password: '',
      userActive: o.userActive,
      contactPerson: o.contactPerson,
      address: o.address,
      nidNumber: o.nidNumber,
      passportNumber: o.passportNumber,
      dob: o.dob,
      gender: o.gender,
      image: o.image,
      joiningDate: o.joiningDate,
      designation: o.designation,
      language: o.language,
      policeStationId: o.policeStationId
    };

    const addressParts = o.address ? o.address.split(', ') : [];
    this.streetAddress = addressParts[0] || '';
    this.imagePreview = o.image ? this.getImageUrl(o.image) : null;

    this.selectedCountryId = (o as any).countryId ? +(o as any).countryId : null;
    this.selectedDivisionId = (o as any).divisionId ? +(o as any).divisionId : null;
    this.selectedDistrictId = (o as any).districtId ? +(o as any).districtId : null;
    this.inspector.policeStationId = o.policeStationId ? +o.policeStationId : 0;

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
    if (confirm("Definitively wipe this QC Inspector station signature node?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("QC Matrix node safely cleared.");
          this.loadInspectors();
        },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  reset() {
    this.inspector = {
      name: '',
      email: '',
      phone: '',
      password: '',
      userActive: false,
      contactPerson: '',
      address: '',
      nidNumber: '',
      passportNumber: '',
      dob: '',
      gender: '',
      image: '',
      joiningDate: '',
      designation: '',
      language: '',
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
