package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class ShipmentRequestDTO {
    private Long id;
    private Long poId;                  // FK → PurchaseOrder
    private Long supplierId;            // FK → Supplier
    private String vehicleNumber;
    private String captainRegistrationNumber;
    private String assignedByEmail;     // FK → User (Logistics Officer)
    private String origin;
    private String sendByAddress;
    private String estimatedDelivery;   // "YYYY-MM-DD"
    private Double transportCost;
    private Double shipmentQuantity;
    private String podFileUrl;          // Image path/URL
}