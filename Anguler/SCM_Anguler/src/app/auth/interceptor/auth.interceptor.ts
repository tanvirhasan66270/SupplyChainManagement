import { HttpInterceptorFn } from "@angular/common/http";
import { inject } from "@angular/core";
import { StorageService } from "../auth_service/storage.service";

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  
  const storage = inject(StorageService);
  let token = storage.getToken();
  
  if (!token) {
    token = localStorage.getItem('token') || localStorage.getItem('JWT_TOKEN') || '';
  }

  if (token && typeof token === 'object') {
    token = (token as any).token || (token as any).accessToken || '';
  }

  console.log(`[Interceptor Log] Target URL: ${req.url} | Token Found:`, token ? "YES (Valid String)" : "NO (Empty/Null)");

  if (token) {
    req = req.clone({
      setHeaders: { 
        Authorization: `Bearer ${token.trim()}` 
      }
    });
  }

  return next(req);
};