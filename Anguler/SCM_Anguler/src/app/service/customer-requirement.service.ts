import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CustomerRequirementModel } from '../component/shared/model/CustomerRequirementModel';
import { environment } from '../../environment/environment';

@Injectable({
  providedIn: 'root'
})
export class CustomerRequirementService {

  private apiUrl = `${environment.apiUrl}customer-requirements`;

  constructor(private http: HttpClient) { }

  submitPublicRequirement(requirement: CustomerRequirementModel): Observable<CustomerRequirementModel> {
    return this.http.post<CustomerRequirementModel>(`${this.apiUrl}/public/submit`, requirement);
  }

  getAllRequirements(): Observable<CustomerRequirementModel[]> {
    return this.http.get<CustomerRequirementModel[]>(this.apiUrl);
  }

  getRequirementById(id: number): Observable<CustomerRequirementModel> {
    return this.http.get<CustomerRequirementModel>(`${this.apiUrl}/${id}`);
  }

  updateStatus(id: number, status: string): Observable<CustomerRequirementModel> {
    return this.http.put<CustomerRequirementModel>(`${this.apiUrl}/${id}/status?status=${status}`, {});
  }

  deleteRequirement(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
