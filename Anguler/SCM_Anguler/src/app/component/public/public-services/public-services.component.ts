import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-public-services',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './public-services.component.html',
  styleUrls: ['./public-services.component.css']
})
export class PublicServicesComponent {
  services = [
    {
      title: 'Global Product Sourcing',
      desc: 'Secure verified suppliers worldwide with competitive bidding matrices and automated RFQ workflows.',
      icon: 'bi-cart-check',
      color: '#0d6efd',
      iconBg: 'bg-primary-subtle',
      headerBg: 'bg-primary-subtle',
      features: [
        'Access to 10,000+ verified suppliers across 50+ countries',
        'Automated Request for Quotation (RFQ) management',
        'Supplier performance scoring and compliance tracking',
        'Secure payment escrow and milestone-based releases',
      ]
    },
    {
      title: 'Air & Ocean Freight',
      desc: 'Multimodal container routes with priority consignments and real-time GPS tracking.',
      icon: 'bi-truck',
      color: '#198754',
      iconBg: 'bg-success-subtle',
      headerBg: 'bg-success-subtle',
      features: [
        'Air, sea, road, and rail logistics integration',
        'Real-time container tracking with ETA predictions',
        'Optimized route planning with cost comparison',
        'Consolidation and deconsolidation services',
      ]
    },
    {
      title: 'Warehouse Management',
      desc: 'Automated warehouse status audits, cold chain storage, and cross-docking operations.',
      icon: 'bi-building-up',
      color: '#ffc107',
      iconBg: 'bg-warning-subtle',
      headerBg: 'bg-warning-subtle',
      features: [
        'Temperature-controlled cold storage facilities',
        'Automated inventory counting and cycle audits',
        'Cross-docking hubs for rapid transit operations',
        'Real-time stock visibility and alerts',
      ]
    },
    {
      title: 'Customs & Trade Compliance',
      desc: 'Clearance logs aligning proforma billing, HS code verification, and bank matching.',
      icon: 'bi-file-earmark-lock',
      color: '#dc3545',
      iconBg: 'bg-danger-subtle',
      headerBg: 'bg-danger-subtle',
      features: [
        'Automated HS code mapping and classification',
        'Bill of lading and customs document generation',
        'Letter of credit (LC) bank matching',
        'Incoterms compliance and regulatory filing',
      ]
    },
  ];

  steps = [
    { title: 'Create Account', desc: 'Sign up for free and set up your business profile in minutes.', color: '#0d6efd', colorBg: 'bg-primary-subtle' },
    { title: 'Connect Partners', desc: 'Link your suppliers, freight forwarders, and customs brokers.', color: '#198754', colorBg: 'bg-success-subtle' },
    { title: 'Manage Operations', desc: 'Track shipments, manage inventory, and process documentation.', color: '#ffc107', colorBg: 'bg-warning-subtle' },
    { title: 'Scale Globally', desc: 'Expand to new markets with our worldwide logistics network.', color: '#dc3545', colorBg: 'bg-danger-subtle' },
  ];
}
