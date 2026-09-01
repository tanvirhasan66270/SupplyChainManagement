import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { InvoiceRequestModel, InvoiceResponseModel } from '../component/shared/model/invoiceModel';

@Injectable({
  providedIn: 'root',
})
export class InvoiceService {
  private apiUrl = environment.apiUrl + 'invoices'; // Synced with @RequestMapping("/api/invoices")

  constructor(private http: HttpClient) { }

  findAll(): Observable<InvoiceResponseModel[]> {
    return this.http.get<InvoiceResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<InvoiceResponseModel> {
    return this.http.get<InvoiceResponseModel>(`${this.apiUrl}/${id}`);
  }

  create(invoice: InvoiceRequestModel): Observable<InvoiceResponseModel> {
    return this.http.post<InvoiceResponseModel>(this.apiUrl, invoice);
  }

  update(id: number, invoice: InvoiceRequestModel): Observable<InvoiceResponseModel> {
    return this.http.put<InvoiceResponseModel>(`${this.apiUrl}/${id}`, invoice);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
