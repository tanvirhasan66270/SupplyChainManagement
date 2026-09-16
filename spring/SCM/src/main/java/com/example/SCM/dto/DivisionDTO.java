package com.example.SCM.dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class DivisionDTO {
    private Long divisionId;
    private  String divisionName;
    private  String countryName;
    private Long countryId;

}
