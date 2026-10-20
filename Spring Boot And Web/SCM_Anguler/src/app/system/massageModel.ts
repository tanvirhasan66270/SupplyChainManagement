export interface MessageRequestModel {
  recipientId?: string | null;
  subject: string;
  body: string;
  priority: 'LOW' | 'MEDIUM' | 'HIGH';
}

export interface MessageResponseModel {
  id: number;
  senderId: string;
  senderName: string;
  subject: string;
  body: string;
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | string;
  status: 'UNREAD' | 'READ' | string;
  createdAt: string;
}
