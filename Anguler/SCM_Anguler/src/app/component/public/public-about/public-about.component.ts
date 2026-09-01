import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-public-about',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './public-about.component.html',
  styleUrls: ['./public-about.component.css']
})
export class PublicAboutComponent {
  coreValues = [
    { title: 'Reliability', desc: 'Ensuring on-time deliveries with strict compliance to international standards and SLAs.', icon: 'bi-check-circle', color: '#0d6efd', iconBg: 'bg-primary-subtle' },
    { title: 'Global Network', desc: 'Over 150+ ports, warehouses, and logistics hubs integrated across 35+ countries.', icon: 'bi-globe2', color: '#198754', iconBg: 'bg-success-subtle' },
    { title: 'Green Logistics', desc: 'Committed to decreasing carbon footprints via sustainable transport and eco-friendly warehousing.', icon: 'bi-leaf', color: '#ffc107', iconBg: 'bg-warning-subtle' },
    { title: 'Innovation', desc: 'AI-powered route optimization, predictive analytics, and blockchain-secured documentation.', icon: 'bi-lightbulb', color: '#dc3545', iconBg: 'bg-danger-subtle' },
    { title: 'Transparency', desc: 'Real-time visibility across your entire supply chain with automated alerts and reporting.', icon: 'bi-eye', color: '#0dcaf0', iconBg: 'bg-info-subtle' },
    { title: 'Customer First', desc: 'Dedicated account managers, 24/7 support, and customizable SLA agreements.', icon: 'bi-heart', color: '#6f42c1', iconBg: 'bg-purple-subtle' },
  ];

  milestones = [
    { year: '2018', title: 'Founded in Dhaka', desc: 'Started with a vision to digitize Bangladesh trade logistics.', color: '#0d6efd' },
    { year: '2020', title: '100+ Ports', desc: 'Expanded network to cover major ports across Asia and Europe.', color: '#198754' },
    { year: '2023', title: 'AI Integration', desc: 'Launched AI-powered route optimization and predictive analytics.', color: '#ffc107' },
    { year: '2026', title: 'Global Scale', desc: 'Managing ৳4.8B+ trade volume with 2,000+ active businesses.', color: '#dc3545' },
  ];
}
