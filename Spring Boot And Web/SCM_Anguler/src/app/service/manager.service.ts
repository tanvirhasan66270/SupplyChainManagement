import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment'; 
import { ManagerRequestModel, ManagerResponseModel } from '../component/shared/model/manager';

@Injectable({
  providedIn: 'root',
})
export class ManagerService {
  private apiUrl = environment.apiUrl + "managers";

  constructor(private http: HttpClient) { }

  findAll(): Observable<ManagerResponseModel[]> {
    return this.http.get<ManagerResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<ManagerResponseModel> {
    return this.http.get<ManagerResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(manager: ManagerRequestModel, file: File | null): Observable<ManagerResponseModel> {
    const formData = new FormData();
    
    formData.append(
      "manager",
      new Blob([JSON.stringify(manager)], { type: "application/json" })
    );

    if (file) {
      formData.append("file", file); 
    }

    return this.http.post<ManagerResponseModel>(this.apiUrl, formData);
  }

  update(id: number, manager: ManagerRequestModel, file: File | null): Observable<ManagerResponseModel> {
    const formData = new FormData();
    
    formData.append(
      "manager",
      new Blob([JSON.stringify(manager)], { type: "application/json" })
    );

    if (file) {
      formData.append("file", file);
    }

    return this.http.put<ManagerResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }



    /** Fetch the agent entity whose linked user matches the given userId. */
  getManagerByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }

  
}
