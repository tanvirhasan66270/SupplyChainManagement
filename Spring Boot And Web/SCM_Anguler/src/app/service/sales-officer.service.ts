import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  SalesOfficerRequestDTO,
  SalesOfficerResponseDTO,
} from '../component/shared/model/salesOfficerModel';

@Injectable({
  providedIn: 'root',
})
export class SalesOfficerService {
  private apiUrl = environment.apiUrl + 'sales-officers';

  constructor(private http: HttpClient) {}

  findAll(): Observable<SalesOfficerResponseDTO[]> {
    return this.http.get<SalesOfficerResponseDTO[]>(this.apiUrl);
  }

  getById(id: number): Observable<SalesOfficerResponseDTO> {
    return this.http.get<SalesOfficerResponseDTO>(`${this.apiUrl}/${id}`);
  }

  save(officer: SalesOfficerRequestDTO, file: File | null): Observable<SalesOfficerResponseDTO> {
    const formData = new FormData();
    formData.append(
      'salesOfficer',
      new Blob([JSON.stringify(officer)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('file', file);
    }
    return this.http.post<SalesOfficerResponseDTO>(this.apiUrl, formData);
  }

  update(
    id: number,
    officer: SalesOfficerRequestDTO,
    file: File | null,
  ): Observable<SalesOfficerResponseDTO> {
    const formData = new FormData();
    formData.append(
      'salesOfficer',
      new Blob([JSON.stringify(officer)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('file', file);
    }
    return this.http.put<SalesOfficerResponseDTO>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  getSalesOfficerByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }
}
