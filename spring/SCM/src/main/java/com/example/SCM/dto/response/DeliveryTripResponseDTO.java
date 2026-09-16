package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class DeliveryTripResponseDTO {
    private Long id;
    private Long dispatcherId;
    private String status;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private String recipientSignature;
    private String deliveryPhotoUrl;
    private String customerAddress;
    private String remarks;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Flattened Relations for UI ──
    private Long customerId;
    private String recipientName;

    private Long driverId;
    private String driverName;
    private String driverPhone;
    private String driverEmail;

    private Long vehicleId;
    private String vehiclePlateNumber;
    private String vehicleModel;
}