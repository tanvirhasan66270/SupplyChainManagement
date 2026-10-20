package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class WarehouseRequestDTO {
    private String name;
    private String email;
    private String location;
    private double capacity;
    private Long managerId;
    
    @com.fasterxml.jackson.annotation.JsonProperty("isActive")
    private boolean isActive;
    
    private Long policeStationId;
}