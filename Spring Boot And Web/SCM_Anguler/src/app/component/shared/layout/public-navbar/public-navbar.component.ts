import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';


@Component({
  selector: 'app-public-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, HttpClientModule],
  templateUrl: './public-navbar.component.html',
  styleUrls: ['./public-navbar.component.css']
})
export class PublicNavbarComponent implements OnInit {
  mobileMenuOpen = false;
  activeDropdown: string | null = null;
  activeMegaTab: string = 'procurement';
  
  // Settings & Context
  currentLanguage = 'EN';
  currentCurrency = 'USD';
  themeMode = 'light';
  
  // Public Modals / Forms
  showSearchModal = false;
  showQuoteModal = false;
  searchQuery = '';
  
  // Public Tracking Search
  trackingNumber = '';
  trackingResult: any = null;
  showTrackingResult = false;
  
  // Quote Form Fields
  quoteForm = {
    product: '',
    qty: 1,
    destination: '',
    shippingMethod: 'SEA',
    deliveryTime: 'STANDARD',
    notes: ''
  };

  constructor(
    private cdr: ChangeDetectorRef, 
    private router: Router
  ) {}

  ngOnInit(): void {
    const savedTheme = localStorage.getItem('theme') || 'light';
    this.themeMode = savedTheme;
    if (savedTheme === 'dark') {
      document.body.classList.add('dark-theme');
    }
  }

  toggleMobileMenu(): void {
    this.mobileMenuOpen = !this.mobileMenuOpen;
    this.cdr.markForCheck();
  }

  toggleDropdown(dropdownName: string): void {
    this.activeDropdown = this.activeDropdown === dropdownName ? null : dropdownName;
    this.cdr.markForCheck();
  }

  setLanguage(lang: string): void {
    this.currentLanguage = lang;
    this.cdr.markForCheck();
  }

  setCurrency(curr: string): void {
    this.currentCurrency = curr;
    this.cdr.markForCheck();
  }

  toggleTheme(): void {
    this.themeMode = this.themeMode === 'light' ? 'dark' : 'light';
    localStorage.setItem('theme', this.themeMode);
    document.body.classList.toggle('dark-theme', this.themeMode === 'dark');
    this.cdr.markForCheck();
  }

  trackShipment(): void {
    if (!this.trackingNumber.trim()) {
      alert('Please enter a valid tracking/container reference number.');
      return;
    }
    // Simulated Tracking Database Sourcing
    this.trackingResult = {
      ref: this.trackingNumber.toUpperCase(),
      origin: 'Port of Shanghai (CN)',
      destination: 'Port of Chittagong (BD)',
      status: 'IN TRANSIT',
      vessel: 'Maersk Mc-Kinney Moller',
      eta: 'July 18, 2026',
      progress: 65
    };
    this.showTrackingResult = true;
    this.cdr.markForCheck();
  }

  submitQuote(): void {
    if (!this.quoteForm.product || !this.quoteForm.destination) {
      alert('Please fill out the product and destination country fields.');
      return;
    }
    alert(`Quotation request submitted successfully for ${this.quoteForm.qty} unit(s) of ${this.quoteForm.product}! Our logistics agents will email you shortly.`);
    this.showQuoteModal = false;
    this.quoteForm = {
      product: '',
      qty: 1,
      destination: '',
      shippingMethod: 'SEA',
      deliveryTime: 'STANDARD',
      notes: ''
    };
    this.cdr.markForCheck();
  }

  globalSearch(): void {
    if (this.searchQuery.trim()) {
      alert(`Simulating Global SCM Catalog Search for: "${this.searchQuery}"`);
      this.showSearchModal = false;
      this.searchQuery = '';
      this.cdr.markForCheck();
    }
  }


}

