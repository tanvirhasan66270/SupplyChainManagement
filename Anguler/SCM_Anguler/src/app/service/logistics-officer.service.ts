import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  LogisticsOfficerRequestModel,
  LogisticsOfficerResponseModel,
} from '../component/shared/model/logisticsOfficer';

@Injectable({
  providedIn: 'root',
})
export class LogisticsOfficerService {
  private apiUrl = environment.apiUrl + 'logistics-officers';

  constructor(private http: HttpClient) {}

  findAll(): Observable<LogisticsOfficerResponseModel[]> {
    return this.http.get<LogisticsOfficerResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<LogisticsOfficerResponseModel> {
    return this.http.get<LogisticsOfficerResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(
    officer: LogisticsOfficerRequestModel,
    file: File | null,
  ): Observable<LogisticsOfficerResponseModel> {
    const formData = new FormData();

    formData.append('officer', new Blob([JSON.stringify(officer)], { type: 'application/json' }));

    if (file) {
      formData.append('file', file);
    }

    return this.http.post<LogisticsOfficerResponseModel>(this.apiUrl, formData);
  }

  update(
    id: number,
    officer: LogisticsOfficerRequestModel,
    file: File | null,
  ): Observable<LogisticsOfficerResponseModel> {
    const formData = new FormData();

    formData.append('officer', new Blob([JSON.stringify(officer)], { type: 'application/json' }));

    if (file) {
      formData.append('file', file);
    }

    return this.http.put<LogisticsOfficerResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  getLogisticsOfficerByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }
}
