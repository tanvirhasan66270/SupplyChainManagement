import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  ProcurementRequestModel,
  ProcurementResponseDTO,
} from '../component/shared/model/procourmentModel';

@Injectable({
  providedIn: 'root',
})
export class ProcurementService {
  private apiUrl = environment.apiUrl + 'procurements';

  constructor(private http: HttpClient) {}

  findAll(): Observable<ProcurementResponseDTO[]> {
    return this.http.get<ProcurementResponseDTO[]>(this.apiUrl);
  }

  getById(id: number): Observable<ProcurementResponseDTO> {
    return this.http.get<ProcurementResponseDTO>(`${this.apiUrl}/${id}`);
  }

  save(
    procurement: ProcurementRequestModel,
    file: File | null,
  ): Observable<ProcurementResponseDTO> {
    const formData = new FormData();
    formData.append(
      'procurement',
      new Blob([JSON.stringify(procurement)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('file', file); // ব্যাকএন্ড রিকোয়েস্ট পার্ট নেম "file"
    }
    return this.http.post<ProcurementResponseDTO>(this.apiUrl, formData);
  }

  update(
    id: number,
    procurement: ProcurementRequestModel,
    file: File | null,
  ): Observable<ProcurementResponseDTO> {
    const formData = new FormData();
    formData.append(
      'procurement',
      new Blob([JSON.stringify(procurement)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('file', file);
    }
    return this.http.put<ProcurementResponseDTO>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  getProcurementByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }
}
