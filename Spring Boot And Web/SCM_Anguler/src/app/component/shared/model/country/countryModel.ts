export interface CountryRequestModel {
  name: string;
  code: string;
  phoneCode: string;
  active: boolean;
}

export interface CountryResponseModel {
  id: number;
  name: string;
  code: string;
  phoneCode: string;
  active: boolean;
}
