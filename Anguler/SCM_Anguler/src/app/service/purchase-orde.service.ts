import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { PurchaseOrderRequestModel, PurchaseOrderResponseModel } from '../component/shared/model/purchaseOrderModel';
import { StorageService } from '../auth/auth_service/storage.service'; 

@Injectable({
  providedIn: 'root',
})
export class PurchaseOrderService {
  private apiUrl = environment.apiUrl + "purchase-orders";

  constructor(
    private http: HttpClient,
    private storage: StorageService 
  ) { }

 
  private getAuthHeaders(): HttpHeaders {
    const token = this.storage.getToken() ?? '';
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  
  findAll(): Observable<PurchaseOrderResponseModel[]> {
    return this.http.get<PurchaseOrderResponseModel[]>(this.apiUrl, {
      headers: this.getAuthHeaders()
    });
  }

 
  getById(id: number): Observable<PurchaseOrderResponseModel> {
    return this.http.get<PurchaseOrderResponseModel>(`${this.apiUrl}/${id}`, {
      headers: this.getAuthHeaders()
    });
  }


  save(order: PurchaseOrderRequestModel): Observable<PurchaseOrderResponseModel> {
    return this.http.post<PurchaseOrderResponseModel>(this.apiUrl, order, {
      headers: this.getAuthHeaders()
    });
  }

  update(id: number, order: PurchaseOrderRequestModel): Observable<PurchaseOrderResponseModel> {
    return this.http.put<PurchaseOrderResponseModel>(`${this.apiUrl}/${id}`, order, {
      headers: this.getAuthHeaders()
    });
  }


  approve(id: number): Observable<PurchaseOrderResponseModel> {
    return this.http.put<PurchaseOrderResponseModel>(`${this.apiUrl}/${id}/approve`, {}, {
      headers: this.getAuthHeaders()
    });
  }

 
  changeStatus(id: number, status: 'RECEIVED' | 'CANCELLED'): Observable<PurchaseOrderResponseModel> {
    return this.http.put<PurchaseOrderResponseModel>(
      `${this.apiUrl}/${id}/status`, 
      {}, 
      { 
        headers: this.getAuthHeaders(), // ইন্টারসেপ্টর ব্যাকআপ হিসেবে হেডার যুক্ত রাখা সেফ
        params: { status: status } 
      }
    );
  }


  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, {
      headers: this.getAuthHeaders(),
      responseType: 'text'
    });
  }

 
  getOrdersBySupplierId(supplierId: number): Observable<PurchaseOrderResponseModel[]> {
    return this.http.get<PurchaseOrderResponseModel[]>(`${this.apiUrl}/supplier/${supplierId}`, {
      headers: this.getAuthHeaders()
    });
  }
}