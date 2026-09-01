

export interface PurchaseOrderRequestModel {
  quotationId: number;
  issuedBy: number;
  issuedByName?: string;
  totalAmount: number;
  quantity: number; // এটি যোগ করুন
  currency: string;
  expectedDeliveryDate: string;
  status: string;
  poNumber?: string;
  supplierName?: string;
  supplierEmail?: string;
  purchaseRequisitionId?: number;
  createdAt?: string;
}

export interface PurchaseOrderResponseModel {
  id: number;
  poNumber: string;
  quantity: number;
  totalAmount: number;
  currency: string;
  expectedDeliveryDate: string;
  status: 'DRAFT' | 'ISSUED' | 'PARTIALLY_RECEIVED' | 'RECEIVED' | 'CANCELLED' | string;
  issuedBy: number;
  createdAt: string;
  updatedAt: string;
  supplierId: number;
  supplierName: string;
  supplierEmail: string;
  purchaseRequisitionId: number;
  quotationId: number;
}
