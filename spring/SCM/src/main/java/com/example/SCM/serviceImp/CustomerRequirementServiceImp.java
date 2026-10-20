package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.CustomerRequirementMapper;
import com.example.SCM.dto.request.CustomerRequirementRequest;
import com.example.SCM.dto.response.CustomerRequirementResponse;
import com.example.SCM.entity.CustomerRequirement;
import com.example.SCM.repository.CustomerRequirementRepository;
import com.example.SCM.service.CustomerRequirementService;
import com.example.SCM.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerRequirementServiceImp implements CustomerRequirementService {

    private final CustomerRequirementRepository repository;
    private final NotificationService notificationService;
    private final CustomerRequirementMapper mapper;

    @Override
    public CustomerRequirementResponse save(CustomerRequirementRequest request) {
        CustomerRequirement entity = mapper.toEntity(request);
        CustomerRequirement saved = repository.save(entity);
        String msg = "New product requirement submitted by " + saved.getCustomerName() + " for " + saved.getProductName();
        
        notificationService.send("SALES_OFFICER", "CUSTOMER_REQ", "New Customer Requirement", msg);
        notificationService.send("LOGISTICS_OFFICER", "CUSTOMER_REQ", "New Customer Requirement", msg);
        
        return mapper.toResponse(saved);
    }

    @Override
    public List<CustomerRequirementResponse> getAll() {
        return repository.findAll().stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CustomerRequirementResponse getById(Long id) {
        return repository.findById(id)
                .map(mapper::toResponse)
                .orElse(null);
    }

    @Override
    public CustomerRequirementResponse updateStatus(Long id, String status) {
        CustomerRequirement req = repository.findById(id).orElse(null);
        if (req != null) {
            req.setStatus(status);
            CustomerRequirement updated = repository.save(req);
            
            String msg = "Customer Requirement for " + updated.getProductName() + " status updated to " + status;
            notificationService.send("SALES_OFFICER", "CUSTOMER_REQ", "Customer Requirement Updated", msg);
            notificationService.send("LOGISTICS_OFFICER", "CUSTOMER_REQ", "Customer Requirement Updated", msg);
            
            return mapper.toResponse(updated);
        }
        return null;
    }

    @Override
    public void delete(Long id) {
        repository.deleteById(id);
    }
}
