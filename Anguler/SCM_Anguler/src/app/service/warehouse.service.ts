import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { WarehouseRequestModel, WarehouseResponseModel } from '../component/shared/model/warehouse';

@Injectable({
  providedIn: 'root',
})
export class WarehouseService {
  private apiUrl = environment.apiUrl + "warehouse";

  constructor(private http: HttpClient) { }

  getAll(): Observable<WarehouseResponseModel[]> {
    return this.http.get<WarehouseResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<WarehouseResponseModel> {
    return this.http.get<WarehouseResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(warehouse: WarehouseRequestModel): Observable<WarehouseResponseModel> {
    return this.http.post<WarehouseResponseModel>(this.apiUrl, warehouse);
  }

  update(id: number, warehouse: WarehouseRequestModel): Observable<WarehouseResponseModel> {
    return this.http.put<WarehouseResponseModel>(`${this.apiUrl}/${id}`, warehouse);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
