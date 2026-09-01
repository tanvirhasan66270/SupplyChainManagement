import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  QCInspectionRequestModel,
  QCInspectionResponseModel,
} from '../component/shared/model/qc-inspection';

@Injectable({
  providedIn: 'root',
})
export class QcInspectionService {
  private apiUrl = environment.apiUrl + 'qc-inspections';

  constructor(private http: HttpClient) {}

  findAll(): Observable<QCInspectionResponseModel[]> {
    return this.http.get<QCInspectionResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<QCInspectionResponseModel> {
    return this.http.get<QCInspectionResponseModel>(`${this.apiUrl}/${id}`);
  }

  // 🧪 Multipart/Form-Data পোস্ট মেকানিজম (জ্যাকসন পার্সার সেফটি সহ)
  save(
    inspection: QCInspectionRequestModel,
    file: File | null,
  ): Observable<QCInspectionResponseModel> {
    const formData = new FormData();
    formData.append('inspection', JSON.stringify(inspection));
    if (file) {
      formData.append('file', file);
    }
    return this.http.post<QCInspectionResponseModel>(this.apiUrl, formData);
  }

  update(
    id: number,
    inspection: QCInspectionRequestModel,
    file: File | null,
  ): Observable<QCInspectionResponseModel> {
    const formData = new FormData();
    formData.append('inspection', JSON.stringify(inspection));
    if (file) {
      formData.append('file', file);
    }
    return this.http.put<QCInspectionResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
