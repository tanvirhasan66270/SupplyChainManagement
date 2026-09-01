import { ChangeDetectorRef, Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  DeliveryTripRequestModel,
  DeliveryTripResponseModel,
} from '../../shared/model/DeliveryTripModel';
import { DeliveryTripService } from '../../../service/delivery-trip.service';
import { VehicleService } from '../../../service/vehicle.service';
import { CustomerService } from '../../../service/customer.service';
import { StorageService } from '../../../auth/auth_service/storage.service';

import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import { environment } from '../../../../environment/environment';

@Component({
  selector: 'app-delivery-trip',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './delivery-trip.component.html',
  styleUrl: './delivery-trip.component.css',
})
export class DeliveryTripComponent implements OnInit {
  trips: DeliveryTripResponseModel[] = [];
  customers: any[] = [];
  allVehicles: any[] = [];
  filteredVehicles: any[] = [];
  selectedVehicleType: string = '';
  errorMessage: string | null = null;
  isDrawerOpen = false;
  isStatusModalOpen = false;
  isEdit = false;
  currentTripId: number | null = null;
  selectedSignature: File | null = null;
  selectedPhoto: File | null = null;
  statusUpdateValue = 'PENDING';
  currentUserId: number = 0;

  userRole: string = '';

  // PDF Preview States
  isPdfModalOpen = false;
  selectedTripForPdf: DeliveryTripResponseModel | null = null;
  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;
  readonly imageBaseUrl = environment.imgUrl;

  // Missing Document Upload Modal States
  isUploadModalOpen = false;
  selectedTripForUpload: DeliveryTripResponseModel | null = null;

  formModel: DeliveryTripRequestModel = {
    dispatcherId: 0,
    customerId: 0,
    vehicleId: 0,
    driverId: 0,
    status: 'PENDING',
    customerAddress: '',
    remarks: '',
  };

  constructor(
    private service: DeliveryTripService,
    private vehicleService: VehicleService,
    private customerService: CustomerService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef,
  ) {}

  ngOnInit() {
    this.userRole = this.storage.getActiveRole()?.toUpperCase() || '';
    const user = this.storage.getUser();
    if (user) {
      this.currentUserId = user.userId;
      this.formModel.dispatcherId = user.userId;
      if (!this.userRole && user.role) {
        this.userRole = user.role.toUpperCase();
      }
    }
    this.loadTrips();
    this.loadActiveFleetData();
  }

