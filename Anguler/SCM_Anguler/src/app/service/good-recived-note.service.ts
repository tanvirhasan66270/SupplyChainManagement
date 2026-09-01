import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { GoodsReceivedNoteRequestModel, GoodsReceivedNoteResponseModel } from '../component/shared/model/goodRecivedNoteModel';

@Injectable({
  providedIn: 'root',
})
export class GoodRecivedNoteService {
  private apiUrl = environment.apiUrl + "goods-received-notes"; // Sync with @RequestMapping("/api/goods-received-notes")

  constructor(private http: HttpClient) { }

  findAll(): Observable<GoodsReceivedNoteResponseModel[]> {
    return this.http.get<GoodsReceivedNoteResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<GoodsReceivedNoteResponseModel> {
    return this.http.get<GoodsReceivedNoteResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(grn: GoodsReceivedNoteRequestModel): Observable<GoodsReceivedNoteResponseModel> {
    return this.http.post<GoodsReceivedNoteResponseModel>(this.apiUrl, grn);
  }

  update(id: number, grn: GoodsReceivedNoteRequestModel): Observable<GoodsReceivedNoteResponseModel> {
    return this.http.put<GoodsReceivedNoteResponseModel>(`${this.apiUrl}/${id}`, grn);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
