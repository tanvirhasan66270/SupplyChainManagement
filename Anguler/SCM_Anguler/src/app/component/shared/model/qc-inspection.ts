
export interface QCChecklistRequestModel {
  inspectionId?: number; 
  checkpointName: string;
  isPassed: boolean;
  remarks: string;
}


export interface QCChecklistResponseModel {
  id: number; 
  checkpointName: string;
  isPassed: boolean;
  remarks: string;
  createdAt: string; 
  updatedAt: string;
  inspectionId: number;
  inspectionType: string;
}


export interface QCInspectionRequestModel {
  id?: number; 
  grnId: number;
  productId: number;
  inspectionType: string; // e.g., 'VISUAL', 'LAB_TEST'
  inspectedBy: number;
  sampleSize: number;
  defectsFound: number;
  defectDescription: string;
  result: 'GOOD' | 'VERY_GOOD' | 'AVERAGE' | 'BAD' | string;
  certificateRef: string;
  labTestReport: string;
  inspectedAt: string; 
  checklists: QCChecklistRequestModel[]; 
}


export interface QCInspectionResponseModel {
  id: number;
  inspectionType: string;
  sampleSize: number;
  defectsFound: number;
  defectDescription: string;
  result: 'GOOD' | 'VERY_GOOD' | 'AVERAGE' | 'BAD' | string;
  certificateRef: string;
  labTestReport: string;
  inspectedAt: string; // YYYY-MM-DD
  createdAt: string;
  updatedAt: string;
  
  
  grnId: number;
  grnNumber: string;
  productId: number;
  productName: string;
  inspectedBy: number;
  inspectedByName: string;
  
  checklists: QCChecklistResponseModel[]; 
}
