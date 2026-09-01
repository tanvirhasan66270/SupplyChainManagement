export interface AdminRequest {
  name: string;
  email: string;
  phone?: string;
  password?: string;
}

export interface AdminResponse {
  id: number;
  name: string;
  phone?: string;
  email: string;
  userId?: number;
  phoneNumber?: string;
  active: boolean;
  role: string;
}