export interface ActivityLogModel {
  id?: number;
  userId: string;
  userEmail?: string;
  action: 'CREATE' | 'UPDATE' | 'DELETE' | 'LOGIN' | string;
  module: 'PO' | 'GRN' | 'QC' | 'LC' | 'SHIPMENT' | string;
  referenceId: string;
  description?: string;
  oldValue?: string;
  newValue?: string;
  actionStatus: 'SUCCESS' | 'FAILED' | string;
  ipAddress?: string;
  performedAt: string; // ISO DateTime String
}
