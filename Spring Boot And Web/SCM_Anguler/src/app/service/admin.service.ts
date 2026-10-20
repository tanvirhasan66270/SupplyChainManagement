import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AdminRequest, AdminResponse } from '../component/shared/model/adminModel';
import { environment } from '../../environment/environment';


@Injectable({
  providedIn: 'root',
})
export class AdminService {
  private apiUrl =  environment.apiUrl + "admin"; 

  constructor(private http: HttpClient) {}

  getAllAdmins(): Observable<AdminResponse[]> {
    return this.http.get<AdminResponse[]>(this.apiUrl);
  }

  getAdminById(id: number): Observable<AdminResponse> {
    return this.http.get<AdminResponse>(`${this.apiUrl}/${id}`);
  }

  createAdmin(request: AdminRequest): Observable<AdminResponse> {
    return this.http.post<AdminResponse>(this.apiUrl, request);
  }

  updateAdmin(id: number, request: AdminRequest): Observable<AdminResponse> {
    return this.http.put<AdminResponse>(`${this.apiUrl}/${id}`, request);
  }

  // deleteAdmin(id: number): Observable<void> {
  //   return this.http.delete<void>(`${this.apiUrl}/${id}`);
  // }
}