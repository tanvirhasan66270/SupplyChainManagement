package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.ManagerRequestDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
public class ManagerMapper {



    public Manager toManagerEntity(ManagerRequestDTO dto, User user, PoliceStation policeStation) {
        Manager manager = new Manager();
        manager.setUser(user);
        manager.setAddress(dto.getAddress());
        manager.setNidNumber(dto.getNidNumber());
        manager.setPassportNumber(dto.getPassportNumber());
        manager.setDesignation(dto.getDesignation());


        if (dto.getDob() != null && !dto.getDob().isBlank()) {
            manager.setDob(LocalDate.parse(dto.getDob()));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().isBlank()) {
            manager.setJoiningDate(LocalDate.parse(dto.getJoiningDate()));
        }
        if (dto.getGender() != null) {
            manager.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null) {
            manager.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        manager.setPoliceStation(policeStation);
        return manager;
    }

    public ManagerResponseDTO convertTOResponseDTO(Manager manager) {

        ManagerResponseDTO dto = new ManagerResponseDTO();
        dto.setId(manager.getId());
        dto.setAddress(manager.getAddress());
        dto.setNidNumber(manager.getNidNumber());
        dto.setPassportNumber(manager.getPassportNumber());
        dto.setDob(manager.getDob());
        dto.setGender(manager.getGender() != null ? manager.getGender().name() : null);
        dto.setImage(manager.getImage());
        dto.setJoiningDate(manager.getJoiningDate());
        dto.setDesignation(manager.getDesignation());
        dto.setLanguage(manager.getLanguage() != null ? manager.getLanguage().name() : null);
        dto.setCreatedAt(manager.getCreatedAt());
        dto.setUpdatedAt(manager.getUpdatedAt());


        if (manager.getPoliceStation() != null) {

            PoliceStation ps = manager.getPoliceStation();

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
        if (manager.getUser() != null) {
            dto.setUserId(manager.getUser().getId());
            dto.setName(manager.getUser().getName());
            dto.setEmail(manager.getUser().getEmail());
            dto.setPhone(manager.getUser().getPhoneNumber());
            if (manager.getUser().getRole() != null) {
                dto.setRole(manager.getUser().getRole().name());
            }
        }
        return dto;
    }
}