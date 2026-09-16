package com.example.SCM.dto.mapper;

import com.example.SCM.dto.response.SupplierResponseDTO;
import com.example.SCM.dto.request.SupplierRequestDTO;

import com.example.SCM.entity.*;
import com.example.SCM.role.Role;
import org.springframework.stereotype.Component;

@Component
public class SupplierMapper {


    public SupplierResponseDTO toResponseDTO(Supplier supplier) {


        SupplierResponseDTO dto = new SupplierResponseDTO();

        dto.setId(supplier.getId());
        dto.setContactPerson(supplier.getContactPerson());
        dto.setAddress(supplier.getAddress());
        dto.setNidNumber(supplier.getNidNumber());
        dto.setPassportNumber(supplier.getPassportNumber());
        dto.setGender(supplier.getGender());


        dto.setDob(supplier.getDob() != null
                ? supplier.getDob().toString() : null);


        dto.setImage(supplier.getImage());
        dto.setRating(supplier.getRating());
        dto.setAverageLeadTimeDays(supplier.getAverageLeadTimeDays());
        dto.setCreatedAt(supplier.getCreatedAt());
        dto.setUpdatedAt(supplier.getUpdatedAt());

        User user = supplier.getUser();
        if (user != null) {
            dto.setUserId(user.getId());
            dto.setName(user.getName());
            dto.setEmail(user.getEmail());
            dto.setPhone(user.getPhoneNumber());
            dto.setRole(user.getRole() != null ? user.getRole().name() : null);
        }


        if (supplier.getPoliceStation() != null) {

            PoliceStation ps = supplier.getPoliceStation();

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




    public Supplier toSupplierEntity(SupplierRequestDTO dto, User user, PoliceStation policeStation) {


        Supplier supplier = new Supplier();

        supplier.setName(dto.getName());
        supplier.setContactPerson(dto.getContactPerson());
        supplier.setEmail(dto.getEmail());
        supplier.setPhone(dto.getPhone());
        supplier.setAddress(dto.getAddress());
        supplier.setNidNumber(dto.getNidNumber());
        supplier.setPassportNumber(dto.getPassportNumber());
        supplier.setGender(dto.getGender());

        if (dto.getDob() != null && !dto.getDob().trim().isEmpty()) {
            try {
                supplier.setDob(String.valueOf(java.sql.Date.valueOf(dto.getDob())));
            } catch (IllegalArgumentException e) {
                try {
                    supplier.setDob(String.valueOf(new java.text.SimpleDateFormat("yyyy-MM-dd").parse(dto.getDob())));
                } catch (Exception ex) {
                }
            }
        }

        supplier.setImage(dto.getImage());
        supplier.setRating(dto.getRating());
        supplier.setAverageLeadTimeDays(dto.getAverageLeadTimeDays());

        supplier.setUser(user);
        supplier.setPoliceStation(policeStation);

        return supplier;
    }
}