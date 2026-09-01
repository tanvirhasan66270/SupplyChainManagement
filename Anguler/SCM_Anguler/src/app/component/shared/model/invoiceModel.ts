

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
  invoiceStatus: 'DRAFT' | 'ISSUED' | 'CANCELLED' | string; // DRAFT, ISSUED, CANCELLED
  deliveryDate?: string | null;      // ফ্রন্টএন্ড থেকে "YYYY-MM-DD" ফরম্যাটে স্ট্রিং ইনপুট আসবে
  deliveryAddress: string;
  notes?: string | null;
  cancelledReason?: string | null;
}


export interface InvoiceResponseModel {
  id: number;
  invoiceNumber: string; // অটো-জেনারেটেড ইউনিক ইনভয়েস কোড
  customerOrderId?: number | null;
  customerEmail: string; // অটো-জেনারেটেড ইমেইল ফিল্ড রেসপন্স নোড
  salesOfficerId?: number | null;
  issuedToName: string;
  currency: string;      // যেমন: "BDT"
  
  // Financial Breakdown
  subtotal: number;
  taxRate: number;
  taxAmount: number;
  discountAmount: number;
  discountPercentage: number;
  shippingFees: number;
  totalAmount: number;
  paidAmount: number;
  dueAmount: number;
  
  // Status Matrix (আপনার কাস্টম স্টাইল সিঙ্কড)
  paymentStatus: 'UNPAID' | 'PARTIALLY_PAID' | 'PAID' | 'REFUNDED' | string;
  paymentMethod?:'CASH' | 'BANK' | 'BKASH' | 'NAGAD' | 'ROCKET' | string | null;
  transactionReference?: string | null;
  invoiceStatus: 'DRAFT' | 'ISSUED' | 'CANCELLED' | string;
  
  // Logistics & Logs
  deliveryDate?: string | null; // "YYYY-MM-DD"
  deliveryAddress: string;
  notes?: string | null;
  cancelledReason?: string | null;
  
  // Auditing Timestamps (ISO Date Strings)
  issuedAt?: string | null;
  createdAt: string;
  updatedAt: string;
  cancelledAt?: string | null;
}
