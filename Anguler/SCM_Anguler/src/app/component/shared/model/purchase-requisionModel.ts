
export interface purchaseRequisitionRequestModel {
  requestedBy: number;
  productIds: number[];
  supplierIds: number[];
  currency: string;
  quantityRequired: number;
  urgencyLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'; 
  requiredByDate: string; 
  remarks: string;
}


export interface purchaseRequisitionResponseModel {
  id: number;
  requestedBy: number;
  currency: string;
  quantityRequired: number;
  urgencyLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'; 
  requiredByDate: string; 
  approvalStatus: 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED';
  approvedBy: number | null; 
  approvedByName: string | null;
  remarks: string | null;
  createdAt: string; 
  
  productIds: number[];
  productNames: string[];
  supplierIds: number[];
  supplierNames: string[];
}