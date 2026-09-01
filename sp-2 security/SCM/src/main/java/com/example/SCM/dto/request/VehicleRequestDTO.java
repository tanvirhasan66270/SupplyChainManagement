package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class VehicleRequestDTO {
    private Long id;
    private String plateNumber;
    private String type;
    private Double capacity;
    private String status;
    private String lastServiceDate; // "YYYY-MM-DD"
    private Integer fuelLevel;
    private Long driverId;       // FK Driver ID (Optional)
}