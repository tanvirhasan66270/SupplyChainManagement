export interface SupplierRequestDTO {
  name: string;
  email: string;
  phone: string;
  password?: string;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  gender: string;
  dob: string;
  image: string;
  rating: number;
  averageLeadTimeDays: number;
  policeStationId: number;
}

export interface SupplierResponseDTO {
  id: number;
  userId: number;
  name: string;
  email: string;
  phone: string;
  role: string;
  contactPerson: string;
  address: string;
  nidNumber: string;
  passportNumber: string;
  gender: string;
  dob: string;
  image: string;
  rating: number;
  averageLeadTimeDays: number;
  createdAt: string;
  updatedAt: string;
  policeStationId: number;
  policeStationName: string;
  districtName: string;
  divisionName: string;
}
