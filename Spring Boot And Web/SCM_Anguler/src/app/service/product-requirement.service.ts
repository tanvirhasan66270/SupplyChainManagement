import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { ProductRequirementRequest, ProductRequirementResponse } from '../component/shared/model/productRequirementModel';

@Injectable({
  providedIn: 'root'
})
export class ProductRequirementService {

  private apiUrl = environment.apiUrl + 'product-requirements';

  constructor(private http: HttpClient) { }

  findAll(): Observable<ProductRequirementResponse[]> {
    return this.http.get<ProductRequirementResponse[]>(this.apiUrl);
  }

  getById(id: number): Observable<ProductRequirementResponse> {
    return this.http.get<ProductRequirementResponse>(`${this.apiUrl}/${id}`);
  }

  save(dto: ProductRequirementRequest): Observable<ProductRequirementResponse> {
    return this.http.post<ProductRequirementResponse>(this.apiUrl, dto);
  }

  update(id: number, dto: ProductRequirementRequest): Observable<ProductRequirementResponse> {
    return this.http.put<ProductRequirementResponse>(`${this.apiUrl}/${id}`, dto);
  }

  updateStatus(id: number, status: string): Observable<ProductRequirementResponse> {
    return this.http.patch<ProductRequirementResponse>(`${this.apiUrl}/${id}/status`, null, {
      params: { status }
    });
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
