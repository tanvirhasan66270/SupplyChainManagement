import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { WarehouseService } from '../../../../service/warehouse.service';
import { CountryService } from '../../../../service/country.service';
import { DivisionService } from '../../../../service/division.service';
import { DistrictService } from '../../../../service/district.service';
import { PoliceStationService } from '../../../../service/police-station.service';
import { WarehouseRequestModel, WarehouseResponseModel } from '../../../shared/model/warehouse';
import { environment } from '../../../../../environment/environment';
import { StorageService } from '../../../../auth/auth_service/storage.service';

@Component({
  selector: 'app-warehouse',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './warehouse.component.html',
  styleUrl: './warehouse.component.css',
})
export class WarehouseComponent implements OnInit {
  warehouses: WarehouseResponseModel[] = [];
  filteredWarehouses: WarehouseResponseModel[] = []; 

  // আলাদা ৩টি সার্চ অপশনের জন্য ভেরিয়েবল
  searchId: string = '';
  searchEmail: string = '';
  searchStatus: string = '';

  countries: any[] = [];
  divisions: any[] = [];
  districts: any[] = [];
  policeStations: any[] = [];

  selectedCountryId: number | null = null;
  selectedDivisionId: number | null = null;
  selectedDistrictId: number | null = null;

  warehouse: WarehouseRequestModel = {
    name: '',
    email: '',
    location: '',
    address: '',
    capacity: 0,
    managerId: 0,
    isActive: true,
    policeStationId: 0,
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;
  currentUserId: number = 0;
  activeRole: string = '';

  constructor(
    private service: WarehouseService,
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef,
  ) {}

  ngOnInit() {
    this.activeRole = this.storage.getActiveRole()?.toUpperCase() || '';
    const user = this.storage.getUser();
    if (user) {
      this.currentUserId = user.userId;
      this.warehouse.managerId = user.userId;
      if (!this.activeRole && user.role) {
        this.activeRole = user.role.toUpperCase();
      }
    }
    this.loadWarehouses();
    this.loadCountries();
  }

  // সিকিউরিটি চেক: LOGISTICS_OFFICER মডিফাই করতে পারবে না
  canModifyWarehouse(): boolean {
    return this.activeRole !== 'LOGISTICS_OFFICER';
  }

  openDrawer() {
    if (!this.canModifyWarehouse()) {
      alert("Access Denied: Logistics Officers cannot deploy new warehouses.");
      return;
    }
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

  loadWarehouses() {
    this.service.getAll().subscribe({
      next: (data) => {
        this.warehouses = data || [];
        this.filteredWarehouses = [...this.warehouses]; 
        this.cdr.markForCheck();
      },
    });
  }

  // মাল্টিপল সার্চ ফিল্টার লজিক
  applySearch() {
    const idTerm = this.searchId.toLowerCase().trim();
    const emailTerm = this.searchEmail.toLowerCase().trim();
    const statusTerm = this.searchStatus.toLowerCase().trim();

    this.filteredWarehouses = this.warehouses.filter(w => {
      const matchId = idTerm === '' || w.id.toString().includes(idTerm);
      const matchEmail = emailTerm === '' || w.email.toLowerCase().includes(emailTerm);
      const matchStatus = statusTerm === '' || (w.isActive ? 'active' : 'locked').includes(statusTerm);

      return matchId && matchEmail && matchStatus;
    });
    this.cdr.markForCheck();
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
    this.warehouse.policeStationId = 0;

    if (!this.selectedCountryId) return;

    this.divisionService.getByCountryId(this.selectedCountryId).subscribe((res) => {
      this.divisions = res || [];
      this.cdr.markForCheck();
    });
  }

  onDivisionChange() {
    this.districts = [];
    this.policeStations = [];
    this.selectedDistrictId = null;
    this.warehouse.policeStationId = 0;

    const divisionId = Number(this.selectedDivisionId);
    if (!divisionId) return;

    this.districtService.getByDivisionId(divisionId).subscribe({
      next: (res) => {
        this.districts = res || [];
        this.cdr.markForCheck();
      },
    });
  }

  onDistrictChange() {
    this.policeStations = [];
    this.warehouse.policeStationId = 0;

    const districtId = Number(this.selectedDistrictId);
    if (!districtId) return;

    this.stationService.getByDistrictId(districtId).subscribe({
      next: (res) => {
        this.policeStations = res || [];
        this.cdr.markForCheck();
      },
    });
  }

  generateFullAddress() {
    const countryName = this.countries.find((x) => x.id == this.selectedCountryId)?.name || '';
    const divisionName = this.divisions.find((x) => x.id == this.selectedDivisionId)?.name || '';
    const districtName = this.districts.find((x) => x.id == this.selectedDistrictId)?.name || '';
    const psName = this.policeStations.find((x) => x.id == this.warehouse.policeStationId)?.name || '';

    this.warehouse.address = [
      this.warehouse.location,
      psName,
      districtName,
      divisionName,
      countryName,
    ]
      .filter((v) => v)
      .join(', ');
  }

  save() {
    if (!this.canModifyWarehouse()) {
      alert("Access Denied: Logistics Officers cannot save changes.");
      return;
    }

    if (!this.warehouse.policeStationId || this.warehouse.policeStationId === 0) {
      alert('Please complete the location hierarchy up to Police Station.');
      return;
    }

    this.generateFullAddress();

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.warehouse).subscribe({
        next: () => {
          alert('Warehouse updated successfully!');
          this.closeDrawer();
          this.loadWarehouses();
        },
      });
    } else {
      this.service.save(this.warehouse).subscribe({
        next: () => {
          alert('Warehouse deployed successfully!');
          this.closeDrawer();
          this.loadWarehouses();
        },
      });
    }
  }

