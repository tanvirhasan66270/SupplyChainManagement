import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { purchaseRequisitionRequestModel, purchaseRequisitionResponseModel } from '../component/shared/model/purchase-requisionModel';
import { StorageService } from '../auth/auth_service/storage.service';

@Injectable({
  providedIn: 'root',
})
export class PurchaseRequisitionService {
  private apiUrl = environment.apiUrl + "purchase-requisitions";

  constructor(
    private http: HttpClient,
    private storage: StorageService
  ) { }

  
  private getAuthHeaders(): HttpHeaders {
    const token = this.storage.getToken() ?? '';
    const userId = this.storage.getUser()?.userId?.toString() ?? '';
    
    return new HttpHeaders()
      .set('Authorization', `Bearer ${token}`)
      .set('X-User-Id', userId);
  }

  findAll(): Observable<purchaseRequisitionResponseModel[]> {
    return this.http.get<purchaseRequisitionResponseModel[]>(this.apiUrl, { 
      headers: this.getAuthHeaders() 
    });
  }

  getById(id: number): Observable<purchaseRequisitionResponseModel> {
    return this.http.get<purchaseRequisitionResponseModel>(`${this.apiUrl}/${id}`, { 
      headers: this.getAuthHeaders() 
    });
  }

  save(requisition: purchaseRequisitionRequestModel): Observable<purchaseRequisitionResponseModel> {
    return this.http.post<purchaseRequisitionResponseModel>(this.apiUrl, requisition, { 
      headers: this.getAuthHeaders() 
    });
  }

  update(id: number, requisition: purchaseRequisitionRequestModel): Observable<purchaseRequisitionResponseModel> {
    return this.http.put<purchaseRequisitionResponseModel>(`${this.apiUrl}/${id}`, requisition, { 
      headers: this.getAuthHeaders() 
    });
  }

  approve(id: number): Observable<purchaseRequisitionResponseModel> {
    return this.http.put<purchaseRequisitionResponseModel>(`${this.apiUrl}/${id}/approve`, {}, { 
      headers: this.getAuthHeaders() 
    });
  }

  rejectOrCancel(id: number, actionType: 'REJECT' | 'CANCEL'): Observable<purchaseRequisitionResponseModel> {
    return this.http.put<purchaseRequisitionResponseModel>(`${this.apiUrl}/${id}/reject-or-cancel`, {}, {
      headers: this.getAuthHeaders(),
      params: { actionType: actionType }
    });
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`, { 
      headers: this.getAuthHeaders() 
    });
  }
}