import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { LCBankRequestModel, LCBankResponseModel } from '../../shared/model/lcbankModel';
import { LcbankService } from '../../../service/lcbank.service';

@Component({
  selector: 'app-lcbank',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './lcbank.component.html',
  styleUrl: './lcbank.component.css',
})
export class LcbankComponent implements OnInit {

  banks: LCBankResponseModel[] = [];
  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentEditId: number | null = null;

  bank: LCBankRequestModel = {
    name: '',
    swiftCode: '',
    branchName: '',
    address: '',
    contactEmail: '',
    contactPhone: ''
  };

  constructor(
    private service: LcbankService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadBanks();
  }

  loadBanks() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.banks = data || [];
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        if (err.status !== 204) {
          this.errorMessage = "Failed to load LC Bank data clusters.";
        }
        this.banks = [];
        this.cdr.markForCheck();
      }
    });
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

  save() {
    this.errorMessage = null;

    if (!this.bank.name || !this.bank.swiftCode || !this.bank.branchName) {
      this.errorMessage = "Validation Fault: Bank Name, SWIFT Code, and Branch Specification are mandatory.";
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.bank).subscribe({
        next: () => {
          alert("LC Bank mapping profile updated successfully.");
          this.closeDrawer();
          this.loadBanks();
        },
        error: (err: any) => this.errorMessage = err.error?.message || "Operational layout modification failure."
      });
    } else {
      this.service.save(this.bank).subscribe({
        next: () => {
          alert("New SWIFT Banking terminal registered successfully.");
          this.closeDrawer();
          this.loadBanks();
        },
        error: (err: any) => this.errorMessage = err.error?.message || "Banking structure integration exception."
      });
    }
  }

  edit(b: LCBankResponseModel) {
    this.errorMessage = null;
    this.currentEditId = b.id;
    this.isEdit = true;
    this.bank = {
      name: b.name,
      swiftCode: b.swiftCode,
      branchName: b.branchName,
      address: b.address,
      contactEmail: b.contactEmail,
      contactPhone: b.contactPhone
    };
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Definitively wipe this LC Bank profile from enterprise matrix? Warning: Active LCs may lose references.")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("LC Bank profile pruned from cluster.");
          this.loadBanks();
        },
        error: (err: any) => alert(err.error?.message || err.message)
      });
    }
  }

  reset() {
    this.bank = {
      name: '',
      swiftCode: '',
      branchName: '',
      address: '',
      contactEmail: '',
      contactPhone: ''
    };
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }
}
