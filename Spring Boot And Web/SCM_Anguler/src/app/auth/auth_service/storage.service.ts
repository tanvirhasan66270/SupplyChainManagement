import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { LoginResponse } from '../Model/authModel';
import { CryptoUtil } from '../utils/CryptoUtil';

export const KEYS = {
  TOKEN: 'cm_token',
  USER: 'cm_user',
  ADMIN: 'cm_admin',
  MANAGER: 'cm_manager',
  DRIVER: 'cm_driver',
  PROCUREMENT: 'cm_procurement',
  QC_INSPECTOR: 'cm_qcInspector',
  LOGISTICS_OFFICER: 'cm_logisticsOfficer',
  COMMERCIAL_OFFICER: 'cm_commercialOfficer',
  CUSTOMER: 'cm_customer',
  SUPPLIER: 'cm_supplier',
  SALES_OFFICER: 'cm_salesOfficer',
};

@Injectable({
  providedIn: 'root',
})
export class StorageService {
  private roleSubject = new BehaviorSubject<string>('');

  // ── Write ────────────────────────────────────────────

  saveSession(data: LoginResponse): void {
    localStorage.setItem(KEYS.TOKEN, CryptoUtil.encrypt(data.token));
    localStorage.setItem(KEYS.USER, CryptoUtil.encrypt(JSON.stringify(data)));
  }

  // ── Read ─────────────────────────────────────────────

  getToken(): string | null {
    const raw = localStorage.getItem(KEYS.TOKEN);
    if (!raw) return null;
    const decrypted = CryptoUtil.decrypt(raw);
    return decrypted ? decrypted : raw;
  }

  getUser(): LoginResponse | null {
    const raw = localStorage.getItem(KEYS.USER);
    if (!raw) return null;
    const json = CryptoUtil.decrypt(raw);
    try {
      if (json) {
        return JSON.parse(json);
      }
      return JSON.parse(raw);
    } catch {
      try {
        return JSON.parse(raw);
      } catch {
        return null;
      }
    }
  }

  constructor() {
    this.roleSubject.next(this.getActiveRole());
  }

  role$ = this.roleSubject.asObservable();

  getActiveRole(): string {
    const sim = localStorage.getItem('simulated_role');
    if (sim) return sim;
    return this.getRole() ?? 'CUSTOMER';
  }

  setActiveRole(role: string): void {
    localStorage.setItem('simulated_role', role);
    this.roleSubject.next(role);
  }

  clearSimulatedRole(): void {
    localStorage.removeItem('simulated_role');
    this.roleSubject.next(this.getActiveRole());
  }

  getRole(): string | null {
    return this.getUser()?.role ?? null;
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }

  // ── Clear ─────────────────────────────────────────────

  clearSession(): void {
    Object.values(KEYS).forEach((k) => localStorage.removeItem(k));
  }

  // Generic Method for ALl

  saveData(key: string, data: any): void {
    localStorage.setItem(key, CryptoUtil.encrypt(JSON.stringify(data)));
  }

  getData<T>(key: string): T | null {
    const raw = localStorage.getItem(key);
    if (!raw) return null;

    try {
      const json = CryptoUtil.decrypt(raw);
      if (json) {
        return JSON.parse(json);
      }
      return JSON.parse(raw);
    } catch {
      try {
        return JSON.parse(raw) as T;
      } catch {
        return null;
      }
    }
  }

  removeData(key: string): void {
    localStorage.removeItem(key);
  }
}
