export interface DriverRequestModel {
  id: number;
  driverName: string;
  phone: string;
  address: string;
  nidNumber: string;
  gender: string;
  email: string;
  vehicleType: string;
  vehicleNumber: string;
  dob: string;
  rating: number;
  totalDeliveries: number;
  totalEarnings: number;
  image: string;
  password: string;
  policeStationId: number;
  warehouseIds: number[];
}



export interface DriverResponseModel {
  id: number;
  driverName: string;
  phone: string;
  address: string;
  nidNumber: string;
  gender: string;
  email: string;
  vehicleType: string;
  vehicleNumber: string;
  dob: string;
  rating: number;
  totalDeliveries: number;
  totalEarnings: number;
  image: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  role: string;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
  warehouseNames: string[];
}
