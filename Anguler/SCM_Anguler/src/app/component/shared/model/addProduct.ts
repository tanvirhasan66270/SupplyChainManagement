export interface ProductRequestModel {
  id: number;
  productCode: string;
  name: string;
  unit: string;
  reorderPoint: number;
  unitCost: number;
  quantity: number;
  sellingPrice: number;
  hasExpiryDate: string;
  weight: number;
  isActive: boolean;
  availability: string;
  image: string;
  categoryId: number;
}

export interface ProductResponseModel {
  id: number;
  productCode: string;
  name: string;
  unit: string;
  reorderPoint: number;
  unitCost: number;
  quantity: number;
  sellingPrice: number;
  hasExpiryDate: string;
  weight: number;
  isActive: boolean;
  availability: string;
  image: string;
  categoryId: number;
  categoryName: string;
}
