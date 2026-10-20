package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.Set;

@Data
public class DriverResponseDTO {
    private Long id;
    private String driverName;
    private String phone;
    private String address;
    private String nidNumber;
    private String gender;
    private String email;
    private String vehicleType;
    private String vehicleNumber;
    private String dob;
    private Double rating;
    private Integer totalDeliveries;
    private Double totalEarnings;
    private String image;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long userId;

    private String role;

    // Location IDs
    private Long countryId;
    private Long divisionId;
    private Long districtId;
    private Long policeStationId;

    // Location Names
    private String countryName;
    private String divisionName;
    private String districtName;
    private String policeStationName;



    private Set<String> warehouseNames;
}