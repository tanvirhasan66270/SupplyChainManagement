export interface LCBankRequestModel {
  name: string;
  swiftCode: string;
  branchName: string;
  address: string;
  contactEmail: string;
  contactPhone: string;
}

export interface LCBankResponseModel {
  id: number;
  name: string;
  swiftCode: string;
  branchName: string;
  address: string;
  contactEmail: string;
  contactPhone: string;
  createdAt: string | null;
  updatedAt: string | null;
}
