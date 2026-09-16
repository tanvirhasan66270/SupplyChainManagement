package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.SalesOfficerRequestDTO;
import com.example.SCM.dto.response.SalesOfficerResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
public class SalesOfficerMapper {


    public SalesOfficer toOfficerEntity(SalesOfficerRequestDTO dto, User user, PoliceStation policeStation) {
        SalesOfficer officer = new SalesOfficer();
        officer.setUser(user);
        officer.setAddress(dto.getAddress());
        officer.setNidNumber(dto.getNidNumber());
        officer.setDesignation(dto.getDesignation());


        if (dto.getDob() != null && !dto.getDob().isBlank()) {
            officer.setDob(LocalDate.parse(dto.getDob()));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().isBlank()) {
            officer.setJoiningDate(LocalDate.parse(dto.getJoiningDate()));
        }
        if (dto.getGender() != null) {
            officer.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null) {
            officer.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        officer.setPoliceStation(policeStation);
        return officer;
    }

    public SalesOfficerResponseDTO convertTOResponseDTO(SalesOfficer entity) {

        SalesOfficerResponseDTO dto = new SalesOfficerResponseDTO();
        dto.setId(entity.getId());
        dto.setAddress(entity.getAddress());
        dto.setNidNumber(entity.getNidNumber());
        dto.setDob(entity.getDob());
        dto.setGender(entity.getGender() != null ? entity.getGender().name() : null);
        dto.setImage(entity.getImage());
        dto.setJoiningDate(entity.getJoiningDate());
        dto.setDesignation(entity.getDesignation());
        dto.setLanguage(entity.getLanguage() != null ? entity.getLanguage().name() : null);
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        // =========================
        // LOCATION INFORMATION
        // =========================
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