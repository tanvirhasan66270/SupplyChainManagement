package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.DivisionRequestDTO;
import com.example.SCM.dto.response.DivisionResponseDTO;
import com.example.SCM.entity.Country;
import com.example.SCM.entity.District;
import com.example.SCM.entity.Division;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class DivisionMapper {


    public DivisionResponseDTO convertTOResponseDTO(Division entity) {

        DivisionResponseDTO dto = new DivisionResponseDTO();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setNameBn(entity.getNameBn());
        dto.setActive(entity.getActive());

        if (entity.getCountry() != null) {
            dto.setCountryId(entity.getCountry().getId());
            dto.setCountryName(entity.getCountry().getName());
        }

        if (entity.getDistricts() != null) {
            dto.setDistricts(entity.getDistricts().stream()
                    .map(District::getName)
                    .collect(Collectors.toList()));
        }
        return dto;
    }


    public Division toEntity(DivisionRequestDTO dto, Country country) {

        Division entity = new Division();
        entity.setName(dto.getName());
        entity.setNameBn(dto.getNameBn());
        if (dto.getActive() != null) {
            entity.setActive(dto.getActive());
        }
        entity.setCountry(country);
        return entity;
    }



    public void updateEntity(DivisionRequestDTO dto, Division entity, Country country) {

        entity.setName(dto.getName());
        entity.setNameBn(dto.getNameBn());
        if (dto.getActive() != null) {
            entity.setActive(dto.getActive());
        }
        if (country != null) {
            entity.setCountry(country);
        }
    }
}