

export interface PaymentStatementRequest {
  customerOrderId: number;
  paidAmount: number;
  paymentMethod: 'CASH' | 'BANK' | 'BKASH' | 'NAGAD' | 'ROCKET' | string;
  issueStatus?: 'PENDING_VERIFICATION' | 'CONFIRMED_BY_OFFICER' | 'FAILED_OR_REJECTED' | string;
  transactionId?: string;
  customerAccountNumber?: string;
  paymentCheckImage?: string;
}

export interface PaymentStatementResponse {
  id: number;
  paidAmount: number;
  oldPaidAmount: number;
  paymentMethod: 'CASH' | 'BANK' | 'BKASH' | 'NAGAD' | 'ROCKET' | string;
  issueStatus: 'PENDING_VERIFICATION' | 'CONFIRMED_BY_OFFICER' | 'FAILED_OR_REJECTED' | string;
  transactionId: string;
  customerAccountNumber?: string;
  paymentCheckImage: string;
  createdAt: string;
  updatedAt: string;
  customerOrderId: number;
  orderNumber: string;
}