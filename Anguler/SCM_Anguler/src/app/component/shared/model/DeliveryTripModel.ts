
export interface DeliveryTripRequestModel {
  dispatcherId: number;
  customerId: number;
  vehicleId: number;
  driverId: number;
  status: 'PENDING' | 'IN_TRANSIT' | 'DELIVERED' | 'CANCELLED' | string;
  customerAddress: string;
  recipientSignature?: string | null; 
  deliveryPhotoUrl?: string | null;   
  remarks?: string | null;
}


export interface DeliveryTripResponseModel {
  id: number;
  dispatcherId: number;
  status: 'PENDING' | 'IN_TRANSIT' | 'DELIVERED' | 'CANCELLED' | string;
  startedAt?: string | null;       
  completedAt?: string | null;    
  recipientSignature?: string | null;
  deliveryPhotoUrl?: string | null;
  customerAddress: string;
  remarks?: string | null;
  createdAt: string;               

  //Flattened Relations for UI Table Maps ──
  customerId: number;
  recipientName: string;           

  driverId: number;
  driverName: string;
  driverPhone: string;
  driverEmail: string;

  vehicleId: number;
  vehiclePlateNumber: string;
  vehicleModel?: string | null;
  updatedAt?: string | null;
}
