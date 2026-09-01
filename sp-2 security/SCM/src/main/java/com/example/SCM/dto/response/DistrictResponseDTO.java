package com.example.SCM.dto.response;

import lombok.Data;
import java.util.List;

@Data
public class DistrictResponseDTO {
    private Long id;
    private String name;
    private String nameBn;
    private String districtCode;
    private Boolean active;

    //  Flattened Division & Country Details ---
    private Long divisionId;
    private String divisionName;
    private String countryName;

    // Police Stations Breakdown ---
    private List<String> policeStations;
}