  loadTrips() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.trips = data || [];
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleError(err),
    });
  }

  canViewConsoleActions(): boolean {
    const role = this.storage.getActiveRole()?.toUpperCase();
    return role === 'ADMIN' || role === 'LOGISTICS_OFFICER';
  }

  canViewStatusActions(): boolean {
    const role = this.storage.getActiveRole()?.toUpperCase().trim();
    return role === 'ADMIN' || role === 'DRIVER';
  }

  loadActiveFleetData() {
    this.vehicleService.findAll().subscribe({
      next: (data) => {
        this.allVehicles = data || [];
        this.cdr.markForCheck();
      },
      error: () => {
        this.errorMessage = 'Failed to load vehicle data.';
        this.cdr.markForCheck();
      },
    });

    this.customerService.getAll().subscribe({
      next: (data) => {
        this.customers = data || [];
        this.cdr.markForCheck();
      },
      error: () => {
        this.customers = [];
      },
    });
  }

  onVehicleTypeChange() {
    this.formModel.vehicleId = 0;

    if (!this.selectedVehicleType) {
      this.filteredVehicles = [];
    } else {
      this.filteredVehicles = this.allVehicles.filter(
        (v) =>
          v.type.toUpperCase() === this.selectedVehicleType.toUpperCase() && v.driverId != null,
      );
    }
    this.cdr.markForCheck();
  }

  submitTrip() {
    this.errorMessage = null;

    if (
      !this.formModel.customerId ||
      +this.formModel.customerId === 0 ||
      !this.formModel.vehicleId ||
      +this.formModel.vehicleId === 0
    ) {
      this.errorMessage =
        'Validation Fault: Customer mapping and Fleet allocation with assigned captain are required.';
      this.cdr.markForCheck();
      return;
    }

    const vehicle = this.allVehicles.find(v => +v.id === +this.formModel.vehicleId);
    const driverId = vehicle ? vehicle.driverId : null;

    const payload: DeliveryTripRequestModel = {
      dispatcherId: +this.formModel.dispatcherId || this.currentUserId,
      customerId: +this.formModel.customerId,
      vehicleId: +this.formModel.vehicleId,
      driverId: driverId || 0,
      status: this.formModel.status.toUpperCase(),
      customerAddress: this.formModel.customerAddress.trim(),
      remarks: this.formModel.remarks?.trim() || null,
    };

    if (this.isEdit && this.currentTripId) {
      this.service.update(this.currentTripId, payload).subscribe({
        next: () => {
          alert('Trip manifest routing modified.');
          this.closeDrawer();
          this.loadTrips();
        },
        error: (err: any) => this.handleError(err),
      });
    } else {
      this.service.create(payload).subscribe({
        next: () => {
          alert('New delivery trip blueprint deployed successfully.');
          this.closeDrawer();
          this.loadTrips();
        },
        error: (err: any) => this.handleError(err),
      });
    }
  }

  openStatusModal(trip: DeliveryTripResponseModel) {
    this.currentTripId = trip.id;
    this.statusUpdateValue = trip.status;
    this.selectedSignature = null;
    this.selectedPhoto = null;
    this.isStatusModalOpen = true;
    this.cdr.markForCheck();
  }

  closeStatusModal() {
    this.isStatusModalOpen = false;
    this.currentTripId = null;
  }

  onFileChange(event: any, type: 'sig' | 'photo') {
    const file = event.target.files[0];
    if (file) {
      if (type === 'sig') this.selectedSignature = file;
      if (type === 'photo') this.selectedPhoto = file;
    }
  }

  executeStatusPatch() {
    if (!this.currentTripId) return;

    this.service
      .changeStatus(
        this.currentTripId,
        this.statusUpdateValue.toUpperCase(),
        this.selectedSignature,
        this.selectedPhoto,
      )
      .subscribe({
        next: () => {
          alert('Trip execution console state patched successfully.');
          this.closeStatusModal();
          this.loadTrips();
        },
        error: (err: any) => this.handleError(err),
      });
  }

  openUploadModal(trip: DeliveryTripResponseModel) {
    this.selectedTripForUpload = trip;
    this.currentTripId = trip.id;
    this.selectedSignature = null;
    this.selectedPhoto = null;
    this.isUploadModalOpen = true;
    this.cdr.markForCheck();
  }

  closeUploadModal() {
    this.isUploadModalOpen = false;
    this.selectedTripForUpload = null;
    this.currentTripId = null;
    this.cdr.markForCheck();
  }

  uploadMissingDocs() {
    if (!this.currentTripId) return;

    this.service
      .changeStatus(
        this.currentTripId,
        'DELIVERED',
        this.selectedSignature,
        this.selectedPhoto,
      )
      .subscribe({
        next: () => {
          alert('Delivery documents uploaded and synced successfully.');
          this.closeUploadModal();
          this.loadTrips();
        },
        error: (err: any) => this.handleError(err),
      });
  }

  viewDocument(filePath?: string | null) {
    if (!filePath) {
      alert('No document attached.');
      return;
    }
    const fullUrl = filePath.startsWith('http') ? filePath : this.imageBaseUrl + filePath;
    window.open(fullUrl, '_blank');
  }

  edit(trip: DeliveryTripResponseModel) {
    this.isEdit = true;
    this.currentTripId = trip.id;

    const matchedVehicle = this.allVehicles.find((v) => v.id === trip.vehicleId);
    if (matchedVehicle) {
      this.selectedVehicleType = matchedVehicle.type;
      this.onVehicleTypeChange();
    }

    this.formModel = {
      dispatcherId: trip.dispatcherId,
      customerId: trip.customerId,
      vehicleId: trip.vehicleId,
      driverId: trip.driverId || 0,
      status: trip.status,
      customerAddress: trip.customerAddress,
      remarks: trip.remarks,
    };
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  deleteTrip(id: number) {
    if (confirm('Are you sure you want to terminate this delivery manifest pointer from matrix?')) {
      this.service.delete(id).subscribe({
        next: (msg) => {
          alert(msg);
          this.loadTrips();
        },
        error: (err: any) => alert(err.error?.message || err.message),
      });
    }
  }

  openPdfModal(trip: DeliveryTripResponseModel) {
    this.selectedTripForPdf = trip;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedTripForPdf = null;
    this.cdr.markForCheck();
  }

  downloadPdfFromModal() {
    if (!this.selectedTripForPdf) return;

    const element = this.pdfPreviewContainer.nativeElement;
    
    html2canvas(element, { scale: 2, useCORS: true, windowHeight: element.scrollHeight, height: element.scrollHeight }).then((canvas) => {
      const imgData = canvas.toDataURL('image/png');
      const pdf = new jsPDF('p', 'mm', 'a4');
      const imgWidth = 210; 
      const pageHeight = 295; 
      const imgHeight = (canvas.height * imgWidth) / canvas.width;
      let heightLeft = imgHeight;
      let position = 0;

      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;

      while (heightLeft >= 0) {
        position = heightLeft - imgHeight;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
      }

      pdf.save(`Delivery-Trip-TRIP-${this.selectedTripForPdf?.id}.pdf`);
      this.closePdfModal();
    });
  }

  openDrawer() {
    this.resetForm();
    this.isDrawerOpen = true;
  }
  closeDrawer() {
    this.isDrawerOpen = false;
    this.resetForm();
  }

  resetForm() {
    this.formModel = {
      dispatcherId: this.currentUserId,
      customerId: 0,
      vehicleId: 0,
      driverId: 0,
      status: 'PENDING',
      customerAddress: '',
      remarks: '',
    };
    this.selectedVehicleType = '';
    this.filteredVehicles = [];
    this.isEdit = false;
    this.currentTripId = null;
    this.errorMessage = null;
  }

  private handleError(err: any) {
    this.errorMessage = err.error?.message || err.message || 'Runtime Communication Exception.';
    this.cdr.markForCheck();
  }
}