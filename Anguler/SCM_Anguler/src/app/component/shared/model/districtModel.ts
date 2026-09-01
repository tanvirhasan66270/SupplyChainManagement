export interface DistrictRequestModel {
  name: string;
  nameBn: string;
  districtCode: string;
  active: boolean;
  divisionId: number;
}
export interface DistrictResponseModel {
  id: number;
  name: string;
  nameBn: string;
  districtCode: string;
  active: boolean;
  divisionId: number;
  divisionName: string;
  countryName: string;
  policeStations: string[];
}
