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

  // 🔍 অল লগ ফেচ করা
  findAll(): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(this.apiUrl);
  }

  // 📦 মডিউল বেসড ফিল্টারিং
  findByModule(moduleName: string): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(`${this.apiUrl}/module/${moduleName}`);
  }

  // 👤 ইউজার আইডি ট্র্যাক লুপ
  findByUserId(userId: string): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(`${this.apiUrl}/user/${userId}`);
  }

  // 🚦 এনাম স্ট্যাটাস ফিল্টারিং (SUCCESS/FAILED)
  findByStatus(status: string): Observable<ActivityLogModel[]> {
    return this.http.get<ActivityLogModel[]>(`${this.apiUrl}/status/${status}`);
  }
}
