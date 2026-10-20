package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.QCInspectorRequestDTO;
import com.example.SCM.dto.response.QCInspectorResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Component
public class QCInspectorMapper {

    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

     public QCInspectorResponseDTO convertTOResponseDTO(QCInspector inspector) {


        QCInspectorResponseDTO dto = new QCInspectorResponseDTO();

        dto.setId(inspector.getId());
        dto.setContactPerson(inspector.getContactPerson());
        dto.setAddress(inspector.getAddress());
        dto.setNidNumber(inspector.getNidNumber());
        dto.setPassportNumber(inspector.getPassportNumber());
        dto.setGender(inspector.getGender());
        dto.setDob(inspector.getDob());
        dto.setImage(inspector.getImage());
        dto.setJoiningDate(inspector.getJoiningDate());
        dto.setDesignation(inspector.getDesignation());
        dto.setLanguage(inspector.getLanguage());
        dto.setCreatedAt(inspector.getCreatedAt());
        dto.setUpdatedAt(inspector.getUpdatedAt());

        User user = inspector.getUser();
        if (user != null) {
            dto.setUserId(user.getId());
            dto.setName(user.getName());
            dto.setEmail(user.getEmail());
            dto.setPhone(user.getPhoneNumber());
            dto.setRole(user.getRole());
            dto.setUserActive(user.isActive());
        }

         if (inspector.getPoliceStation() != null) {

             PoliceStation ps = inspector.getPoliceStation();

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

        return dto;
    }




    public QCInspector toQCInspectorEntity(QCInspectorRequestDTO dto, User user, PoliceStation policeStation) {


        QCInspector inspector = new QCInspector();

        inspector.setContactPerson(dto.getContactPerson());
        inspector.setAddress(dto.getAddress());
        inspector.setNidNumber(dto.getNidNumber());
        inspector.setPassportNumber(dto.getPassportNumber());
        inspector.setImage(dto.getImage());
        inspector.setDesignation(dto.getDesignation());

        if (dto.getDob() != null && !dto.getDob().trim().isEmpty()) {
            inspector.setDob(LocalDate.parse(dto.getDob(), dateFormatter));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().trim().isEmpty()) {
            inspector.setJoiningDate(LocalDate.parse(dto.getJoiningDate(), dateFormatter));
        }

        if (dto.getGender() != null && !dto.getGender().trim().isEmpty()) {
            inspector.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null && !dto.getLanguage().trim().isEmpty()) {
            inspector.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        inspector.setUser(user);
        inspector.setPoliceStation(policeStation);

        return inspector;
    }


    public void updateEntity(QCInspectorRequestDTO dto, QCInspector inspector, PoliceStation policeStation) {

        User user = inspector.getUser();
        if (user != null) {
            if (dto.getName() != null) user.setName(dto.getName());
            if (dto.getEmail() != null) user.setEmail(dto.getEmail());
            if (dto.getPhone() != null) user.setPhoneNumber(dto.getPhone());
            user.setActive(dto.isUserActive());
            if (dto.getPassword() != null && !dto.getPassword().trim().isEmpty()) {
                user.setPassword(dto.getPassword());
            }
        }

        inspector.setContactPerson(dto.getContactPerson());
        inspector.setAddress(dto.getAddress());
        inspector.setNidNumber(dto.getNidNumber());
        inspector.setPassportNumber(dto.getPassportNumber());
        inspector.setImage(dto.getImage());
        inspector.setDesignation(dto.getDesignation());

        if (dto.getDob() != null && !dto.getDob().trim().isEmpty()) {
            inspector.setDob(LocalDate.parse(dto.getDob(), dateFormatter));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().trim().isEmpty()) {
            inspector.setJoiningDate(LocalDate.parse(dto.getJoiningDate(), dateFormatter));
        }

        if (dto.getGender() != null && !dto.getGender().trim().isEmpty()) {
            inspector.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null && !dto.getLanguage().trim().isEmpty()) {
            inspector.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        if (policeStation != null) {
            inspector.setPoliceStation(policeStation);
        }
    }
}