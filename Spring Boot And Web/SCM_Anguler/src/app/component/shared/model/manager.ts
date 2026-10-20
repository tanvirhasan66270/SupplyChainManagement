
export interface ManagerResponseModel {
  id: number;
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
  policeStationName: string;
  createdAt: string;
  updatedAt: string;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
}
export interface ManagerRequestModel {
  id: number;
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
