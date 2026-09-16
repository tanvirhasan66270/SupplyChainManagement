package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.AdminRequest;
import com.example.SCM.dto.response.AdminResponse;
import com.example.SCM.entity.Admin;
import com.example.SCM.entity.User;
import org.springframework.stereotype.Component;

@Component("scmAdminMapperServiceNode")
public class AdminMapper {


    public AdminResponse toResponse(Admin entity) {
        if (entity == null) return null;

        AdminResponse dto = new AdminResponse();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setPhone(entity.getPhone());
        dto.setEmail(entity.getEmail());


        if (entity.getUser() != null) {
            User user = entity.getUser();
            dto.setUserId(user.getId());
            dto.setPhoneNumber(user.getPhoneNumber());
            dto.setActive(user.isActive());

            if (user.getRole() != null) {
                dto.setRole(user.getRole());
            }
        }

        return dto;
    }


    public void updateEntity(AdminRequest request, Admin entity) {
        if (request.getName() != null) {
            entity.setName(request.getName());
        }

        if (request.getPhone() != null) {
            entity.setPhone(request.getPhone());
        }

        if (request.getEmail() != null) {
            entity.setEmail(request.getEmail());
        }


        if (entity.getUser() != null) {
            User user = entity.getUser();

            if (request.getName() != null) {
                user.setName(request.getName());
            }

            if (request.getPhone() != null) {
                user.setPhoneNumber(request.getPhone());
            }

            if (request.getEmail() != null) {
                user.setEmail(request.getEmail());
            }
        }
    }
}