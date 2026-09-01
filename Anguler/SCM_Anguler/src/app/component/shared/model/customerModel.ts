
export interface CustomerRequestModel {
  name: string;
  email: string;
  phone: string;
  password?: string;         // এডিট মোডে পাসওয়ার্ড অপশনাল হতে পারে, তাই '?' দেওয়া হয়েছে
  address: string;           // অটো-কম্পাইল্ড ফুল অ্যাড্রেস স্ট্রিং
  gender: string;
  dob: string;               // "YYYY-MM-DD" ফরম্যাট স্ট্রিং
  nidNumber: string;
  policeStationId: number;   // লোকেশন হায়ারার্কির শেষ নোড আইডি
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
  dob: string;               // "YYYY-MM-DD" ফরম্যাট স্ট্রিং
  nidNumber: string;
  image: string ; 
  createdAt: string;         // ISO Date-Time String

  countryId: number ;
  divisionId: number ;
  districtId: number ;
  policeStationId: number ;

  countryName: string ;
  divisionName: string ;
  districtName: string ;
  policeStationName: string ;
}