import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environment/environment';
import { CategoryRequestModel, CategoryResponseModel } from '../component/shared/model/category';

@Injectable({
  providedIn: 'root',
})
export class CategoryService {
  private apiUrl = environment.apiUrl + "category";

  constructor(private http: HttpClient) { }

  getAll(): Observable<CategoryResponseModel[]> {
    return this.http.get<CategoryResponseModel[]>(this.apiUrl);
  }

  getById(id: number): Observable<CategoryResponseModel> {
    return this.http.get<CategoryResponseModel>(`${this.apiUrl}/${id}`);
  }

  save(category: CategoryRequestModel): Observable<CategoryResponseModel> {
    return this.http.post<CategoryResponseModel>(this.apiUrl, category);
  }

  update(id: number, category: CategoryRequestModel): Observable<CategoryResponseModel> {
    return this.http.put<CategoryResponseModel>(`${this.apiUrl}/${id}`, category);
  }

  delete(id: number): Observable<string> {
    return this.http.delete(`${this.apiUrl}/${id}`, { responseType: 'text' });
  }
}
