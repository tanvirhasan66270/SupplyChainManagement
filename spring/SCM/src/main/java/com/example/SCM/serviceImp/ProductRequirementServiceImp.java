package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.ProductRequirementMapper;
import com.example.SCM.dto.request.ProductRequirementRequestDTO;
import com.example.SCM.dto.response.ProductRequirementResponseDTO;
import com.example.SCM.entity.ProductRequirement;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.ProductRequestStatus;
import com.example.SCM.repository.ProductRequirementRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.NotificationService;
import com.example.SCM.service.ProductRequirementService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductRequirementServiceImp implements ProductRequirementService {

    private final ProductRequirementRepository repository;
    private final ProductRequirementMapper mapper;

    private final NotificationService notificationService;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public ProductRequirementResponseDTO save(ProductRequirementRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("ProductRequirement data cannot be null");
        ProductRequirement entity = mapper.toEntity(dto);
        ProductRequirement saved = repository.save(entity);

        try {
            List<User> targetUsers = userRepository.findByRole(Role.PROCUREMENT);

            for (User user : targetUsers) {
                notificationService.send(
                        user.getId().toString(),
                        "PRODUCT_REQUIREMENT",
                        "New Product Requirement: " + saved.getProductName(),
                        "A new product requirement has been requested. Qty: " + saved.getRequestedQuantity() + " " + saved.getUnit()
                );
            }
        } catch (Exception e) {
            System.err.println("Error sending notification for Product Requirement creation: " + e.getMessage());
        }


        return mapper.toResponseDTO(saved);
    }

    //  LOGISTICS_OFFICER update করতে পারবে
    @Override
    @Transactional
    public ProductRequirementResponseDTO update(Long id, ProductRequirementRequestDTO dto) {
        ProductRequirement entity = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("ProductRequirement not found with ID: " + id));

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isLogisticsOfficer = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_LOGISTICS_OFFICER"));

        if (isLogisticsOfficer && entity.getStatus() == ProductRequestStatus.APPROVED) {
            throw new RuntimeException(
                "Access Denied: This requirement is already APPROVED. Logistics Officer cannot modify an approved requirement."
            );
        }

        mapper.updateEntity(dto, entity);
        ProductRequirement updated = repository.save(entity);
        return mapper.toResponseDTO(updated);
    }

    @Override
    @Transactional
    public ProductRequirementResponseDTO updateStatus(Long id, String status) {
        ProductRequirement entity = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("ProductRequirement not found with ID: " + id));

        try {
            entity.setStatus(ProductRequestStatus.valueOf(status.toUpperCase()));
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status value: " + status + ". Allowed: PENDING, APPROVED, REJECTED, PROCESSING");
        }

        ProductRequirement updated = repository.save(entity);
        return mapper.toResponseDTO(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductRequirementResponseDTO> findAll() {
        return repository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(mapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ProductRequirementResponseDTO> getById(Long id) {
        return repository.findById(id).map(mapper::toResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new EntityNotFoundException("ProductRequirement not found with ID: " + id);
        }
        repository.deleteById(id);
    }
}
