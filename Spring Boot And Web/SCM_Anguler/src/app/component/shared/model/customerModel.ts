
export interface CustomerRequestModel {
  name: string;
  email: string;
  phone: string;
  password?: string;         
  address: string;           
  gender: string;
  dob: string;              
  nidNumber: string;
  policeStationId: number;   
}
export interface CustomerResponseModel {
  id: number;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
  address: string;
  gender: string;
  dob: string;               
  nidNumber: string;
  image: string ; 
  createdAt: string;         

  countryId: number ;
  divisionId: number ;
  districtId: number ;
  policeStationId: number ;

  countryName: string ;
  divisionName: string ;
  districtName: string ;
  policeStationName: string ;
}