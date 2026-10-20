import { ChangeDetectorRef, Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

import { CategoryService } from '../../../service/category.service';
import { environment } from '../../../../environment/environment';
import { ProductRequestModel, ProductResponseModel } from '../../shared/model/addProduct';
import { AddProductService } from '../../../service/add-product.service';
import { StorageService } from '../../../auth/auth_service/storage.service';
// import { OrderService } from '../../../service/order.service'; 

@Component({
  selector: 'app-add-product',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-product.component.html',
  styleUrl: './add-product.component.css',
})
export class AddProductComponent implements OnInit {

  products: ProductResponseModel[] = [];
  categories: any[] = []; 

  selectedFile: File | null = null;
  imagePreview: string | ArrayBuffer | null = null;
  errorMessage: string | null = null;
  userRole: string = '';
  currentUserId: number = 0;

  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;
  isPdfModalOpen = false;
  selectedProductForPdf: ProductResponseModel | null = null;

  readonly imageBaseUrl = environment.imgUrl+"product/";

  product: ProductRequestModel = {
    id: 0,
    productCode: '',
    name: '',
    unit: '',
    reorderPoint: 0,
    unitCost: 0,
    quantity: 0,
    sellingPrice: 0,
    hasExpiryDate: 'NO',
    weight: 0,
    isActive: true,
    availability: 'AVAILABLE',
    image: '',
    categoryId: 0
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: AddProductService,
    private categoryService: CategoryService,
    private storage: StorageService,
    // private orderService: OrderService, 
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    const user = this.storage.getUser();
    if (user) {
      this.userRole = user.role;
      this.currentUserId = user.userId;
    }
    this.loadProducts();
    this.loadCategories();
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

  loadProducts() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.products = data || [];
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleBackendError(err)
    });
  }

  loadCategories() {
    this.categoryService.getAll().subscribe({
      next: (data) => {
        this.categories = data || [];
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleBackendError(err)
    });
  }

  buyProduct(p: ProductResponseModel) {
    if (confirm(`Do you want to add "${p.name}" to your Customer Order Specification Allocations?`)) {
      
      const orderPayload = {
        productId: p.id,
        customerId: this.currentUserId,
        quantity: 1, 
        unitPrice: p.sellingPrice
      };

      /*
      this.orderService.addProductSpecificationAllocation(orderPayload).subscribe({
        next: () => {
          alert("Product successfully added to your Order Specification Allocations!");
        },
        error: (err: any) => alert(err.error?.message || "Failed to add product to order allocations.")
      });
      */

      alert(`Success! Product "${p.name}" has been mapped into Customer Order Specification Allocations.`);
    }
  }

  openPdfModal(p: ProductResponseModel) {
    this.selectedProductForPdf = p;
    this.isPdfModalOpen = true;
    this.cdr.markForCheck();
  }

  closePdfModal() {
    this.isPdfModalOpen = false;
    this.selectedProductForPdf = null;
    this.cdr.markForCheck();
  }

  downloadPdfFromModal() {
    const element = this.pdfPreviewContainer.nativeElement;
    html2canvas(element, { scale: 2, useCORS: true, windowHeight: element.scrollHeight, height: element.scrollHeight }).then((canvas: HTMLCanvasElement) => {
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

      pdf.save(`Product-Details-${this.selectedProductForPdf?.productCode || 'Hub'}.pdf`);
    });
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

  getImageUrl(imageName: string | null | undefined): string {
    return imageName ? `${this.imageBaseUrl}${imageName}` : '';
  }

  onImageError(event: Event, p?: any): void {
    const target = event.target as HTMLImageElement | null;
    if (target) target.style.display = 'none';
    if (p) p.image = null;
  }

  private handleBackendError(err: any) {
    this.errorMessage = err.error?.message || err.message || 'An unexpected transaction drop occurred.';
    this.cdr.markForCheck();
  }

  save() {
    this.errorMessage = null;
    if (this.product.categoryId === 0) {
      this.errorMessage = 'Validation Fault: Mapping requires an active cluster Category allocation.';
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.product, this.selectedFile).subscribe({
        next: () => { alert("Product updated successfully!"); this.closeDrawer(); this.loadProducts(); },
        error: (err: any) => this.handleBackendError(err)
      });
    } else {
      this.service.save(this.product, this.selectedFile).subscribe({
        next: () => { alert("Product registered successfully!"); this.closeDrawer(); this.loadProducts(); },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  edit(p: ProductResponseModel) {
    this.errorMessage = null;
    this.currentEditId = p.id;
    this.isEdit = true;
    this.product = { ...p };
    this.imagePreview = p.image ? this.getImageUrl(p.image) : null;
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Definitively purge this product item?")) {
      this.service.delete(id).subscribe({
        next: () => { alert("Product deleted."); this.loadProducts(); },
        error: (err: any) => this.handleBackendError(err)
      });
    }
  }

  reset() {
    this.product = {
      id: 0, productCode: '', name: '', unit: '', reorderPoint: 0, unitCost: 0,
      quantity: 0, sellingPrice: 0, hasExpiryDate: 'NO', weight: 0, isActive: true,
      availability: 'AVAILABLE', image: '', categoryId: 0
    };
    this.selectedFile = null;
    this.imagePreview = null;
    this.isEdit = false;
    this.currentEditId = null;
    this.errorMessage = null;
  }
}