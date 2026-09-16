package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class WarehouseResponseDTO {
    private Long id;
    private String name;
    private String email;
    private String location;
    private String address;
    private double capacity;
    private Long managerId;
    
    @com.fasterxml.jackson.annotation.JsonProperty("isActive")
    private boolean isActive;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Location/PoliceStation Details (Data Flattening)
    private Long policeStationId;
    private String policeStationName;
    private String districtName;
    private String divisionName;
}