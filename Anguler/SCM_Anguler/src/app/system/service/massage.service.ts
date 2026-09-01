import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { StorageService } from '../../auth/auth_service/storage.service';
import { environment } from '../../../environment/environment';
import { MessageRequestModel, MessageResponseModel } from '../massageModel';

@Injectable({
  providedIn: 'root',
})
export class MessageService {
  private apiUrl = environment.apiUrl + 'messages';

  constructor(
    private http: HttpClient,
    private storage: StorageService,
  ) {}

  private getHeaders(): HttpHeaders {
    const userId = this.storage.getUser()?.userId?.toString() ?? '';
    return new HttpHeaders().set('X-User-Id', userId);
  }

  private validateHeaders(): HttpHeaders | null {
    const headers = this.getHeaders();
    if (!headers.get('X-User-Id')) {
      console.warn('SCM Warning: User context missing. Aborting message request.');
      return null;
    }
    return headers;
  }

  getInbox(): Observable<MessageResponseModel[]> {
    const headers = this.validateHeaders();
    if (!headers) return new Observable<MessageResponseModel[]>(obs => obs.next([]));
    return this.http.get<MessageResponseModel[]>(`${this.apiUrl}/inbox`, { headers });
  }

  getChatlist(): Observable<any[]> {
    const headers = this.validateHeaders();
    if (!headers) return new Observable<any[]>(obs => obs.next([]));
    return this.http.get<any[]>(`${this.apiUrl}/chatlist`, { headers });
  }

  getChatHistory(contactId: string): Observable<MessageResponseModel[]> {
    const headers = this.validateHeaders();
    if (!headers) return new Observable<MessageResponseModel[]>(obs => obs.next([]));
    return this.http.get<MessageResponseModel[]>(`${this.apiUrl}/history`, {
      headers,
      params: { contactId }
    });
  }

  send(message: MessageRequestModel): Observable<MessageResponseModel[]> {
    const headers = this.validateHeaders();
    if (!headers) return new Observable<MessageResponseModel[]>(obs => obs.next([]));
    return this.http.post<MessageResponseModel[]>(this.apiUrl, message, { headers });
  }

  markAsRead(id: number): Observable<void> {
    const headers = this.validateHeaders();
    if (!headers) return new Observable<void>(obs => obs.next());
    return this.http.patch<void>(`${this.apiUrl}/${id}/read`, {}, { headers });
  }
}
