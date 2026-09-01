export interface QCInspectorRequestModel {
  name: string;
  email: string;
  phone: string;
  password?: string;
  userActive: boolean;
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
  policeStationId: number;
}

export interface QCInspectorResponseModel {
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
  userActive: boolean;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
}
