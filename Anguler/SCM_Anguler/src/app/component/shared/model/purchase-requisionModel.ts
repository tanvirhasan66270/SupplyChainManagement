
export interface purchaseRequisitionRequestModel {
  requestedBy: number;
  productIds: number[];
  supplierIds: number[];
  currency: string;
  quantityRequired: number;
  urgencyLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'; // Java UrgencyLevel Enum
  requiredByDate: string; // Format: YYYY-MM-DD
  remarks: string;
}


export interface purchaseRequisitionResponseModel {
  id: number;
  requestedBy: number;
  currency: string;
  quantityRequired: number;
  urgencyLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'; // Java UrgencyLevel Enum
  requiredByDate: string; // Jackson কাস্টিং ডেটা (YYYY-MM-DD)
  approvalStatus: 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED'; // Java PurchaseRequisitionStatus Enum
  approvedBy: number | null; 
  approvedByName: string | null;
  remarks: string | null;
  createdAt: string; // ISO String format
  
  productIds: number[];
  productNames: string[];
  supplierIds: number[];
  supplierNames: string[];
}