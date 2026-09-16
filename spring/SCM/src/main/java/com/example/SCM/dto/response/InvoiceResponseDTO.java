package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class InvoiceResponseDTO {
    private Long id;
    private String invoiceNumber;
    private Long customerOrderId;      // TS: CustomerOrderId
    private String customerEmail;
    private Long salesOfficerId;
    private String issuedToName;
    private String currency;
    private double subtotal;
    private double taxRate;
    private double taxAmount;
    private double discountAmount;
    private double discountPercentage;
    private double shippingFees;
    private double totalAmount;
    private double paidAmount;
    private double dueAmount;
    private String paymentStatus;
    private String paymentMethod;
    private String transactionReference;
    private String invoiceStatus;
    private LocalDate deliveryDate;
    private String deliveryAddress;
    private String notes;
    private String cancelledReason;
    private LocalDate issuedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime cancelledAt;
}