package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.DistrictRequestDTO;
import com.example.SCM.dto.response.DistrictResponseDTO;
import com.example.SCM.entity.Division;
import com.example.SCM.entity.District;
import com.example.SCM.entity.PoliceStation;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class DistrictMapper {


    public DistrictResponseDTO convertTOResponseDTO(District entity) {

        DistrictResponseDTO dto = new DistrictResponseDTO();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setNameBn(entity.getNameBn());
        dto.setDistrictCode(entity.getDistrictCode());
        dto.setActive(entity.getActive());

        // Division & Country Flattening
        if (entity.getDivision() != null) {
            dto.setDivisionId(entity.getDivision().getId());
            dto.setDivisionName(entity.getDivision().getName());
            if (entity.getDivision().getCountry() != null) {
                dto.setCountryName(entity.getDivision().getCountry().getName());
            }
        }

        // Child Police Stations Mapping
        if (entity.getPoliceStations() != null) {
            dto.setPoliceStations(entity.getPoliceStations().stream()
                    .map(PoliceStation::getName) // আপনার PoliceStation এনটিটির নাম ফিল্ড অনুযায়ী
                    .collect(Collectors.toList()));
        }
        return dto;
    }


    public District toEntity(DistrictRequestDTO dto, Division division) {

        District entity = new District();
        entity.setName(dto.getName());
        entity.setNameBn(dto.getNameBn());
        entity.setDistrictCode(dto.getDistrictCode());
        if (dto.getActive() != null) {
            entity.setActive(dto.getActive());
        }
        entity.setDivision(division);
        return entity;
    }


    public void updateEntity(DistrictRequestDTO dto, District entity, Division division) {
        if (dto == null || entity == null) return;

        entity.setName(dto.getName());
        entity.setNameBn(dto.getNameBn());
        entity.setDistrictCode(dto.getDistrictCode());
        if (dto.getActive() != null) {
            entity.setActive(dto.getActive());
        }
        if (division != null) {
            entity.setDivision(division);
        }
    }
}