package com.project.scm.model.response;

import java.util.List;

import lombok.Data;

@Data
public class CustomerOrderResponseDTO {

    private Long id;
    private String orderNumber;
    private Long customerId;
    private String customerName;
    private String customerEmail;
    private double itemSubtotal;
    private double weight;
    private String serviceType;
    private String currency;
    private double codAmount;
    private double deliveryCharge;
    private double totalAmount;
    private String paidAmount;
    private String dueAmount;
    private String paymentStatus;
    private String paymentMethod;     // CASH, BANK, BKASH, ইত্যাদি
    private String status;            // PENDING, CONFIRMED, SHIPPED, DELIVERED
    private String deliveryAddress;
    private String deliveryPhone;
    private String estimatedDelivery;
    private String remarks;
    private String createdAt;

    private List<OrderLineItemResponseDTO> lineItems;
}
