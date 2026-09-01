import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-public-network',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './public-network.component.html',
  styleUrls: ['./public-network.component.css']
})
export class PublicNetworkComponent {
  heroStats = [
    { value: '150+', label: 'Ports', icon: 'bi-anchor', color: '#3b82f6' },
    { value: '35+', label: 'Countries', icon: 'bi-globe2', color: '#198754' },
    { value: '50+', label: 'Warehouses', icon: 'bi-building', color: '#ffc107' },
    { value: '24/7', label: 'Operations', icon: 'bi-clock', color: '#dc3545' },
  ];

  hubs = [
    {
      region: 'Asia Pacific',
      emoji: '\uD83C\uDF0F',
      countries: '12',
      majorPorts: ['Shanghai', 'Singapore', 'Chittagong', 'Mumbai', 'Ho Chi Minh'],
      desc: 'Our largest network spanning major manufacturing and shipping hubs across Asia.',
      headerBg: 'bg-primary-subtle'
    },
    {
      region: 'Europe',
      emoji: '\uD83C\uDDEA\uD83C\uDDFA',
      countries: '8',
      majorPorts: ['Rotterdam', 'Hamburg', 'Antwerp', 'London', 'Marseille'],
      desc: 'Premium logistics corridors connecting European markets with global supply chains.',
      headerBg: 'bg-success-subtle'
    },
    {
      region: 'Americas',
      emoji: '\uD83C\uDDF2\uD83C\uDDFD',
      countries: '6',
      majorPorts: ['Long Beach', 'New York', 'Houston', 'Santos', 'Vancouver'],
      desc: 'Full coverage of North and South American trade routes and customs networks.',
      headerBg: 'bg-warning-subtle'
    },
    {
      region: 'Middle East & Africa',
      emoji: '\uD83C\uDDF8\uD83C\uDDE6',
      countries: '5',
      majorPorts: ['Dubai', 'Jebel Ali', 'Cape Town', 'Lagos', 'Djibouti'],
      desc: 'Strategic positioning for Africa-Middle East trade corridor and energy logistics.',
      headerBg: 'bg-danger-subtle'
    },
    {
      region: 'Oceania',
      emoji: '\uD83C\uDDF5\uD83C\uDDF3',
      countries: '3',
      majorPorts: ['Sydney', 'Melbourne', 'Auckland'],
      desc: 'Pacific region coverage for Australia and New Zealand trade operations.',
      headerBg: 'bg-info-subtle'
    },
    {
      region: 'Central Asia',
      emoji: '\uD83C\uDDF0\uD83C\uDDFF',
      countries: '4',
      majorPorts: ['Almaty', 'Tashkent', 'Tbilisi', 'Istanbul'],
      desc: 'Emerging Silk Road corridors connecting East-West overland freight routes.',
      headerBg: 'bg-purple-subtle'
    },
  ];

  infrastructure = [
    { value: '50+', label: 'Warehouses', icon: 'bi-building', color: '#0d6efd' },
    { value: '200+', label: 'Fleet Vehicles', icon: 'bi-truck', color: '#198754' },
    { value: '500+', label: 'Customs Agents', icon: 'bi-person-badge', color: '#ffc107' },
    { value: '1000+', label: 'Trade Partners', icon: 'bi-handshake', color: '#dc3545' },
  ];
}
