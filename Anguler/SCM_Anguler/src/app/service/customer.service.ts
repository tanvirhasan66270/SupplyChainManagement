import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { CustomerResponseModel } from '../component/shared/model/customerModel';

@Injectable({
  providedIn: 'root',
})
export class CustomerService {
  private apiUrl = environment.apiUrl + 'customer';

  constructor(private http: HttpClient) {}

  getAll(): Observable<CustomerResponseModel[]> {
    return this.http.get<CustomerResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<CustomerResponseModel> {
    return this.http.get<CustomerResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(formData: FormData): Observable<CustomerResponseModel> {
    return this.http.post<CustomerResponseModel>(this.apiUrl, formData);
  }

  update(id: number, formData: FormData): Observable<CustomerResponseModel> {
    return this.http.put<CustomerResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }

  getCustomerByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }
}