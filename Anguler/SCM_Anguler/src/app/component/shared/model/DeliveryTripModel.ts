
export interface DeliveryTripRequestModel {
  dispatcherId: number;
  customerId: number;
  vehicleId: number;
  driverId: number;
  status: 'PENDING' | 'IN_TRANSIT' | 'DELIVERED' | 'CANCELLED' | string;
  customerAddress: string;
  recipientSignature?: string | null; // ফাইল আপলোডের পর জেনারেট হওয়া স্ট্রিং পাথ
  deliveryPhotoUrl?: string | null;   // ফাইল আপলোডের পর জেনারেট হওয়া স্ট্রিং পাথ
  remarks?: string | null;
}


export interface DeliveryTripResponseModel {
  id: number;
  dispatcherId: number;
  status: 'PENDING' | 'IN_TRANSIT' | 'DELIVERED' | 'CANCELLED' | string;
  startedAt?: string | null;       // ISO Date-Time String (LocalDateTime)
  completedAt?: string | null;     // ISO Date-Time String (LocalDateTime)
  recipientSignature?: string | null;
  deliveryPhotoUrl?: string | null;
  customerAddress: string;
  remarks?: string | null;
  createdAt: string;               // ISO Date-Time String
  updatedAt: string;               // ISO Date-Time String

  //Flattened Relations for UI Table Maps ──
  customerId: number;
  recipientName: string;           // Maps directly with customer.name

  driverId: number;
  driverName: string;
  driverPhone: string;
  driverEmail: string;

  vehicleId: number;
  vehiclePlateNumber: string;
  vehicleModel?: string | null;    // ওআরএম অবজেক্ট থেকে ম্যাপড ভেহিকল স্পেক্স
}
