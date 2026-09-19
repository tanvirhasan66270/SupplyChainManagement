

export interface InvoiceRequestModel {
  customerOrderId?: number | null;
  salesOfficerId?: number | null;
  subtotal: number;
  taxRate: number;
  discountAmount: number;
  discountPercentage: number;
  shippingFees: number;
  paidAmount: number;
  paymentMethod?: 'CASH' | 'BANK' | 'BKASH' | 'NAGAD' | 'ROCKET' | string | null;
  transactionReference?: string | null;
  invoiceStatus: 'DRAFT' | 'ISSUED' | 'CANCELLED' | string; 
  deliveryDate?: string | null;     
  deliveryAddress: string;
  notes?: string | null;
  cancelledReason?: string | null;
}


export interface InvoiceResponseModel {
  id: number;
  invoiceNumber: string;
  customerOrderId?: number | null;
  customerEmail: string; 
  salesOfficerId?: number | null;
  issuedToName: string;
  currency: string;     
  
  subtotal: number;
  taxRate: number;
  taxAmount: number;
  discountAmount: number;
  discountPercentage: number;
  shippingFees: number;
  totalAmount: number;
  paidAmount: number;
  dueAmount: number;
  
  paymentStatus: 'UNPAID' | 'PARTIALLY_PAID' | 'PAID' | 'REFUNDED' | string;
  paymentMethod?:'CASH' | 'BANK' | 'BKASH' | 'NAGAD' | 'ROCKET' | string | null;
  transactionReference?: string | null;
  invoiceStatus: 'DRAFT' | 'ISSUED' | 'CANCELLED' | string;
  
  deliveryDate?: string | null; // "YYYY-MM-DD"
  deliveryAddress: string;
  notes?: string | null;
  cancelledReason?: string | null;
  
  issuedAt?: string | null;
  createdAt: string;
  updatedAt: string;
  cancelledAt?: string | null;
}
