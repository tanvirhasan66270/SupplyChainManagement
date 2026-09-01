import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { POLineItemRequestDTO, POLineItemResponseDTO } from '../component/shared/model/pOLineItemModel';

@Injectable({
  providedIn: 'root',
})
export class PoLineItemService {
  private apiUrl = environment.apiUrl + "po-line-items";

  constructor(private http: HttpClient) { }

  findAll(): Observable<POLineItemResponseDTO[]> {
    return this.http.get<POLineItemResponseDTO[]>(this.apiUrl);
  }

  getById(id: number): Observable<POLineItemResponseDTO> {
    return this.http.get<POLineItemResponseDTO>(`${this.apiUrl}/${id}`);
  }

  save(item: POLineItemRequestDTO): Observable<POLineItemResponseDTO> {
    return this.http.post<POLineItemResponseDTO>(this.apiUrl, item);
  }

  update(id: number, item: POLineItemRequestDTO): Observable<POLineItemResponseDTO> {
    return this.http.put<POLineItemResponseDTO>(`${this.apiUrl}/${id}`, item);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }

  trackByNumber(trackingNumber: string): Observable<POLineItemResponseDTO> {
    return this.http.get<POLineItemResponseDTO>(`${this.apiUrl}/track/${trackingNumber}`);
  }
}
