import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { LetterOfCreditRequestModel,LetterOfCreditResponseModel } from '../component/shared/model/letterOfCraditModel';

@Injectable({
  providedIn: 'root',
})
export class LetterOfCreditService {
  private apiUrl = environment.apiUrl + "lc";

  constructor(private http: HttpClient) { }

  findAll(): Observable<LetterOfCreditResponseModel[]> {
    
    return this.http.get<LetterOfCreditResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<LetterOfCreditResponseModel> {
    return this.http.get<LetterOfCreditResponseModel>(`${this.apiUrl}/${id}`);
  }

  // 1. Create LC Node (Multipart Form Data)
  save(lcData: LetterOfCreditRequestModel, file: File | null): Observable<LetterOfCreditResponseModel> {
    const formData = new FormData();
    formData.append('lcData', JSON.stringify(lcData)); // Sync @RequestPart("lcData")
    if (file) {
      formData.append('file', file); // Sync @RequestPart("file")
    }
    return this.http.post<LetterOfCreditResponseModel>(this.apiUrl, formData);
  }

  // 2. Update LC Metadata (Multipart Form Data)
  update(id: number, lcData: LetterOfCreditRequestModel, file: File | null): Observable<LetterOfCreditResponseModel> {
    const formData = new FormData();
    formData.append('lcData', JSON.stringify(lcData));
    if (file) {
      formData.append('file', file);
    }
    return this.http.put<LetterOfCreditResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  // 3. Commercial Amendment Gateway (Standard PATCH JSON)
  amendLC(id: number, patchDto: Partial<LetterOfCreditRequestModel>): Observable<LetterOfCreditResponseModel> {
    return this.http.patch<LetterOfCreditResponseModel>(`${this.apiUrl}/amend/${id}`, patchDto);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
