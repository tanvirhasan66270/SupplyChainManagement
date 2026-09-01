export interface OrderLineItemRequestModel {
  productId: number;
  quantity: number;
  remarks: string;
}

export interface OrderLineItemResponseModel {
  id: number;
  productId: number;
  productName: string;
  productCode: string;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
  itemWeightTotal: number;
  remarks: string;
}

export interface CustomerOrderRequestModel {
  customerId: number; 
  deliveryAddress: string;
  deliveryPhone: string;
  estimatedDelivery: string; 
  serviceType: 'STANDARD' | 'EXPRESS' | 'OVERNIGHT' | 'SAME_DAY' | string; 
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT' | string;  // LOW, NORMAL, HIGH, URGENT
  currency: string;
  codAmount: number;
  paymentMethod: 'CASH' | 'BANK' | 'BKASH' | 'NAGAD' | 'ROCKET' | string;  // CASH, BANK, BKASH, NAGAD, ROCKET
  customerAccountNumber?: string;
  paymentCheckImage?: string;
  status: 'PENDING' | 'CONFIRMED' | 'PROCESSING' | 'SHIPPED' | 'OUT_FOR_DELIVERY' |'DELIVERED' |'CANCELLED' | string;
  remarks: string;
  items: OrderLineItemRequestModel[];
}

export interface CustomerOrderResponseModel {
  id: number;
  orderNumber: string;
  customerId: number;
  customerName: string;
  customerEmail: string;
  itemSubtotal: number;
  weight: number;
  serviceType: 'STANDARD' | 'EXPRESS' | 'OVERNIGHT' | 'SAME_DAY' | string;
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT' | string;
  currency: string;
  codAmount: number;
  deliveryCharge: number;
  totalAmount: number;
  paidAmount: number | string;
  dueAmount: number | string;
  paymentStatus:  'UNPAID' | 'PARTIALLY_PAID' | 'PAID' | 'REFUNDED' | string;
  paymentMethod: 'CASH' | 'BANK' | 'BKASH' | 'NAGAD' | 'ROCKET' | string;
  customerAccountNumber?: string;
  paymentCheckImage?: string;
  status: 'PENDING' | 'CONFIRMED' | 'PROCESSING' | 'SHIPPED' | 'OUT_FOR_DELIVERY' |'DELIVERED' |'CANCELLED' | string;
  deliveryAddress: string;
  deliveryPhone: string;
  remarks: string;
  estimatedDelivery: string;
  createdAt: string;
  lineItems: OrderLineItemResponseModel[];
}
