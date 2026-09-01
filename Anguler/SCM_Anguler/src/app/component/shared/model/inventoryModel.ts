

export interface InventoryRequestModel {
  productId: number;
  warehouseId: number;
  quantityOnHand: number;
  quantityReserved: number;
  locationStatus?: string; // যেমন: "Rack-A, Row-3" (Optional safety)
  expiryDate?: string;     // ফ্রন্টএন্ড থেকে "YYYY-MM-DD" ফরম্যাটের স্ট্রিং
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
  lastUpdated: string;       // LocalDateTime ISO String
}
