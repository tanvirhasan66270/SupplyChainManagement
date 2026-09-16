package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class VehicleResponseDTO {
    private Long id;
    private String plateNumber;
    private String type;
    private Double capacity;
    private String status;
    private String lastServiceDate;
    private Integer fuelLevel;

    // Flattened Driver Metadata
    private Long driverId;
    private String driverName;
    private String driverPhone;
    private String driverEmail;
}