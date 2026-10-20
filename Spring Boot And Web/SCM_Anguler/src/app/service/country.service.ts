import { Injectable } from '@angular/core';
import { environment } from '../../environment/environment';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import {
  CountryRequestModel,
  CountryResponseModel,
} from '../component/shared/model/country/countryModel';

@Injectable({
  providedIn: 'root',
})
export class CountryService {
  private apiUrl = environment.apiUrl + 'country';

  constructor(private http: HttpClient) {}

  getAll(): Observable<CountryResponseModel[]> {
    return this.http.get<CountryResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<CountryResponseModel> {
    return this.http.get<CountryResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(country: CountryRequestModel): Observable<CountryResponseModel> {
    return this.http.post<CountryResponseModel>(this.apiUrl, country);
  }

  update(id: number, country: CountryRequestModel): Observable<CountryResponseModel> {
    return this.http.put<CountryResponseModel>(`${this.apiUrl}/${id}`, country);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
