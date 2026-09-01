import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { DashboardSummaryModel } from '../component/shared/model/dashboard';

@Injectable({
  providedIn: 'root',
})
export class DashboardService {
  private apiUrl = environment.apiUrl + 'dashboard';

  constructor(private http: HttpClient) {}

  getSummary(
    dateFilter?: string,
    startDate?: string,
    endDate?: string
  ): Observable<DashboardSummaryModel> {
    let params = new HttpParams();
    if (dateFilter) {
      params = params.set('dateFilter', dateFilter);
    }
    if (startDate && endDate) {
      params = params.set('startDate', startDate).set('endDate', endDate);
    }
    return this.http.get<DashboardSummaryModel>(`${this.apiUrl}/summary`, { params });
  }

  getTable(
    entityType: string,
    page: number,
    size: number,
    search?: string,
    sortField?: string,
    sortDir?: string
  ): Observable<any> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('size', size.toString());
    
    if (search) {
      params = params.set('search', search);
    }
    if (sortField) {
      params = params.set('sortField', sortField);
    }
    if (sortDir) {
      params = params.set('sortDir', sortDir);
    }

    return this.http.get<any>(`${this.apiUrl}/tables/${entityType}`, { params });
  }
}
