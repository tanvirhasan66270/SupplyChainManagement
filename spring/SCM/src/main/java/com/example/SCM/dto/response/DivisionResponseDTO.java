package com.example.SCM.dto.response;

import lombok.Data;
import java.util.List;

@Data
public class DivisionResponseDTO {
    private Long id;
    private String name;
    private String nameBn;
    private Boolean active;

    //  Flattened Country Relation ---
    private Long countryId;
    private String countryName;

    //  Districts Breakdown ---
    private List<String> districts;
}