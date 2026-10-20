import { Component, OnInit } from '@angular/core';
import { StorageService } from '../../auth_service/storage.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-role-deriect.component',
  imports: [],
  templateUrl: './role-deriect.component.html',
  styleUrl: './role-deriect.component.css',
})
export class RoleDeriectComponent implements OnInit {

constructor(private storage: StorageService, private router: Router) { }

  ngOnInit(): void {
    const role = this.storage.getRole();
    const map: Record<string, string> = {
      ADMIN:  '/dashboard/admin',
      MANAGER:  '/dashboard/manager',
      DRIVER:  '/dashboard/driver',
      PROCUREMENT: '/dashboard/procurement',
      QC_INSPECTOR: '/dashboard/qc-inspector',
      LOGISTICS_OFFICER:  '/dashboard/logistics',
      COMMERCIAL_OFFICER:  '/dashboard/commercial',
      CUSTOMER:   '/dashboard/customer',
      SUPPLIER:   '/dashboard/supplier',
      SALES_OFFICER: '/dashboard/sales',
    };
    this.router.navigate([map[role ?? ''] ?? '/login']);
  }


}
