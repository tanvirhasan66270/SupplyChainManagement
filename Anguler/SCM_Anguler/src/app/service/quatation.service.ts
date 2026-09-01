import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { QuotationRequestModel, QuotationResponseModel } from '../component/shared/model/quatationModel';

@Injectable({
  providedIn: 'root',
})
export class QuotationService {
  private apiUrl = environment.apiUrl + "quotations";

  constructor(private http: HttpClient) { }

  findAll(): Observable<QuotationResponseModel[]> {
  return this.http.get<QuotationResponseModel[]>(this.apiUrl);
}

  getById(id: number): Observable<QuotationResponseModel> {
    return this.http.get<QuotationResponseModel>(`${this.apiUrl}/${id}`);
  }

  
  save(quotation: QuotationRequestModel, file: File | null): Observable<QuotationResponseModel> {
    const formData = new FormData();
    
    formData.append(
      'quotation',
      new Blob([JSON.stringify(quotation)], { type: 'application/json' })
    );
    
    if (file) {
      formData.append('image', file); 
    }

    return this.http.post<QuotationResponseModel>(this.apiUrl, formData);
  }

  update(id: number, quotation: QuotationRequestModel): Observable<QuotationResponseModel> {
    return this.http.put<QuotationResponseModel>(`${this.apiUrl}/${id}`, quotation);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
  updateStatus(id: number, status: string): Observable<any> {
  return this.http.patch(`${environment.apiUrl}quotations/${id}/status`, status);
}
}
