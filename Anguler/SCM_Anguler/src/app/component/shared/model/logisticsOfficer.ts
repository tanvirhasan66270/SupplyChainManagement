export interface LogisticsOfficerRequestModel {
  id: number;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  joiningDate: string;
  designation: string;
  language: string;
  policeStationId: number;
  name: string;
  email: string;
  phone: string;
  password: string;
}
export interface LogisticsOfficerResponseModel {
  id: number;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  dob: string;
  gender: string;
  image: string;
  joiningDate: string;
  designation: string;
  language: string;
  
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;

 countryId: number ;
  divisionId: number ;
  districtId: number ;
  policeStationId: number ;

  countryName: string ;
  divisionName: string ;
  districtName: string ;
  policeStationName: string ;
}

