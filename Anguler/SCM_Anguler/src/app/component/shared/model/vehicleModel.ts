

export interface VehicleRequestModel {
  plateNumber: string;
  type: 'TRUCK' | 'VAN' | 'BIKE' | 'AIR' | 'RIVER_SHIP' | string;
  capacity: number;
  status: 'AVAILABLE' | 'ON_TRIP' | 'MAINTENANCE' | 'OUT_OF_SERVICE' | string;
  lastServiceDate?: string | null;  // "YYYY-MM-DD" ফরম্যাটে স্ট্রিং ইনপুট আসবে
  fuelLevel: number;
  driverId?: number | null;         // FK Driver ID (Optional, ড্রাইভারে অ্যাসাইন না থাকলে null যাবে)
}

export interface VehicleResponseModel {
  id: number;
  plateNumber: string;
  type: 'TRUCK' | 'VAN' | 'BIKE' | 'AIR' | 'RIVER_SHIP' | string;
  capacity: number;
  status: 'AVAILABLE' | 'ON_TRIP' | 'MAINTENANCE' | 'OUT_OF_SERVICE' | string;
  lastServiceDate?: string | null;   // "YYYY-MM-DD" বা ISO ডেট স্ট্রিং
  fuelLevel: number;

  // Flattened Driver Metadata ──
  driverId?: number | null;
  driverName?: string | null;
  driverPhone?: string | null;
}
