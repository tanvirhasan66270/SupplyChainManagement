export interface ShipmentRequestModel {
  poId: number;
  supplierId: number;
  vehicleNumber: string;
  captainRegistrationNumber: string;
  assignedByEmail: string;
  origin: string;
  sendByAddress: string;
  estimatedDelivery: string; // YYYY-MM-DD
  transportCost: number;
  shipmentQuantity?: number;
  podFileUrl: string;
}

export interface ShipmentResponseModel {
  id: number;
  shipmentNumber: string;
  poId: number;
  poQuantity: number;
  poTotalAmount: number;
  supplierId: number;
  supplierName: string;
  supplierContactPerson: string;
  supplierEmail: string;
  supplierPhone: string;
  supplierAddress: string;
  vehicleNumber: string;
  captainRegistrationNumber: string;
  assignedByEmail: string;
  origin: string;
  sendByAddress: string;
  estimatedDelivery: string;
  transportCost: number;
  shipmentQuantity: number;
  podFileUrl: string;
  createdAt: string;
  updatedAt: string;
}
