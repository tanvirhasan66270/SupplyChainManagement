
export interface DailyReportRequestModel {
  warehouseId: string;
  reportDate: string;       
  totalTasksDone: number;
  issuesLogged: number;
  summary: string;
}


export interface DailyReportResponseModel {
  id: number;
  userId: string;            
  warehouseId: string;
  reportDate: string;      
  totalTasksDone: number;
  issuesLogged: number;
  summary: string | null;    
  reportStatus: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | string;
  attachmentUrl: string | null | undefined; 
  generatedAt: string;      
  updatedAt: string;        

  notifiedAuthorities: Array<{
    name: string;
    email: string;
    role: string;
  }>;
}

