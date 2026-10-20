import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { SupplierRequestDTO, SupplierResponseDTO } from '../component/shared/model/supplierModel';

@Injectable({
  providedIn: 'root',
})
export class SupplierService {
  private apiUrl = environment.apiUrl + 'suppliers';

  constructor(private http: HttpClient) {}

  findAll(): Observable<SupplierResponseDTO[]> {
    return this.http.get<SupplierResponseDTO[]>(this.apiUrl);
  }

  getById(id: number): Observable<SupplierResponseDTO> {
    return this.http.get<SupplierResponseDTO>(`${this.apiUrl}/${id}`);
  }

  save(supplier: SupplierRequestDTO, file: File | null): Observable<SupplierResponseDTO> {
    const formData = new FormData();
    formData.append(
      'suppliers',
      new Blob([JSON.stringify(supplier)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('image', file);
    }
    return this.http.post<SupplierResponseDTO>(this.apiUrl, formData);
  }

  update(
    id: number,
    supplier: SupplierRequestDTO,
    file: File | null,
  ): Observable<SupplierResponseDTO> {
    const formData = new FormData();
    formData.append(
      'suppliers',
      new Blob([JSON.stringify(supplier)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('image', file);
    }
    return this.http.put<SupplierResponseDTO>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }

  getSupplierByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }
}