  edit(w: WarehouseResponseModel) {
    if (!this.canModifyWarehouse()) {
      alert("Access Denied: Logistics Officers cannot edit warehouse data.");
      return;
    }

    this.currentEditId = w.id;
    this.isEdit = true;

    this.warehouse = {
      name: w.name,
      email: w.email,
      location: w.location,
      address: w.address,
      capacity: w.capacity,
      managerId: w.managerId,
      isActive: w.isActive,
      policeStationId: w.policeStationId,
    };

    if (w.policeStationId) {
      console.log('Fetching station for ID:', w.policeStationId);
      this.stationService.getById(w.policeStationId).subscribe({
        next: (station) => {
          console.log('Station loaded:', station);
          if (station && station.districtId) {
            this.districtService.getById(station.districtId).subscribe({
              next: (district) => {
                console.log('District loaded:', district);
                if (district && district.divisionId) {
                  this.divisionService.getById(district.divisionId).subscribe({
                    next: (division) => {
                      console.log('Division loaded:', division);
                      if (division && division.countryId) {
                        this.selectedCountryId = Number(division.countryId);
                        console.log('Selected Country ID set to:', this.selectedCountryId);
                        
                        this.divisionService.getByCountryId(division.countryId).subscribe((divs) => {
                          this.divisions = divs || [];
                          this.selectedDivisionId = Number(district.divisionId);
                          console.log('Divisions loaded, selectedDivisionId:', this.selectedDivisionId);
                          this.cdr.markForCheck();
                        });
                        
                        this.districtService.getByDivisionId(district.divisionId).subscribe((dists) => {
                          this.districts = dists || [];
                          this.selectedDistrictId = Number(station.districtId);
                          console.log('Districts loaded, selectedDistrictId:', this.selectedDistrictId);
                          this.cdr.markForCheck();
                        });
                        
                        this.stationService.getByDistrictId(station.districtId).subscribe((stations) => {
                          this.policeStations = stations || [];
                          this.warehouse.policeStationId = Number(station.id);
                          console.log('Stations loaded, policeStationId:', this.warehouse.policeStationId);
                          this.cdr.markForCheck();
                        });
                      }
                    },
                    error: (err) => console.error('Division fetch error:', err)
                  });
                }
              },
              error: (err) => console.error('District fetch error:', err)
            });
          }
        },
        error: (err) => console.error('Station fetch error:', err)
      });
    } else {
      console.log('No policeStationId on warehouse:', w);
    }

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (!this.canModifyWarehouse()) {
      alert("Access Denied: Logistics Officers cannot delete warehouses.");
      return;
    }

    if (confirm('Purge this warehouse node?')) {
      this.service.delete(id).subscribe({
        next: () => {
          alert('Warehouse deleted successfully');
          this.loadWarehouses();
        },
      });
    }
  }

  reset() {
    this.warehouse = {
      name: '',
      email: '',
      location: '',
      address: '',
      capacity: 0,
      managerId: this.currentUserId,
      isActive: true,
      policeStationId: 0,
    };
    this.selectedCountryId = null;
    this.selectedDivisionId = null;
    this.selectedDistrictId = null;
    this.divisions = [];
    this.districts = [];
    this.policeStations = [];
    this.isEdit = false;
    this.currentEditId = null;
  }
}