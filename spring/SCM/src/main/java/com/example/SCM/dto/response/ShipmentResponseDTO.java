package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ShipmentResponseDTO {
    private Long id;
    private String shipmentNumber;      // Auto generated

    //  Purchase Order Auto-loads ---
    private Long poId;
    private Integer poQuantity;
    private Double poTotalAmount;

    //  Supplier Auto-loads ---
    private Long supplierId;
    private String supplierName;
    private String supplierContactPerson;
    private String supplierEmail;
    private String supplierPhone;
    private String supplierAddress;

    //  Logistics Matrix ---
    private String vehicleNumber;
    private String captainRegistrationNumber;
    private String assignedByEmail;
    private String origin;
    private String sendByAddress;
    private String estimatedDelivery;
    private Double transportCost;
    private Double shipmentQuantity;
    private String podFileUrl;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}