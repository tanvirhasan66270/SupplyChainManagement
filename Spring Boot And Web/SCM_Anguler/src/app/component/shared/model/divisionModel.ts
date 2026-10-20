export interface DivisionRequestModel{
  name: string;
  nameBn: string;
  active: boolean;
  countryId: number;
}
export interface DivisionResponseModel {
  id: number;
  name: string;
  nameBn: string;
  active: boolean;
  countryId: number;
  countryName: string;
  
}
