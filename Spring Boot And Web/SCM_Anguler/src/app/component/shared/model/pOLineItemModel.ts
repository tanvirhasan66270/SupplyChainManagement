
export interface POLineItemRequestDTO {
  poId: number;
  productId: number;
  quantity: number;
  unitPrice: number;
  quotationRef: string;
  poNumber: string;
  deliveryDate: string; // YYYY-MM-DD
  shipmentMethod: string;
  notes: string;
  status:  'PENDING' | 'APPROVED' | 'SHIPPED' | 'DELIVERED' | 'CANCELLED' | string;
}

export interface POLineItemResponseDTO {
  id: number;
  poId: number;
  productId: number;
  productName: string;
  productCode: string;
  supplierId:string;
  supplierName:string;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
  totalAmount: number;
  quotationRef: string;
  poNumber: string;
  deliveryDate: string;
  shipmentMethod: string;
  trackingNumber: string;
  notes: string;
  status:  'PENDING' | 'APPROVED' | 'SHIPPED' | 'DELIVERED' | 'CANCELLED' | string;
  createdAt: string;
}
