package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.PurchaseRequisitionRequestDTO;
import com.example.SCM.dto.response.PurchaseRequisitionResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.PurchaseRequisitionStatus;
import com.example.SCM.enumClass.UrgencyLevel;
import com.example.SCM.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class PurchaseRequisitionMapper {

    private final UserRepository userRepository;
    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");


    public PurchaseRequisition toEntity(PurchaseRequisitionRequestDTO dto, List<Product> products, List<Supplier> suppliers) {
        if (dto == null) return null;

        PurchaseRequisition pr = new PurchaseRequisition();
        pr.setRequestedBy(dto.getRequestedBy());
        pr.setCurrency(dto.getCurrency() != null ? dto.getCurrency() : "USD");
        pr.setQuantityRequired(dto.getQuantityRequired());
        pr.setRemarks(dto.getRemarks());

        if (dto.getRequiredByDate() != null && !dto.getRequiredByDate().trim().isEmpty()) {
            pr.setRequiredByDate(LocalDate.parse(dto.getRequiredByDate(), dateFormatter));
        }

        if (dto.getUrgencyLevel() != null) {
            pr.setUrgencyLevel(UrgencyLevel.valueOf(dto.getUrgencyLevel().toUpperCase()));
        }

        if (products != null) {
            pr.setProducts(new LinkedHashSet<>(products));
        }
        if (suppliers != null) {
            pr.setSuppliers(new LinkedHashSet<>(suppliers));
        }

        pr.setApprovalStatus(PurchaseRequisitionStatus.PENDING);

        return pr;
    }


    public PurchaseRequisitionResponseDTO convertTOResponseDTO(PurchaseRequisition pr) {
        if (pr == null) return null;

        PurchaseRequisitionResponseDTO dto = new PurchaseRequisitionResponseDTO();
        dto.setId(pr.getId());
        dto.setRequestedBy(pr.getRequestedBy());
        dto.setCurrency(pr.getCurrency());
        dto.setQuantityRequired(pr.getQuantityRequired());
        dto.setUrgencyLevel(pr.getUrgencyLevel());
        dto.setRequiredByDate(pr.getRequiredByDate());
        dto.setApprovalStatus(pr.getApprovalStatus());
        dto.setRemarks(pr.getRemarks());
        dto.setCreatedAt(pr.getCreatedAt());

        if (pr.getApprovedBy() != null) {
            dto.setApprovedBy(pr.getApprovedBy());
            userRepository.findById(pr.getApprovedBy()).ifPresent(user -> {
                dto.setApprovedByName(user.getName());
            });
        }

        if (pr.getProducts() != null) {
            dto.setProductIds(pr.getProducts().stream().map(Product::getId).collect(Collectors.toList()));
            dto.setProductNames(pr.getProducts().stream().map(Product::getName).collect(Collectors.toList()));
        }

        if (pr.getSuppliers() != null) {
            dto.setSupplierIds(pr.getSuppliers().stream().map(Supplier::getId).collect(Collectors.toList()));
            dto.setSupplierNames(pr.getSuppliers().stream().map(Supplier::getName).collect(Collectors.toList()));
        }

        return dto;
    }


    public void updateEntity(PurchaseRequisitionRequestDTO dto, PurchaseRequisition pr, List<Product> products, List<Supplier> suppliers) {
        if (dto == null || pr == null) return;

        if (dto.getRequestedBy() != null) pr.setRequestedBy(dto.getRequestedBy());
        if (dto.getCurrency() != null) pr.setCurrency(dto.getCurrency());
        pr.setQuantityRequired(dto.getQuantityRequired());
        if (dto.getRemarks() != null) pr.setRemarks(dto.getRemarks());

        if (dto.getRequiredByDate() != null && !dto.getRequiredByDate().trim().isEmpty()) {
            pr.setRequiredByDate(LocalDate.parse(dto.getRequiredByDate(), dateFormatter));
        }

        if (dto.getUrgencyLevel() != null) {
            pr.setUrgencyLevel(UrgencyLevel.valueOf(dto.getUrgencyLevel().toUpperCase()));
        }

        if (products != null) {
            pr.setProducts(new LinkedHashSet<>(products));
        }
        if (suppliers != null) {
            pr.setSuppliers(new LinkedHashSet<>(suppliers));
        }
    }
}