import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment'; // স্পেলিং প্রজেক্ট অনুযায়ী
import { HttpClient } from '@angular/common/http';
import { DriverRequestModel, DriverResponseModel } from '../component/shared/model/driverModel';

@Injectable({
  providedIn: 'root',
})
export class DriverService {
  private apiUrl = environment.apiUrl + 'drivers';

  constructor(private http: HttpClient) {}

  findAll(): Observable<DriverResponseModel[]> {
    return this.http.get<DriverResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<DriverResponseModel> {
    return this.http.get<DriverResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(driver: DriverRequestModel, file: File | null): Observable<DriverResponseModel> {
    const formData = new FormData();

    formData.append('driver', new Blob([JSON.stringify(driver)], { type: 'application/json' }));

    if (file) {
      formData.append('image', file);
    }

    return this.http.post<DriverResponseModel>(this.apiUrl, formData);
  }

  update(
    id: number,
    driver: DriverRequestModel,
    file: File | null,
  ): Observable<DriverResponseModel> {
    const formData = new FormData();

    formData.append('driver', new Blob([JSON.stringify(driver)], { type: 'application/json' }));

    if (file) {
      formData.append('file', file);
    }

    return this.http.put<DriverResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  getDriverByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }
}
