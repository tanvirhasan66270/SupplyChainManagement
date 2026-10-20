import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { catchError, Observable, throwError } from 'rxjs';
import { environment } from '../../environment/environment';
import {
  PoliceStationRequestModel,
  PoliceStationResponseModel,
} from '../component/shared/model/policeStationModel';

@Injectable({
  providedIn: 'root',
})
export class PoliceStationService {
  private apiUrl = environment.apiUrl + 'policestation/';

  constructor(private http: HttpClient) {}

  getAll(): Observable<PoliceStationResponseModel[]> {
    return this.http.get<PoliceStationResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<PoliceStationResponseModel> {
    return this.http.get<PoliceStationResponseModel>(`${this.apiUrl}${id}`);
  }

  save(station: PoliceStationRequestModel): Observable<PoliceStationResponseModel> {
    return this.http.post<PoliceStationResponseModel>(this.apiUrl, station);
  }

  update(id: number, station: PoliceStationRequestModel): Observable<PoliceStationResponseModel> {
    return this.http.put<PoliceStationResponseModel>(`${this.apiUrl}${id}`, station);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}${id}`, { responseType: 'text' });
  }
  getByDistrictId(id: number): Observable<any[]> {
    const normalizedId = Number(id);
    const primaryUrl = `${this.apiUrl}district/${normalizedId}`;
    const fallbackUrl = `${this.apiUrl}/by-district/${normalizedId}`;
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

  search(keyword: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/search?keyword=${keyword}`);
  }
}
