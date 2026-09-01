export interface WarehouseRequestModel {
  name: string;
  email: string;
  location: string;
  address:string;
  capacity: number;
  managerId: number;
  isActive: boolean;
  policeStationId: number;
}

export interface WarehouseResponseModel {
  id: number;
  name: string;
  email: string;
  location: string;
  address:string;
  capacity: number;
  managerId: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
}
