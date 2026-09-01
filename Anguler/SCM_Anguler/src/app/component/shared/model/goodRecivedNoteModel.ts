
export interface GRNLineItemRequestModel {
  id?: number; // Optional: নতুন আইটেম তৈরির সময় লাগবে না, আপডেটের সময় লাগবে
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
  receivedBy: number; // লগইন করা ইউজারের আইডি
  warehouseId: number;
  receivedAt: string; // Format Pattern: YYYY-MM-DD
  status: 'PENDING' | 'RECEIVED' | 'APPROVED' | 'REJECTED' | string;
  remarks: string;
  inspectedBy?: number | null; // Optional/Nullable
  inspectionDate?: string | null; // Format Pattern: YYYY-MM-DD (Optional)
  lineItems: GRNLineItemRequestModel[]; 
}

export interface GoodsReceivedNoteResponseModel {
  id: number;
  grnNumber: string;
  quantity: number;
  receivedQuantity: number;
  receivedAt: string; // Temporal String Format
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
