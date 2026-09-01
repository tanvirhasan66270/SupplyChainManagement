import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-public-landing',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './public-landing.component.html',
  styleUrls: ['./public-landing.component.css']
})
export class PublicLandingComponent {
  trackingNumber = '';
  trackingDetails: any = null;
  showDetails = false;

  services = [
    { title: 'Global Procurement', desc: 'Source verified suppliers, manage RFQs, and issue purchase orders across 50+ countries.', icon: 'bi-cart-check', color: '#0d6efd', iconBg: 'bg-primary-subtle' },
    { title: 'Freight Forwarding', desc: 'Air, ocean, and road logistics with optimized routing and real-time container tracking.', icon: 'bi-truck', color: '#198754', iconBg: 'bg-success-subtle' },
    { title: 'Warehouse Hubs', desc: 'Cold storage, cross-docking, and automated inventory management across global hubs.', icon: 'bi-building-up', color: '#ffc107', iconBg: 'bg-warning-subtle' },
    { title: 'Customs Compliance', desc: 'Automated HS code mapping, bill of lading docs, and letter of credit bank matching.', icon: 'bi-file-earmark-lock', color: '#dc3545', iconBg: 'bg-danger-subtle' },
  ];

  whyUs = [
    { title: 'AI-Powered Route Optimization', desc: 'Machine learning algorithms find the fastest, cheapest shipping routes.', icon: 'bi-cpu', color: '#0d6efd', iconBg: 'bg-primary-subtle' },
    { title: 'Real-Time Visibility', desc: 'Track every shipment, container, and delivery across your entire supply chain.', icon: 'bi-eye', color: '#198754', iconBg: 'bg-success-subtle' },
    { title: 'Compliance Automation', desc: 'Auto-generate customs docs, LC papers, and regulatory filings.', icon: 'bi-shield-check', color: '#ffc107', iconBg: 'bg-warning-subtle' },
  ];

  stats = [
    { value: '৳4.8B+', label: 'Trade Volume Managed', color: '#0d6efd' },
    { value: '150+', label: 'Ports & Airports', color: '#198754' },
    { value: '2,000+', label: 'Active Businesses', color: '#ffc107' },
    { value: '99.8%', label: 'QC Pass Rate', color: '#dc3545' },
  ];

  trackShipment(): void {
    if (!this.trackingNumber.trim()) {
      alert('Please enter a valid tracking reference.');
      return;
    }
    this.trackingDetails = {
      ref: this.trackingNumber.toUpperCase(),
      status: 'DEPARTED TRANSSHIPMENT HUB',
      origin: 'Port of Shanghai (CN)',
      destination: 'Port of Chittagong (BD)',
      vessel: 'MSC Isabelle II',
      eta: 'July 22, 2026',
      progress: 42
    };
    this.showDetails = true;
  }
}
