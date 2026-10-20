import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { ActivityLogModel } from '../component/shared/model/ActivityLogModel';

@Injectable({
  providedIn: 'root',
})
export class ActivityLogService {
  private apiUrl = environment.apiUrl + 'admin/logs';

  constructor(private http: HttpClient) { }

  findAll(): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(this.apiUrl);
  }

  findByModule(moduleName: string): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(`${this.apiUrl}/module/${moduleName}`);
  }

  findByUserId(userId: string): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(`${this.apiUrl}/user/${userId}`);
  }

  findByStatus(status: string): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(`${this.apiUrl}/status/${status}`);
  }
}
