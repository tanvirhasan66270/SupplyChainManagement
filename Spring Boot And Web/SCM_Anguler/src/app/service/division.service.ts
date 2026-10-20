import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  DivisionRequestModel,
  DivisionResponseModel,
} from '../component/shared/model/divisionModel';
@Injectable({
  providedIn: 'root',
})
export class DivisionService {
  private apiUrl = environment.apiUrl + 'division/';

  constructor(private http: HttpClient) {}

  getAll(): Observable<DivisionResponseModel[]> {
    return this.http.get<DivisionResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<DivisionResponseModel> {
    return this.http.get<DivisionResponseModel>(`${this.apiUrl}${id}`);
  }

  save(division: DivisionRequestModel): Observable<DivisionResponseModel> {
    return this.http.post<DivisionResponseModel>(this.apiUrl, division);
  }

  update(id: number, division: DivisionRequestModel): Observable<DivisionResponseModel> {
    return this.http.put<DivisionResponseModel>(`${this.apiUrl}${id}`, division);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}${id}`, { responseType: 'text' });
  }

  getByCountryId(id: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}country/${id}`);
  }
}
