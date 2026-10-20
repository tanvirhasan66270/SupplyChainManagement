

export interface VehicleRequestModel {
  plateNumber: string;
  type: 'TRUCK' | 'VAN' | 'BIKE' | 'AIR' | 'RIVER_SHIP' | string;
  capacity: number;
  status: 'AVAILABLE' | 'ON_TRIP' | 'MAINTENANCE' | 'OUT_OF_SERVICE' | string;
  lastServiceDate?: string | null;  
  fuelLevel: number;
  driverId?: number | null;        
}

export interface VehicleResponseModel {
  id: number;
  plateNumber: string;
  type: 'TRUCK' | 'VAN' | 'BIKE' | 'AIR' | 'RIVER_SHIP' | string;
  capacity: number;
  status: 'AVAILABLE' | 'ON_TRIP' | 'MAINTENANCE' | 'OUT_OF_SERVICE' | string;
  lastServiceDate?: string | null;  
  fuelLevel: number;

  driverId?: number | null;
  driverName?: string | null;
  driverPhone?: string | null;
}
