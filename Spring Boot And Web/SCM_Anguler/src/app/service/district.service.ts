import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { catchError, Observable, throwError } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  DistrictRequestModel,
  DistrictResponseModel,
} from '../component/shared/model/districtModel';

@Injectable({
  providedIn: 'root',
})
export class DistrictService {
  private apiUrl = environment.apiUrl + 'district/';

  constructor(private http: HttpClient) {}

  getAll(): Observable<DistrictResponseModel[]> {
    return this.http.get<DistrictResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<DistrictResponseModel> {
    return this.http.get<DistrictResponseModel>(`${this.apiUrl}${id}`);
  }

  save(district: DistrictRequestModel): Observable<DistrictResponseModel> {
    return this.http.post<DistrictResponseModel>(this.apiUrl, district);
  }

  update(id: number, district: DistrictRequestModel): Observable<DistrictResponseModel> {
    return this.http.put<DistrictResponseModel>(`${this.apiUrl}${id}`, district);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}${id}`, { responseType: 'text' });
  }

  getByDivisionId(id: number): Observable<any[]> {
    const normalizedId = Number(id);
    const primaryUrl = `${this.apiUrl}division/${normalizedId}`;
    const fallbackUrl = `${this.apiUrl}/by-division/${normalizedId}`;
    const legacyUrl = `${this.apiUrl}/${normalizedId}`;

    return this.http.get<any[]>(primaryUrl).pipe(
      catchError((error) => {
        if (error.status === 404) {
          return this.http
            .get<any[]>(fallbackUrl)
            .pipe(catchError(() => this.http.get<any[]>(legacyUrl)));
        }
        return throwError(() => error);
      }),
    );
  }
}
