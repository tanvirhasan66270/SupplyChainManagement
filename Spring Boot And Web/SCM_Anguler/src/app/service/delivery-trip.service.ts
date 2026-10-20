import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { DeliveryTripRequestModel, DeliveryTripResponseModel } from '../component/shared/model/DeliveryTripModel';

@Injectable({
  providedIn: 'root',
})
export class DeliveryTripService {
  private apiUrl = environment.apiUrl + 'delivery-trips';

  constructor(private http: HttpClient) { }

  findAll(): Observable<DeliveryTripResponseModel[]> {
    return this.http.get<DeliveryTripResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<DeliveryTripResponseModel> {
    return this.http.get<DeliveryTripResponseModel>(`${this.apiUrl}/${id}`);
  }

  create(trip: DeliveryTripRequestModel): Observable<DeliveryTripResponseModel> {
    return this.http.post<DeliveryTripResponseModel>(this.apiUrl, trip);
  }

  update(id: number, trip: DeliveryTripRequestModel): Observable<DeliveryTripResponseModel> {
    return this.http.put<DeliveryTripResponseModel>(`${this.apiUrl}/${id}`, trip);
  }

  changeStatus(id: number, status: string, signatureFile?: File | null, photoFile?: File | null): Observable<DeliveryTripResponseModel> {
    const formData = new FormData();
    formData.append('status', status);
    
    if (signatureFile) formData.append('signature', signatureFile);
    if (photoFile) formData.append('photo', photoFile);

    return this.http.patch<DeliveryTripResponseModel>(`${this.apiUrl}/${id}/status`, formData);
  }
  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
