import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { PaymentStatementResponse } from '../component/shared/model/PaymentStatementModel';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environment/environment';

@Injectable({
  providedIn: 'root',
})
export class PaymentStatementService {
  private apiUrl = environment.apiUrl + 'payment-statements'; // Base API URL

  constructor(private http: HttpClient) {}

  addPayment(formData: FormData): Observable<PaymentStatementResponse> {
    return this.http.post<PaymentStatementResponse>(this.apiUrl, formData);
  }

  updatePayment(id: number, formData: FormData): Observable<PaymentStatementResponse> {
    return this.http.put<PaymentStatementResponse>(`${this.apiUrl}/${id}`, formData);
  }

  updatePaymentStatus(id: number, status: string): Observable<PaymentStatementResponse> {
    return this.http.patch<PaymentStatementResponse>(`${this.apiUrl}/${id}/status?status=${status}`, null);
  }

  getPaymentsByOrderId(orderId: number): Observable<PaymentStatementResponse[]> {
    return this.http.get<PaymentStatementResponse[]>(`${this.apiUrl}/order/${orderId}`);
  }

  getPaymentsByOrderNumber(orderNumber: string): Observable<PaymentStatementResponse[]> {
    return this.http.get<PaymentStatementResponse[]>(`${this.apiUrl}/order-number/${orderNumber}`);
  }

  getPaymentsByStatus(status: string): Observable<PaymentStatementResponse[]> {
    return this.http.get<PaymentStatementResponse[]>(`${this.apiUrl}/status/${status}`);
  }

  getPaymentById(id: number): Observable<PaymentStatementResponse> {
    return this.http.get<PaymentStatementResponse>(`${this.apiUrl}/${id}`);
  }

  deletePayment(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
