package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.ProcurementRequestDTO;
import com.example.SCM.dto.response.ProcurementResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
public class ProcurementMapper {


    public Procurement toProcurementEntity(ProcurementRequestDTO dto, User user, PoliceStation policeStation) {
        Procurement procurement = new Procurement();
        procurement.setUser(user);
        procurement.setAddress(dto.getAddress());
        procurement.setNidNumber(dto.getNidNumber());
        procurement.setPassportNumber(dto.getPassportNumber());
        procurement.setDesignation(dto.getDesignation());
        procurement.setActive(dto.isActive());

        if (dto.getDob() != null && !dto.getDob().isBlank()) {
            procurement.setDob(LocalDate.parse(dto.getDob()));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().isBlank()) {
            procurement.setJoiningDate(LocalDate.parse(dto.getJoiningDate()));
        }
        if (dto.getGender() != null) {
            procurement.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null) {
            procurement.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        procurement.setPoliceStation(policeStation);
        return procurement;
    }

    public ProcurementResponseDTO convertTOResponseDTO(Procurement entity) {

        ProcurementResponseDTO dto = new ProcurementResponseDTO();
        dto.setId(entity.getId());
        dto.setAddress(entity.getAddress());
        dto.setNidNumber(entity.getNidNumber());
        dto.setPassportNumber(entity.getPassportNumber());
        dto.setDob(entity.getDob());
        dto.setGender(entity.getGender() != null ? entity.getGender().name() : null);
        dto.setImage(entity.getImage());
        dto.setActive(entity.isActive());
        dto.setJoiningDate(entity.getJoiningDate());
        dto.setDesignation(entity.getDesignation());
        dto.setLanguage(entity.getLanguage() != null ? entity.getLanguage().name() : null);
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());


        if (entity.getPoliceStation() != null) {

            PoliceStation ps = entity.getPoliceStation();

            dto.setPoliceStationId(ps.getId());
            dto.setPoliceStationName(ps.getName());

            District district = ps.getDistrict();

            if (district != null) {

                dto.setDistrictId(district.getId());
                dto.setDistrictName(district.getName());

                Division division = district.getDivision();

                if (division != null) {

                    dto.setDivisionId(division.getId());
                    dto.setDivisionName(division.getName());

                    Country country = division.getCountry();

                    if (country != null) {

                        dto.setCountryId(country.getId());
                        dto.setCountryName(country.getName());

                    }
                }
            }
        }

        if (entity.getUser() != null) {
            dto.setUserId(entity.getUser().getId());
            dto.setName(entity.getUser().getName());
            dto.setEmail(entity.getUser().getEmail());
            dto.setPhone(entity.getUser().getPhoneNumber());
            if (entity.getUser().getRole() != null) {
                dto.setRole(entity.getUser().getRole().name());
            }
        }
        return dto;
    }
}