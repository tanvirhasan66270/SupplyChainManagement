
export interface LetterOfCreditRequestModel {
  purchaseOrderId: number;
  issuingBankId: number;
  shipmentIncoTerms: string;
  latestShipmentDate: string; // Formatting Pattern: YYYY-MM-DD
  portOfLoading: string;
  portOfDischarge: string;
  amount: number;
  supplierId: number;
  currency: string;
  expiryDate: string;         // Formatting Pattern: YYYY-MM-DD
  lcStatus: 'DRAFT' | 'OPENED' | 'AMENDED' | 'EXPIRED' | 'CANCELLED' | string;
  documentVaultUrl: string;   // Image/PDF Vault String Path References
}


export interface LetterOfCreditResponseModel {
  id: number;
  lcNumber: string;
  purchaseOrderId: number;
  poNumber: string;
  issuingBankId: number;
  issuingBankName: string;
  issuingBankSwiftCode: string;
  issuingBankBranch: string;
  issuingBankaddress: string; 
  shipmentIncoTerms: string;
  latestShipmentDate: string;
  portOfLoading: string;
  portOfDischarge: string;
  amendmentCount: number;
  amount: number;
  supplierId: number;
  supplierName: string;
  supplierEmail: string;
  currency: string;
  expiryDate: string;
  lcStatus: 'DRAFT' | 'OPENED' | 'AMENDED' | 'EXPIRED' | 'CANCELLED' | string;
  documentVaultUrl: string;
  openedAt: string;
  createdAt: string;
  updatedAt: string;
}
