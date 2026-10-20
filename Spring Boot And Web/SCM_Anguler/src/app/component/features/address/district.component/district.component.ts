import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DistrictService } from '../../../../service/district.service';
import { DivisionService } from '../../../../service/division.service';
import { DistrictRequestModel, DistrictResponseModel } from '../../../shared/model/districtModel';
import { DivisionResponseModel } from '../../../shared/model/divisionModel';

@Component({
  selector: 'app-district.component',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './district.component.html',
  styleUrl: './district.component.css',
})
export class DistrictComponent implements OnInit {
  districts: DistrictResponseModel[] = [];
  divisions: DivisionResponseModel[] = []; 

  district: DistrictRequestModel = {
    name: '',
    nameBn: '',
    districtCode: '',
    active: true,
    divisionId: 0
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false; 

  constructor(
    private service: DistrictService,
    private divisionService: DivisionService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadDistricts();
    this.loadDivisions();
  }

  openDrawer() {
    this.isDrawerOpen = true;
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.reset();
  }

  loadDistricts() {
    this.service.getAll().subscribe({
      next: (data) => {
        this.districts = data;
        this.cdr.markForCheck();
      },
      error: (err: any) => console.error('Error loading districts:', err)
    });
  }

  loadDivisions() {
    this.divisionService.getAll().subscribe({
      next: (data) => {
        this.divisions = data;
        this.cdr.markForCheck();
      }
    });
  }

  save() {
    if (!this.district.divisionId || this.district.divisionId === 0) {
      alert("Please select a valid division.");
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.district).subscribe({
        next: () => {
          alert("Updated Successfully");
          this.closeDrawer();
          this.loadDistricts();
        },
        error: (err: any) => console.error('Error updating district:', err)
      });
    } else {
      this.service.save(this.district).subscribe({
        next: () => {
          alert("Saved Successfully");
          this.closeDrawer();
          this.loadDistricts();
        },
        error: (err: any) => console.error('Error saving district:', err)
      });
    }
  }

  edit(d: DistrictResponseModel) {
    this.currentEditId = d.id;
    this.district = {
      name: d.name,
      nameBn: d.nameBn,
      districtCode: d.districtCode,
      active: d.active,
      divisionId: d.divisionId
    };
    this.isEdit = true;
    this.openDrawer();
  }

  delete(id: number) {
    if (confirm("Delete this district?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Deleted successfully");
          this.loadDistricts();
        },
        error: (err: any) => console.error('Error deleting district:', err)
      });
    }
  }

  reset() {
    this.district = {
      name: '',
      nameBn: '',
      districtCode: '',
      active: true,
      divisionId: 0
    };
    this.isEdit = false;
    this.currentEditId = null;
  }
}
