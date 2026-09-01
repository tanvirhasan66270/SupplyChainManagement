export interface NotificationModel {
  id?: number;
  recipientId: string;
  type: 'SHIPMENT' | 'TRIP_ALERT' | 'REPORT_APPROVED' | string;
  title: string;
  message: string;
  isRead: boolean;
  createdAt: string; // ISO Date String
}
