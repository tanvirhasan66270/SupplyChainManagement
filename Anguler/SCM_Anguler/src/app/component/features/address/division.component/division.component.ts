import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { DivisionRequestModel, DivisionResponseModel } from '../../../shared/model/divisionModel';
import { DivisionService } from '../../../../service/division.service';
import { CountryService } from '../../../../service/country.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CountryResponseModel } from '../../../shared/model/country/countryModel';


@Component({
  selector: 'app-division.component',
    standalone: true,
 imports: [CommonModule, FormsModule],
  templateUrl: './division.component.html',
  styleUrl: './division.component.css',
})
export class Division implements OnInit {
  divisions: DivisionResponseModel[] = [];
  countries: CountryResponseModel[] = []; 

  division: DivisionRequestModel = {
    name: '',
    nameBn: '',
    active: true,
    countryId: 0
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false; 

  constructor(
    private service: DivisionService,
    private countryService: CountryService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadDivisions();
    this.loadCountries();
  }

  openDrawer() {
    this.isDrawerOpen = true;
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.reset();
  }

  loadDivisions() {
    this.service.getAll().subscribe({
      next: (data) => {
        this.divisions = data;
        this.cdr.markForCheck();
      },
      error: (err: any) => console.error('Error loading divisions:', err)
    });
  }

  loadCountries() {
    this.countryService.getAll().subscribe({
      next: (data) => {
        this.countries = data;
        this.cdr.markForCheck();
      }
    });
  }

  save() {
    if (!this.division.countryId || this.division.countryId === 0) {
      alert("Please select a valid country.");
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.division).subscribe({
        next: () => {
          alert("Updated Successfully");
          this.closeDrawer();
          this.loadDivisions();
        },
        error: (err: any) => console.error('Error updating division:', err)
      });
    } else {
      this.service.save(this.division).subscribe({
        next: () => {
          alert("Saved Successfully");
          this.closeDrawer();
          this.loadDivisions();
        },
        error: (err: any) => console.error('Error saving division:', err)
      });
    }
  }

  edit(d: DivisionResponseModel) {
    this.currentEditId = d.id;
    this.division = {
      name: d.name,
      nameBn: d.nameBn,
      active: d.active,
      countryId: d.countryId
    };
    this.isEdit = true;
    this.openDrawer();
  }

  delete(id: number) {
    if (confirm("Delete this division?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Deleted successfully");
          this.loadDivisions();
        },
        error: (err: any) => console.error('Error deleting division:', err)
      });
    }
  }

  reset() {
    this.division = {
      name: '',
      nameBn: '',
      active: true,
      countryId: 0
    };
    this.isEdit = false;
    this.currentEditId = null;
  }
}
