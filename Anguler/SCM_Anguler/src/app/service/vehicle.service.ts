import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { VehicleRequestModel, VehicleResponseModel } from '../component/shared/model/vehicleModel';

@Injectable({
  providedIn: 'root',
})
export class VehicleService {
  private apiUrl = environment.apiUrl + 'vehicles'; // Synced with @RequestMapping("/api/vehicles")

  constructor(private http: HttpClient) { }

  findAll(): Observable<VehicleResponseModel[]> {
    return this.http.get<VehicleResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<VehicleResponseModel> {
    return this.http.get<VehicleResponseModel>(`${this.apiUrl}/${id}`);
  }

  create(vehicle: VehicleRequestModel): Observable<VehicleResponseModel> {
    return this.http.post<VehicleResponseModel>(this.apiUrl, vehicle);
  }

  update(id: number, vehicle: VehicleRequestModel): Observable<VehicleResponseModel> {
    return this.http.put<VehicleResponseModel>(`${this.apiUrl}/${id}`, vehicle);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
