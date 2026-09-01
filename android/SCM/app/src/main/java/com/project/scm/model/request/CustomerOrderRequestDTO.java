package com.project.scm.model.request;



import lombok.Data;
import java.util.List;

@Data
public class CustomerOrderRequestDTO {
    private Long customerId;
    private String deliveryAddress;
    private String deliveryPhone;
    private String estimatedDelivery; // YYYY-MM-DD
    private String serviceType;       // STANDARD, EXPRESS
    private String currency;          // BDT, USD
    private double codAmount;
    private String paymentMethod;     // CASH, BANK, BKASH, NAGAD, ROCKET
    private String status;            // PENDING, CONFIRMED
    private String remarks;

    private List<OrderLineItemRequestDTO> items;
}