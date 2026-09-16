package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.QuotationRequestDTO;
import com.example.SCM.dto.response.QuotationResponseDTO;
import com.example.SCM.entity.PurchaseRequisition; // আপনার সিস্টেমের পিআর এনটিটি
import com.example.SCM.entity.Quotation;
import com.example.SCM.entity.Supplier;
import com.example.SCM.enumClass.QuotationStatus;
import jakarta.persistence.EntityManager;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Component
public class QuotationMapper {

    private final EntityManager entityManager;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public QuotationMapper(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public Quotation toEntity(QuotationRequestDTO dto) {
        if (dto == null) {
            return null;
        }

        Quotation quotation = new Quotation();

        if (dto.getReceivedAt() != null && !dto.getReceivedAt().isBlank()) {
            quotation.setReceivedAt(LocalDate.parse(dto.getReceivedAt(), DATE_FORMATTER));
        }
        if (dto.getDeliveryTime() != null && !dto.getDeliveryTime().isBlank()) {
            quotation.setDeliveryTime(LocalDate.parse(dto.getDeliveryTime(), DATE_FORMATTER));
        }

        // Lazy Proxy references resolution
        if (dto.getSupplierId() != null) {
            quotation.setSupplier(entityManager.getReference(Supplier.class, dto.getSupplierId()));
        }
        if (dto.getPurchaseRequisitionId() != null) {
            quotation.setPurchaseRequisition(entityManager.getReference(PurchaseRequisition.class, dto.getPurchaseRequisitionId()));
        }

        quotation.setLeadTimeDays(dto.getLeadTimeDays());

        quotation.setProductDescription(dto.getProductDescription());
        quotation.setUnitPrice(dto.getUnitPrice());
        quotation.setQuantity(dto.getQuantity());
        quotation.setWarranty(dto.getWarranty());
        quotation.setNotes(dto.getNotes());
        quotation.setAttachmentUrl(dto.getAttachmentUrl());

        if (dto.getStatus() != null) {
            quotation.setStatus(QuotationStatus.valueOf(dto.getStatus().toUpperCase()));
        }

        return quotation;
    }

    public QuotationResponseDTO toResponseDTO(Quotation quotation) {
        if (quotation == null) {
            return null;
        }

        QuotationResponseDTO dto = new QuotationResponseDTO();

        dto.setId(quotation.getId());
        dto.setQuotationNumber(quotation.getQuotationNumber());
        dto.setValidUntil(quotation.getValidUntil());
        dto.setLeadTimeDays(quotation.getLeadTimeDays());
        dto.setReceivedAt(quotation.getReceivedAt());
        dto.setStatus(quotation.getStatus());
        dto.setProductDescription(quotation.getProductDescription());
        dto.setUnitPrice(quotation.getUnitPrice());
        dto.setQuantity(quotation.getQuantity());
        dto.setTotalPrice(quotation.getTotalPrice());
        dto.setDeliveryTime(quotation.getDeliveryTime());
        dto.setWarranty(quotation.getWarranty());
        dto.setNotes(quotation.getNotes());
        dto.setAttachmentUrl(quotation.getAttachmentUrl());
        dto.setCreatedAt(quotation.getCreatedAt());

        // Supplier Flattening
        if (quotation.getSupplier() != null) {
            dto.setSupplierId(quotation.getSupplier().getId());
            dto.setSupplierName(quotation.getSupplier().getName());
            dto.setEmail(quotation.getSupplier().getEmail());
        }

        if (quotation.getPurchaseRequisition() != null) {
            dto.setPurchaseRequisitionId(quotation.getPurchaseRequisition().getId());
            dto.setProductName(quotation.getProductName()); // ডাটাবেজে স্টোর হওয়া নামের স্ন্যাপশট
        }

        return dto;
    }

    public void updateEntityFromDTO(QuotationRequestDTO dto, Quotation quotation) {
        if (dto == null || quotation == null) {
            return;
        }

        if (dto.getReceivedAt() != null && !dto.getReceivedAt().isBlank()) {
            quotation.setReceivedAt(LocalDate.parse(dto.getReceivedAt(), DATE_FORMATTER));
        }
        if (dto.getDeliveryTime() != null && !dto.getDeliveryTime().isBlank()) {
            quotation.setDeliveryTime(LocalDate.parse(dto.getDeliveryTime(), DATE_FORMATTER));
        }

        if (dto.getSupplierId() != null) {
            quotation.setSupplier(entityManager.getReference(Supplier.class, dto.getSupplierId()));
        }
        if (dto.getPurchaseRequisitionId() != null) {
            quotation.setPurchaseRequisition(entityManager.getReference(PurchaseRequisition.class, dto.getPurchaseRequisitionId()));
        }

        quotation.setLeadTimeDays(dto.getLeadTimeDays());

        quotation.setProductDescription(dto.getProductDescription());
        quotation.setUnitPrice(dto.getUnitPrice());
        quotation.setQuantity(dto.getQuantity());
        quotation.setWarranty(dto.getWarranty());
        quotation.setNotes(dto.getNotes());
        quotation.setAttachmentUrl(dto.getAttachmentUrl());

        if (dto.getStatus() != null) {
            quotation.setStatus(QuotationStatus.valueOf(dto.getStatus().toUpperCase()));
        }
    }
}