import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { ProductRequestModel, ProductResponseModel } from '../component/shared/model/addProduct';

@Injectable({
  providedIn: 'root',
})
export class AddProductService {
  private apiUrl = environment.apiUrl + "products";

  constructor(private http: HttpClient) { }

  findAll(): Observable<ProductResponseModel[]> {
    return this.http.get<ProductResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<ProductResponseModel> {
    return this.http.get<ProductResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(product: ProductRequestModel, file: File | null): Observable<ProductResponseModel> {
    const formData = new FormData();
    // ব্যাকএন্ডের @RequestPart("productJson") ম্যাচ করানোর জন্য JSON Blob তৈরি
    formData.append(
      "productJson",
      new Blob([JSON.stringify(product)], { type: "application/json" })
    );
    if (file) {
      formData.append("image", file); 
    }
    return this.http.post<ProductResponseModel>(this.apiUrl, formData);
  }

  update(id: number, product: ProductRequestModel, file: File | null): Observable<ProductResponseModel> {
    const formData = new FormData();
    formData.append(
      "productJson",
      new Blob([JSON.stringify(product)], { type: "application/json" })
    );
    if (file) {
      formData.append("image", file);
    }
    return this.http.put<ProductResponseModel>(`${this.apiUrl}/${id}`, formData);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
