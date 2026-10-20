import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { VehicleRequestModel, VehicleResponseModel } from '../../shared/model/vehicleModel';
import { VehicleService } from '../../../service/vehicle.service';
import { DriverService } from '../../../service/driver.service';
import { StorageService } from '../../../auth/auth_service/storage.service';

@Component({
  selector: 'app-vehicle',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './vehicle.component.html',
  styleUrl: './vehicle.component.css'
})
export class VehicleComponent implements OnInit {

  vehicles: VehicleResponseModel[] = [];
  drivers: any[] = []; 
  
  errorMessage: string | null = null;
  isDrawerOpen = false;
  isEdit = false;
  currentVehicleId: number | null = null;

  isStatusModalOpen = false;
  statusUpdateValue = 'AVAILABLE';

  userRole: string = '';
  currentUserId: number = 0;

  formModel: VehicleRequestModel = {
    plateNumber: '',
    type: 'VAN',
    capacity: 0,
    status: 'AVAILABLE', 
    lastServiceDate: '',
    fuelLevel: 100,
    driverId: null
  };

  constructor(
    private service: VehicleService,
    private driverService: DriverService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef
  ) { }

  actualDriverId: number | null = null;

  ngOnInit() {
    const user = this.storage.getUser();
    if (user) {
      this.currentUserId = user.userId ;
      this.userRole = user.role;
    }
    
    if (this.userRole === 'DRIVER') {
      this.driverService.getDriverByUserId(this.currentUserId).subscribe({
        next: (driver) => {
          this.actualDriverId = driver.id;
          this.loadVehicles();
        },
        error: (err) => {
          console.error('Failed to load driver profile', err);
          this.loadVehicles();
        }
      });
    } else {
      this.loadVehicles();
    }
    this.loadDrivers();
  }

  loadVehicles() {
    this.service.findAll().subscribe({
      next: (data) => { 
        const allVehicles = data || [];
        
        if (this.userRole === 'DRIVER') {
          this.vehicles = allVehicles.filter((v: any) => 
            v.driverId === this.actualDriverId || v.driver?.id === this.actualDriverId
          );
        } else {
          this.vehicles = allVehicles;
        }

        this.cdr.markForCheck(); 
      },
      error: (err: any) => this.handleError(err)
    });
  }

  loadDrivers() {
    this.driverService.findAll().subscribe({ next: (data) => this.drivers = data || [] });
  }

  submitVehicle() {
    this.errorMessage = null;

    if (!this.formModel.plateNumber || this.formModel.plateNumber.trim() === '') {
      this.errorMessage = "Validation Error: Vehicle Plate Number is mandatory.";
      this.cdr.markForCheck();
      return;
    }

    const payload: VehicleRequestModel = {
      plateNumber: this.formModel.plateNumber.trim(),
      type: this.formModel.type,
      capacity: +this.formModel.capacity,
      status: this.formModel.status,
      lastServiceDate: this.formModel.lastServiceDate || null,
      fuelLevel: +this.formModel.fuelLevel,
      driverId: this.formModel.driverId ? +this.formModel.driverId : null
    };

    if (this.isEdit && this.currentVehicleId) {
      this.service.update(this.currentVehicleId, payload).subscribe({
        next: () => { alert("Fleet vehicle parameters updated successfully."); this.closeDrawer(); this.loadVehicles(); },
        error: (err: any) => this.handleError(err)
      });
    } else {
      this.service.create(payload).subscribe({
        next: () => { alert("New vehicle asset logged into logistics database."); this.closeDrawer(); this.loadVehicles(); },
        error: (err: any) => this.handleError(err)
      });
    }
  }

  openStatusModal(vehicle: VehicleResponseModel) {
    this.currentVehicleId = vehicle.id;
    this.statusUpdateValue = vehicle.status;
    this.isStatusModalOpen = true;
    this.cdr.markForCheck();
  }

  closeStatusModal() {
    this.isStatusModalOpen = false;
    this.currentVehicleId = null;
  }

  executeStatusUpdate() {
    if (!this.currentVehicleId) return;

    const targetVehicle = this.vehicles.find(v => v.id === this.currentVehicleId);
    if (!targetVehicle) return;

    const patchPayload: VehicleRequestModel = {
      plateNumber: targetVehicle.plateNumber,
      type: targetVehicle.type,
      capacity: targetVehicle.capacity,
      status: this.statusUpdateValue.toUpperCase(), 
      lastServiceDate: targetVehicle.lastServiceDate,
      fuelLevel: targetVehicle.fuelLevel,
      driverId: targetVehicle.driverId
    };

    this.service.update(this.currentVehicleId, patchPayload).subscribe({
      next: () => {
        alert("Vehicle workshop maintenance status patched successfully.");
        this.closeStatusModal();
        this.loadVehicles();
      },
      error: (err: any) => this.handleError(err)
    });
  }

  edit(vehicle: VehicleResponseModel) {
    this.isEdit = true;
    this.currentVehicleId = vehicle.id;
    this.formModel = {
      plateNumber: vehicle.plateNumber,
      type: vehicle.type,
      capacity: vehicle.capacity,
      status: vehicle.status, 
      lastServiceDate: vehicle.lastServiceDate,
      fuelLevel: vehicle.fuelLevel,
      driverId: vehicle.driverId
    };
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  deleteVehicle(id: number) {
    if (confirm("Are you sure you want to decommission this vehicle asset?")) {
      this.service.delete(id).subscribe({
        next: (msg) => { alert(msg); this.loadVehicles(); },
        error: (err: any) => alert(err.error?.message || err.message)
      });
    }
  }

  openDrawer() { this.resetForm(); this.isDrawerOpen = true; }
  closeDrawer() { this.isDrawerOpen = false; this.resetForm(); }

  resetForm() {
    this.formModel = { plateNumber: '', type: 'VAN', capacity: 0, status: 'AVAILABLE', lastServiceDate: '', fuelLevel: 100, driverId: null };
    this.isEdit = false;
    this.currentVehicleId = null;
    this.errorMessage = null;
  }

  private handleError(err: any) {
    this.errorMessage = err.error?.message || err.message || "Runtime Fleet Communication Interruption.";
    this.cdr.markForCheck();
  }
}