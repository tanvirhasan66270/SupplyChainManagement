
export interface GRNLineItemRequestModel {
  id?: number;
  grnId?: number;
  productId: number;
  quantityOrdered: number;
  quantityReceived: number;
}


export interface GRNLineItemResponseModel {
  id: number;
  quantityOrdered: number;
  quantityReceived: number;
  grnId: number;
  grnNumber: string;
  productId: number;
  productName: string;
}


export interface GoodsReceivedNoteRequestModel {
  poId: number;
  productId: number | null;
  receivedQuantity: number;
  receivedBy: number;
  warehouseId: number;
  receivedAt: string; 
  status: 'PENDING' | 'RECEIVED' | 'APPROVED' | 'REJECTED' | string;
  remarks: string;
  inspectedBy?: number | null; 
  inspectionDate?: string | null;
  lineItems: GRNLineItemRequestModel[]; 
}

export interface GoodsReceivedNoteResponseModel {
  id: number;
  grnNumber: string;
  quantity: number;
  receivedQuantity: number;
  receivedAt: string; 
  status: 'PENDING' | 'RECEIVED' | 'APPROVED' | 'REJECTED' | string;
  remarks: string;
  inspectionDate: string | null;
  createdAt: string;
  updatedAt: string;
  poId: number;
  poNumber: string;
  productId: number;
  productName: string;
  warehouseId: number;
  warehouseName: string;
  receivedBy: number;
  receivedByName: string;
  inspectedBy: number | null;
  inspectedByName: string | null;
  lineItems?: GRNLineItemResponseModel[];
}
