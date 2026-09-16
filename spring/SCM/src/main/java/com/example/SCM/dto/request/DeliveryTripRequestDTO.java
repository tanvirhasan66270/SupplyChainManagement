package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class DeliveryTripRequestDTO {
    private Long id;
    private Long dispatcherId;
    private Long customerId;
    private Long driverId;
    private Long vehicleId;
    private String status;     // PENDING, IN_TRANSIT, DELIVERED, CANCELLED
    private String customerAddress;
    private String recipientSignature;
    private String deliveryPhotoUrl;
    private String remarks;
}