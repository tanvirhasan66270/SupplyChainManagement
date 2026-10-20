

export interface InventoryRequestModel {
  productId: number;
  warehouseId: number;
  quantityOnHand: number;
  quantityReserved: number;
  locationStatus?: string;
  expiryDate?: string;    
  stockStatus: 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK' | string;
}


export interface InventoryResponseModel {
  id: number; 

  productId: number;
  productCode: string;
  productName: string;

  warehouseId: number;
  warehouseName: string;

  quantityOnHand: number;
  quantityReserved: number;
  availableQuantity: number; // (quantityOnHand - quantityReserved)
  locationStatus: string;
  expiryDate: string;        // Temporal Date Format (YYYY-MM-DD)
  stockStatus: 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK' | string;
  lastUpdated: string;      
}
