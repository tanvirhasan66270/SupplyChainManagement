export interface QuotationRequestModel {
  supplierId: number;
  purchaseRequisitionId: number;
  leadTimeDays: number;
  receivedAt: string;        // YYYY-MM-DD
  status: 'PENDING' | 'UNDER_REVIEW' | 'APPROVED' | 'REJECTED' | 'EXPIRED';
  productDescription: string;
  unitPrice: number;
  quantity: number;
  deliveryTime: string;      // YYYY-MM-DD
  warranty: string;
  notes: string;
  attachmentUrl?: string;
}

export interface QuotationResponseModel {
  id: number;
  quotationNumber: string;
  validUntil: string;
  leadTimeDays: number;
  receivedAt: string;
  status: 'PENDING' | 'UNDER_REVIEW' | 'APPROVED' | 'REJECTED' | 'EXPIRED';
  productDescription: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  deliveryTime: string;
  warranty: string;
  notes: string;
  attachmentUrl: string;
  createdAt: string;
  supplierId: number;
  supplierName: string;
   supplierEmail: string;
  
  productIds: number;
  productName: string;
  purchaseRequisitionId: number;
}