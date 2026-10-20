import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { CustomerOrderRequestModel, CustomerOrderResponseModel } from '../component/shared/model/customerOrder';

@Injectable({
  providedIn: 'root',
})
export class CustomerOrderService {
  private apiUrl = environment.apiUrl + "customerOrders";

  constructor(private http: HttpClient) { }

  findAll(): Observable<CustomerOrderResponseModel[]> {
    return this.http.get<CustomerOrderResponseModel[]>(this.apiUrl);
  }

getByCustomerEmail(): Observable<CustomerOrderResponseModel[]> {
  return this.http.get<CustomerOrderResponseModel[]>(`${this.apiUrl}/customer`);
}


  getById(id: number): Observable<CustomerOrderResponseModel> {
    return this.http.get<CustomerOrderResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(order: CustomerOrderRequestModel, image?: File): Observable<CustomerOrderResponseModel> {
    const formData = new FormData();
    formData.append('order', new Blob([JSON.stringify(order)], { type: 'application/json' }));
    if (image) {
      formData.append('image', image);
    }
    return this.http.post<CustomerOrderResponseModel>(this.apiUrl, formData);
  }

  update(id: number, order: CustomerOrderRequestModel, image?: File): Observable<CustomerOrderResponseModel> {
    const formData = new FormData();
    formData.append('order', new Blob([JSON.stringify(order)], { type: 'application/json' }));
    if (image) {
      formData.append('image', image);
    }
    return this.http.put<CustomerOrderResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  updateStatus(id: number, status: string): Observable<CustomerOrderResponseModel> {
    return this.http.patch<CustomerOrderResponseModel>(`${this.apiUrl}/${id}/status`, null, {
      params: { status: status }
    });
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }

  trackOrder(orderNumber: string): Observable<CustomerOrderResponseModel> {
    return this.http.get<CustomerOrderResponseModel>(`${this.apiUrl}/track`, {
      params: { orderNumber: orderNumber }
    });
  }

  verifyPaymentLink(orderId: number, amountPaid: number, method: string): Observable<string> {
    return this.http.get(`${this.apiUrl}/verify-link`, {
      params: { orderId: orderId, amountPaid: amountPaid, method: method },
      responseType: 'text'
    });
  }
}
