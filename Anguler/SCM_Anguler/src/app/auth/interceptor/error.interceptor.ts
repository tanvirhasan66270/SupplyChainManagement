import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, EMPTY, throwError } from 'rxjs';
import { StorageService } from '../auth_service/storage.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const storage = inject(StorageService);
  const router = inject(Router);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401) {
        storage.clearSession();
        router.navigate(['/login']);
        return EMPTY;
      } else if (error.status === 403) {
        // Just pass the 403 error to the component. Do not redirect globally.
        return throwError(() => error);
      }
      
      return throwError(() => error);
    }),
  );
};
