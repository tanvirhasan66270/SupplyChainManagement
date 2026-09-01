import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { CommercialOfficerRequestModel, CommercialOfficerResponseModel } from '../component/shared/model/commercialOfficer';

@Injectable({
  providedIn: 'root',
})
export class CommercialOfficerService {
  private apiUrl = environment.apiUrl + "commercial-officer";

  constructor(private http: HttpClient) { }

  findAll(): Observable<CommercialOfficerResponseModel[]> {
    return this.http.get<CommercialOfficerResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<CommercialOfficerResponseModel> {
    return this.http.get<CommercialOfficerResponseModel>(`${this.apiUrl}/${id}`);
  }

  getCommercialOfficerByUserId(userId: number): Observable<CommercialOfficerResponseModel> {
    return this.http.get<CommercialOfficerResponseModel>(`${this.apiUrl}/user/${userId}`);
  }

  save(officer: CommercialOfficerRequestModel, file: File | null): Observable<CommercialOfficerResponseModel> {
    const formData = new FormData();
    
    // কন্ট্রোলারের String টাইপ রিকোয়েস্ট পার্টের জন্য সরাসরি স্ট্রিংফাই করে পাঠানো হলো
    formData.append("commercialOfficer", JSON.stringify(officer));

    if (file) {
      formData.append("file", file);
    }

    return this.http.post<CommercialOfficerResponseModel>(this.apiUrl, formData);
  }

  update(id: number, officer: CommercialOfficerRequestModel, file: File | null): Observable<CommercialOfficerResponseModel> {
    const formData = new FormData();
    
    // কন্ট্রোলারের String টাইপ রিকোয়েস্ট পার্টের জন্য সরাসরি স্ট্রিংফাই করে পাঠানো হলো
    formData.append("officer", JSON.stringify(officer));

    if (file) {
      formData.append("file", file);
    }

    return this.http.put<CommercialOfficerResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  

 
}