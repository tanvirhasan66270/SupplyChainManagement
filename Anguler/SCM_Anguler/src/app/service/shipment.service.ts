import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { ShipmentRequestModel, ShipmentResponseModel } from '../component/shared/model/shipmentModel';

@Injectable({
  providedIn: 'root',
})
export class ShipmentService {
  private apiUrl = environment.apiUrl + "shipments";

  constructor(private http: HttpClient) { }

  findAll(): Observable<ShipmentResponseModel[]> {
    return this.http.get<ShipmentResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<ShipmentResponseModel> {
    return this.http.get<ShipmentResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(shipment: ShipmentRequestModel, file: File | null): Observable<ShipmentResponseModel> {
    const formData = new FormData();
    
    // ব্যাকএন্ড যদি String JSON হিসেবে রিসিভ করে
    formData.append('shipment', JSON.stringify(shipment));
    
    if (file) {
      // ব্যাকএন্ডে যদি @RequestParam("file") অথবা @RequestPart("file") থাকে
      formData.append('file', file);
      // ব্যাকএন্ডের সুবিধার জন্য 'podFile' নামেও অ্যাপেন্ড করে দেওয়া হলো
      formData.append('podFile', file);
    }
    return this.http.post<ShipmentResponseModel>(this.apiUrl, formData);
  }

  update(id: number, shipment: ShipmentRequestModel, file: File | null): Observable<ShipmentResponseModel> {
    const formData = new FormData();
    formData.append('shipment', JSON.stringify(shipment));
    
    if (file) {
      formData.append('file', file);
      formData.append('podFile', file);
    }
    return this.http.put<ShipmentResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}