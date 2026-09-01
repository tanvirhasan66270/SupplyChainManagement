import { Component, OnInit, ChangeDetectorRef, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { environment } from '../../../../environment/environment';
import { CustomerRequirementService } from '../../../service/customer-requirement.service';

@Component({
  selector: 'app-public-products',
  standalone: true,
  imports: [CommonModule, HttpClientModule, FormsModule],
  templateUrl: './public-products.component.html',
  styleUrls: ['./public-products.component.css']
})
export class PublicProductsComponent implements OnInit {
  categories: any[] = [];
  allProducts: any[] = [];
  displayedProducts: any[] = [];
  selectedCategoryId: number | null = null;
  imgUrl = environment.imgUrl;
  isLoading = true;

  isPdfModalOpen = false;
  selectedProductForPdf: any = null;
  @ViewChild('pdfPreviewContainer') pdfPreviewContainer!: ElementRef;

  // Contact for Others Product Modal state
  showRequirementModal = false;
  requirementForm = {
    productName: '',
    productDescription: '',
    customerName: '',
    contactNumber: '',
    email: ''
  };

  constructor(
    private http: HttpClient,
    private cdr: ChangeDetectorRef,
    private requirementService: CustomerRequirementService
  ) {}

  ngOnInit(): void {
    this.loadCategories();
    this.loadProducts();
  }

  loadCategories(): void {
    this.http.get<any[]>(`${environment.apiUrl}category/public`).subscribe({
      next: (res) => {
        this.categories = res || [];
        this.cdr.detectChanges();
      },
      error: (err) => console.error('Failed to load categories', err)
    });
  }

  loadProducts(): void {
    this.http.get<any[]>(`${environment.apiUrl}products/public`).subscribe({
      next: (res) => {
        this.allProducts = res || [];
        this.displayedProducts = this.allProducts;
        this.isLoading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('Failed to load products', err);
        this.isLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  selectCategory(categoryId: number | null): void {
    this.selectedCategoryId = categoryId;
    if (categoryId === null) {
      this.displayedProducts = this.allProducts;
    } else {
      this.displayedProducts = this.allProducts.filter(p => p.category?.id === categoryId || p.categoryId === categoryId);
    }
    this.cdr.detectChanges();
  }

  viewProductPdf(prod: any): void {
    this.selectedProductForPdf = prod;
    this.isPdfModalOpen = true;
    this.cdr.detectChanges();
  }

  closePdfModal(): void {
    this.isPdfModalOpen = false;
    this.selectedProductForPdf = null;
    this.cdr.detectChanges();
  }

  getImageUrl(imageName: string): string {
    return imageName ? `${this.imgUrl}product/${imageName}` : '';
  }

  onImageError(event: any, product: any): void {
    event.target.style.display = 'none';
    product.image = null;
  }

  downloadPdfFromModal(): void {
    const element = this.pdfPreviewContainer.nativeElement;
    
    Promise.all([
      import('jspdf'),
      import('html2canvas')
    ]).then(([{ jsPDF }, { default: html2canvas }]) => {
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
  
        pdf.save(`${this.selectedProductForPdf?.productCode || 'Product'}_Specification.pdf`);
      });
    }).catch(err => {
      console.error('Failed to load libraries', err);
    });
  }

  // Submit Contact for Others Product Form
  submitRequirement(): void {
    if (!this.requirementForm.productName || !this.requirementForm.customerName) {
      alert('Please fill out Product Name and Your Name.');
      return;
    }

    this.requirementService.submitPublicRequirement(this.requirementForm).subscribe({
      next: (res) => {
        alert('Your requirement has been submitted. Our Sales and Logistics team will contact you soon.');
        this.showRequirementModal = false;
        this.requirementForm = { productName: '', productDescription: '', customerName: '', contactNumber: '', email: '' };
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error(err);
        alert('Failed to submit requirement. Please try again.');
      }
    });
  }
}
