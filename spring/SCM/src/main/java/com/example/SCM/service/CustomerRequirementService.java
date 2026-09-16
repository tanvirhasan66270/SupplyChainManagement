package com.example.SCM.service;

import com.example.SCM.entity.CustomerRequirement;
import com.example.SCM.dto.request.CustomerRequirementRequest;
import com.example.SCM.dto.response.CustomerRequirementResponse;
import java.util.List;

public interface CustomerRequirementService {
    CustomerRequirementResponse save(CustomerRequirementRequest requirement);
    List<CustomerRequirementResponse> getAll();
    CustomerRequirementResponse getById(Long id);
    CustomerRequirementResponse updateStatus(Long id, String status);
    void delete(Long id);
}
