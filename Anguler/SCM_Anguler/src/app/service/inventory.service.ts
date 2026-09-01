import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { InventoryRequestModel, InventoryResponseModel } from '../component/shared/model/inventoryModel';

@Injectable({
  providedIn: 'root',
})
export class InventoryService {
  private apiUrl = environment.apiUrl + "inventories"; // Sync with @RequestMapping("/api/inventories")

  constructor(private http: HttpClient) { }

  findAll(): Observable<InventoryResponseModel[]> {
    return this.http.get<InventoryResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<InventoryResponseModel> {
    return this.http.get<InventoryResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(inventory: InventoryRequestModel): Observable<InventoryResponseModel> {
    return this.http.post<InventoryResponseModel>(this.apiUrl, inventory);
  }

  update(id: number, inventory: InventoryRequestModel): Observable<InventoryResponseModel> {
    return this.http.put<InventoryResponseModel>(`${this.apiUrl}/${id}`, inventory);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
