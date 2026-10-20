import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PoliceStationService } from '../../../../service/police-station.service';
import { DistrictService } from '../../../../service/district.service';
import { PoliceStationRequestModel, PoliceStationResponseModel } from '../../../shared/model/policeStationModel';
import { DistrictResponseModel } from '../../../shared/model/districtModel';

@Component({
  selector: 'app-police-station.component',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './police-station.component.html',
  styleUrl: './police-station.component.css',
})
export class PoliceStationComponent implements OnInit {
  stations: PoliceStationResponseModel[] = [];
  districts: DistrictResponseModel[] = []; 

  station: PoliceStationRequestModel = {
    name: '',
    nameBn: '',
    postalCode: '',
    active: true,
    districtId: 0
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false; 

  constructor(
    private service: PoliceStationService,
    private districtService: DistrictService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadStations();
    this.loadDistricts();
  }

  openDrawer() {
    this.isDrawerOpen = true;
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.reset();
  }

  loadStations() {
    this.service.getAll().subscribe({
      next: (data) => {
        this.stations = data;
        this.cdr.markForCheck();
      },
      error: (err: any) => console.error('Error loading stations:', err)
    });
  }

  loadDistricts() {
    this.districtService.getAll().subscribe({
      next: (data) => {
        this.districts = data;
        this.cdr.markForCheck();
      }
    });
  }

  save() {
    if (!this.station.districtId || this.station.districtId === 0) {
      alert("Please select a valid district.");
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.station).subscribe({
        next: () => {
          alert("Updated Successfully");
          this.closeDrawer();
          this.loadStations();
        },
        error: (err: any) => console.error('Error updating station:', err)
      });
    } else {
      this.service.save(this.station).subscribe({
        next: () => {
          alert("Saved Successfully");
          this.closeDrawer();
          this.loadStations();
        },
        error: (err: any) => console.error('Error saving station:', err)
      });
    }
  }

  edit(s: PoliceStationResponseModel) {
    this.currentEditId = s.id;
    this.station = {
      name: s.name,
      nameBn: s.nameBn,
      postalCode: s.postalCode,
      active: s.active,
      districtId: s.districtId
    };
    this.isEdit = true;
    this.openDrawer();
  }

  delete(id: number) {
    if (confirm("Delete this police station?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Deleted successfully");
          this.loadStations();
        },
        error: (err: any) => console.error('Error deleting station:', err)
      });
    }
  }

  reset() {
    this.station = {
      name: '',
      nameBn: '',
      postalCode: '',
      active: true,
      districtId: 0
    };
    this.isEdit = false;
    this.currentEditId = null;
  }
}
