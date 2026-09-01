import { ChangeDetectorRef, Component } from '@angular/core';
import { CountryService } from '../../../../service/country.service';
import { DivisionService } from '../../../../service/division.service';
import { DistrictService } from '../../../../service/district.service';
import { PoliceStationService } from '../../../../service/police-station.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-location.component',
  standalone: true,
  imports: [CommonModule,FormsModule],
  templateUrl: './location.component.html',
  styleUrl: './location.component.css',
})
export class LocationComponent {

countries: any[] = [];
  divisions: any[] = [];
  districts: any[] = [];
  stations: any[] = [];

  selectedCountryId: number | null = null;
  selectedDivisionId: number | null = null;
  selectedDistrictId: number | null = null;

  keyword: string = '';

  constructor(
    private countryService: CountryService,
    private divisionService: DivisionService,
    private districtService: DistrictService,
    private stationService: PoliceStationService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadCountries();
  }

  loadCountries() {
    this.countryService.getAll().subscribe({
      next: (data) => {
        this.countries = data;
        this.cdr.markForCheck();
      },
      error: (err: any) => console.error('Error loading countries:', err)
    });
  }

  onCountryChange() {
    this.divisions = [];
    this.districts = [];
    this.stations = [];
    this.selectedDivisionId = null;
    this.selectedDistrictId = null;

    if (!this.selectedCountryId) return;

    // আপনার DivisionService-এ getByCountryId মেথডটি থাকতে হবে
    this.divisionService.getByCountryId(this.selectedCountryId).subscribe({
      next: (res) => {
        this.divisions = res;
        this.cdr.markForCheck();
      }
    });
  }

  onDivisionChange() {
    this.districts = [];
    this.stations = [];
    this.selectedDistrictId = null;

    if (!this.selectedDivisionId) return;

    this.districtService.getByDivisionId(this.selectedDivisionId).subscribe({
      next: (res) => {
        this.districts = res;
        this.cdr.markForCheck();
      }
    });
  }

  onDistrictChange() {
    this.stations = [];

    if (!this.selectedDistrictId) return;

    this.stationService.getByDistrictId(this.selectedDistrictId).subscribe({
      next: (res) => {
        this.stations = res;
        this.cdr.markForCheck();
      }
    });
  }

  search() {
    if (this.keyword.trim().length === 0) {
      this.stations = [];
      return;
    }

    this.stationService.search(this.keyword).subscribe({
      next: (res) => {
        this.stations = res;
        this.cdr.markForCheck();
      }
    });
  }

}
