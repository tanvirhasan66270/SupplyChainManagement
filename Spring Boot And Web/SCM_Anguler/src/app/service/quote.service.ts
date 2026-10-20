import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { QuoteRequestModel } from '../component/shared/model/quote_requestModel';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';

@Injectable({
  providedIn: 'root',
})
export class QuoteService {
  private apiUrl = environment.apiUrl + 'quotes/submit';

  constructor(private http: HttpClient) {}

  submitRequest(data: QuoteRequestModel): Observable<QuoteRequestModel> {
    return this.http.post<QuoteRequestModel>(this.apiUrl, data);
  }
}
