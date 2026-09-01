package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.CountryRequestDTO;
import com.example.SCM.dto.response.CountryResponseDTO;
import com.example.SCM.entity.Country;
import com.example.SCM.entity.Division;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class CountryMapper {


    public CountryResponseDTO convertTOResponseDTO(Country entity) {

        CountryResponseDTO dto = new CountryResponseDTO();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setCode(entity.getCode());
        dto.setPhoneCode(entity.getPhoneCode());
        dto.setActive(entity.getActive());

        if (entity.getDivisions() != null) {
            dto.setDivisions(entity.getDivisions().stream()
                    .map(Division::getName)
                    .collect(Collectors.toList()));
        }
        return dto;
    }


    public Country toEntity(CountryRequestDTO dto) {

        Country entity = new Country();
        entity.setName(dto.getName());
        entity.setCode(dto.getCode());
        entity.setPhoneCode(dto.getPhoneCode());
        if (dto.getActive() != null) {
            entity.setActive(dto.getActive());
        }
        return entity;
    }


    public void updateEntity(CountryRequestDTO dto, Country entity) {

        entity.setName(dto.getName());
        entity.setCode(dto.getCode());
        entity.setPhoneCode(dto.getPhoneCode());
        if (dto.getActive() != null) {
            entity.setActive(dto.getActive());
        }
    }
}