export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  tokenType: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: 'ADMIN' | 'MANAGER' | 'DRIVER' | 'PROCUREMENT'|'QC_INSPECTOR' | 'LOGISTICS_OFFICER' | 'COMMERCIAL_OFFICER' | 'CUSTOMER'| 'SUPPLIER' | 'SALES_OFFICER';
  hubId?: number;
  hubName?: string;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface ResetPasswordRequest {
  token: string;
  newPassword: string;
}
