import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { LCBankRequestModel, LCBankResponseModel } from '../component/shared/model/lcbankModel';

@Injectable({
  providedIn: 'root',
})
export class LcbankService {
  private apiUrl = environment.apiUrl + "banks"; // Sync with @RequestMapping("/api/banks")

  constructor(private http: HttpClient) { }

  findAll(): Observable<LCBankResponseModel[]> {
    return this.http.get<LCBankResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<LCBankResponseModel> {
    return this.http.get<LCBankResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(bank: LCBankRequestModel): Observable<LCBankResponseModel> {
    return this.http.post<LCBankResponseModel>(this.apiUrl, bank);
  }

  update(id: number, bank: LCBankRequestModel): Observable<LCBankResponseModel> {
    return this.http.put<LCBankResponseModel>(`${this.apiUrl}/${id}`, bank);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
