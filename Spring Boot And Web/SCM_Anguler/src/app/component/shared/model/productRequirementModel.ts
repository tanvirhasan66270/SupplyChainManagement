
export interface ProductRequirementRequest {
  customerOrderNumber: string;
  productName: string;
  description: string;
  requestedQuantity: number;
  unit: string;
  targetPriceRange: string;
  urgencyLevel: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'PROCESSING'| string;
  requestedByOfficerId: number | null;
  requestedByOfficerName: string;
  procurementRemarks: string;
}

export interface ProductRequirementResponse {
  id: number;
  requestReferenceNo: string;
  customerOrderNumber: string;
  productName: string;
  description: string;
  requestedQuantity: number;
  unit: string;
  targetPriceRange: string;
  urgencyLevel: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'PROCESSING'| string;
  requestedByOfficerId: number;
  requestedByOfficerName: string;
  procurementRemarks: string;
  createdAt: string;
}
