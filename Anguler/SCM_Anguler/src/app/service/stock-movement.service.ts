import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  StockMovementRequestModel,
  StockMovementResponseModel,
} from '../component/shared/model/stock-movement';

@Injectable({
  providedIn: 'root',
})
export class StockMovementService {
  private apiUrl = environment.apiUrl + 'stock-movements';

  constructor(private http: HttpClient) {}

  findAll(): Observable<StockMovementResponseModel[]> {
    return this.http.get<StockMovementResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<StockMovementResponseModel> {
    return this.http.get<StockMovementResponseModel>(`${this.apiUrl}/${id}`);
  }

  logMovement(movement: StockMovementRequestModel): Observable<StockMovementResponseModel> {
    return this.http.post<StockMovementResponseModel>(this.apiUrl, movement);
  }

  update(id: number, movement: StockMovementRequestModel): Observable<StockMovementResponseModel> {
    return this.http.put<StockMovementResponseModel>(`${this.apiUrl}/${id}`, movement);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
