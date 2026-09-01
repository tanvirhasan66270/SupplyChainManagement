export interface PoliceStationRequestModel {
  name: string;
  nameBn: string;
  postalCode: string;
  active: boolean;
  districtId: number;
}
export interface PoliceStationResponseModel {
  id: number;
  name: string;
  nameBn: string;
  postalCode: string;
  active: boolean;
  districtId: number;
  districtName: string;
  divisionName: string;
  countryName: string;
}

