package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class InvoiceRequestDTO {
    private Long customerOrderId;      // TS: CustomerOrderId
    private Long salesOfficerId;
    private double subtotal;
    private double taxRate;
    private double discountAmount;
    private double discountPercentage;
    private double shippingFees;
    private double paidAmount;
    private String paymentMethod;
    private String transactionReference;
    private String invoiceStatus;      // DRAFT, ISSUED, CANCELLED
    private String deliveryDate;
    private String deliveryAddress;
    private String notes;
    private String cancelledReason;
}