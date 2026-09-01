import { CommonModule } from '@angular/common';
import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivityLogModel } from '../../shared/model/ActivityLogModel';
import { ActivityLogService } from '../../../service/activity.log.service';


@Component({
  selector: 'app-activity.log.component',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './activity.log.component.html',
  styleUrl: './activity.log.component.css',
})
export class ActivityLogComponent implements OnInit {

  logs: ActivityLogModel[] = [];
  selectedLog: ActivityLogModel | null = null; 
  errorMessage: string | null = null;

  // ডাইনামিক ফিল্টার মডেলস
  filterModule: string = '';
  searchUserId: string = '';
  filterStatus: string = '';

  constructor(
    private service: ActivityLogService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadAllLogs();
  }

  loadAllLogs() {
    this.errorMessage = null;
    this.resetFilters(false);
    this.service.findAll().subscribe({
      next: (data) => {
        this.logs = data || [];
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleError(err)
    });
  }

  onModuleFilter() {
    if (!this.filterModule) { this.loadAllLogs(); return; }
    this.resetFilters(false, 'module');
    this.service.findByModule(this.filterModule).subscribe({
      next: (data) => { this.logs = data || []; this.cdr.markForCheck(); },
      error: (err: any) => this.handleError(err)
    });
  }

  onUserIdSearch() {
    if (!this.searchUserId.trim()) { this.loadAllLogs(); return; }
    this.resetFilters(false, 'user');
    this.service.findByUserId(this.searchUserId.trim()).subscribe({
      next: (data) => { this.logs = data || []; this.cdr.markForCheck(); },
      error: (err: any) => this.handleError(err)
    });
  }

  onStatusFilter() {
    if (!this.filterStatus) { this.loadAllLogs(); return; }
    this.resetFilters(false, 'status');
    this.service.findByStatus(this.filterStatus).subscribe({
      next: (data) => { this.logs = data || []; this.cdr.markForCheck(); },
      error: (err: any) => this.handleError(err)
    });
  }

  viewDetails(log: ActivityLogModel) {
    this.selectedLog = log;
  }

  closeDetails() {
    this.selectedLog = null;
  }

  resetFilters(reload = true, except: 'module' | 'user' | 'status' | null = null) {
    if (except !== 'module') this.filterModule = '';
    if (except !== 'user') this.searchUserId = '';
    if (except !== 'status') this.filterStatus = '';
    if (reload) this.loadAllLogs();
  }

  private handleError(err: any) {
    this.errorMessage = err.error?.message || err.message || "Audit Trail Stream Timeout.";
    this.cdr.markForCheck();
  }
}
