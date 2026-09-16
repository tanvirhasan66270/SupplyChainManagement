package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.CustomerRequirementRequest;
import com.example.SCM.dto.response.CustomerRequirementResponse;
import com.example.SCM.entity.CustomerRequirement;
import org.springframework.stereotype.Component;

@Component
public class CustomerRequirementMapper {

    public CustomerRequirement toEntity(CustomerRequirementRequest request) {
        if (request == null) {
            return null;
        }

        CustomerRequirement entity = new CustomerRequirement();
        entity.setProductName(request.getProductName());
        entity.setProductDescription(request.getProductDescription());
        entity.setCustomerName(request.getCustomerName());
        entity.setContactNumber(request.getContactNumber());
        entity.setEmail(request.getEmail());
        
        return entity;
    }

    public CustomerRequirementResponse toResponse(CustomerRequirement entity) {
        if (entity == null) {
            return null;
        }

        CustomerRequirementResponse response = new CustomerRequirementResponse();
        response.setId(entity.getId());
        response.setProductName(entity.getProductName());
        response.setProductDescription(entity.getProductDescription());
        response.setCustomerName(entity.getCustomerName());
        response.setContactNumber(entity.getContactNumber());
        response.setEmail(entity.getEmail());
        response.setStatus(entity.getStatus());
        response.setCreatedAt(entity.getCreatedAt());
        
        return response;
    }
}
