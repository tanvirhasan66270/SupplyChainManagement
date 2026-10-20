import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';

@Injectable({
  providedIn: 'root',
})
export class QcInspectorService {
  private apiUrl = environment.apiUrl + 'qc-inspectors';

  constructor(private http: HttpClient) {}

  findAll(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl);
  }

  getById(id: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/${id}`);
  }

  save(inspector: any, file: File | null): Observable<any> {
    const formData = new FormData();
    formData.append(
      'qcInspector',
      new Blob([JSON.stringify(inspector)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('image', file);
    }
    return this.http.post<any>(this.apiUrl, formData);
  }

  update(id: number, inspector: any, file: File | null): Observable<any> {
    const formData = new FormData();
    formData.append(
      'qcInspector',
      new Blob([JSON.stringify(inspector)], { type: 'application/json' }),
    );
    if (file) {
      formData.append('image', file);
    }
    return this.http.put<any>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }

  getQcInspectorByUserId(userId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/user/${userId}`);
  }
}
