package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.LogisticsOfficerRequestDTO;
import com.example.SCM.dto.response.LogisticsOfficerResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
public class LogisticsOfficerMapper {


    public Logistics_Officer toOfficerEntity(LogisticsOfficerRequestDTO dto, User user, PoliceStation policeStation) {
        Logistics_Officer officer = new Logistics_Officer();
        officer.setUser(user);
        officer.setContactPerson(dto.getContactPerson());
        officer.setAddress(dto.getAddress());
        officer.setNidNumber(dto.getNidNumber());
        officer.setPassportNumber(dto.getPassportNumber());
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

    public LogisticsOfficerResponseDTO convertTOResponseDTO(Logistics_Officer officer) {

        LogisticsOfficerResponseDTO dto = new LogisticsOfficerResponseDTO();
        dto.setId(officer.getId());
        dto.setContactPerson(officer.getContactPerson());
        dto.setAddress(officer.getAddress());
        dto.setNidNumber(officer.getNidNumber());
        dto.setPassportNumber(officer.getPassportNumber());
        dto.setDob(officer.getDob());
        dto.setGender(officer.getGender() != null ? officer.getGender().name() : null);
        dto.setImage(officer.getImage());
        dto.setJoiningDate(officer.getJoiningDate());
        dto.setDesignation(officer.getDesignation());
        dto.setLanguage(officer.getLanguage() != null ? officer.getLanguage().name() : null);
        dto.setCreatedAt(officer.getCreatedAt());
        dto.setUpdatedAt(officer.getUpdatedAt());


        if (officer.getPoliceStation() != null) {

            PoliceStation ps = officer.getPoliceStation();

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

        if (officer.getUser() != null) {
            dto.setUserId(officer.getUser().getId());
            dto.setName(officer.getUser().getName());
            dto.setEmail(officer.getUser().getEmail());
            dto.setPhone(officer.getUser().getPhoneNumber());
            if (officer.getUser().getRole() != null) {
                dto.setRole(officer.getUser().getRole().name());
            }
        }
        return dto;
    }
}