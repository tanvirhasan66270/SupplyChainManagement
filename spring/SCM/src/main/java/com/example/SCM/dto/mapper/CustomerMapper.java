package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.CustomerRequestDTO;
import com.example.SCM.dto.response.CustomerResponseDTO;
import com.example.SCM.entity.Country;
import com.example.SCM.entity.Customer;
import com.example.SCM.entity.District;
import com.example.SCM.entity.Division;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import org.springframework.stereotype.Component;

import java.text.SimpleDateFormat;

@Component("scmCustomerMapperServiceNode")
public class CustomerMapper {

    private final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");


    public CustomerResponseDTO convertTOResponseDTO(Customer entity) {

        CustomerResponseDTO dto = new CustomerResponseDTO();

        dto.setId(entity.getId());
        dto.setAddress(entity.getAddress());
        dto.setGender(entity.getGender());
        dto.setNidNumber(entity.getNidNumber());
        dto.setImage(entity.getImage());


        if (entity.getDob() != null) {
            dto.setDob(entity.getDob().toString());
        }

        if (entity.getCreatedAt() != null) {
            dto.setCreatedAt(entity.getCreatedAt().toString());
        }


        if (entity.getUser() != null) {

            User user = entity.getUser();

            dto.setUserId(user.getId());
            dto.setName(user.getName());
            dto.setEmail(user.getEmail());
            dto.setPhone(user.getPhoneNumber());

            if (user.getRole() != null) {
                dto.setRole(user.getRole().name());
            }
        }


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

        return dto;
    }


    public void updateEntity(CustomerRequestDTO dto,
                             Customer entity,
                             PoliceStation policeStation) {

        if (dto.getName() != null)
            entity.setName(dto.getName());

        if (dto.getEmail() != null)
            entity.setEmail(dto.getEmail());

        if (dto.getPhone() != null)
            entity.setPhone(dto.getPhone());

        if (dto.getAddress() != null)
            entity.setAddress(dto.getAddress());

        if (dto.getGender() != null)
            entity.setGender(dto.getGender());

        if (dto.getNidNumber() != null)
            entity.setNidNumber(dto.getNidNumber());



        if (dto.getDob() != null && !dto.getDob().isBlank()) {
            try {
                entity.setDob(java.time.LocalDate.parse(dto.getDob().trim()));
            } catch (Exception e) {
                System.err.println("DOB parse warning: " + e.getMessage());
            }
        }

        if (policeStation != null) {
            entity.setPoliceStation(policeStation);
        }


        if (entity.getUser() != null) {

            User user = entity.getUser();

            if (dto.getName() != null)
                user.setName(dto.getName());

            if (dto.getEmail() != null)
                user.setEmail(dto.getEmail());

            if (dto.getPhone() != null)
                user.setPhoneNumber(dto.getPhone());
        }
    }
}