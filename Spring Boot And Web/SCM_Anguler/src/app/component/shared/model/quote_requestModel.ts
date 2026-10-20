export interface QuoteRequestModel {
  id?: number;
  companyName: string;
  contactName: string;
  email: string;
  phone: string;
  requestType: string; // 'BUYER' | 'SUPPLIER' | 'LOGISTICS'
  productDetails: string;
  createdAt?: string;
}