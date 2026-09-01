package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.GoodsReceivedNoteRequestDTO;
import com.example.SCM.dto.response.GoodsReceivedNoteResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.GRNStatus;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;


@Component
@RequiredArgsConstructor
public class GoodsReceivedNoteMapper {

    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");


    public GoodsReceivedNoteResponseDTO convertTOResponseDTO(GoodsReceivedNote grn) {


        GoodsReceivedNoteResponseDTO dto = new GoodsReceivedNoteResponseDTO();

        dto.setId(grn.getId());
        dto.setGrnNumber(grn.getGrnNumber());
        dto.setQuantity(grn.getQuantity());
        dto.setReceivedQuantity(grn.getReceivedQuantity());
        dto.setReceivedAt(grn.getReceivedAt());
        dto.setStatus(grn.getStatus());
        dto.setRemarks(grn.getRemarks());
        dto.setInspectionDate(grn.getInspectionDate());
        dto.setCreatedAt(grn.getCreatedAt());
        dto.setUpdatedAt(grn.getUpdatedAt());

        if (grn.getPurchaseOrder() != null) {
            dto.setPoId(grn.getPurchaseOrder().getId());
            dto.setPoNumber(grn.getPurchaseOrder().getPoNumber());
        }

        if (grn.getProduct() != null) {
            dto.setProductId(grn.getProduct().getId());
            dto.setProductName(grn.getProduct().getName());
        }

        if (grn.getWarehouse() != null) {
            dto.setWarehouseId(grn.getWarehouse().getId());
            dto.setWarehouseName(grn.getWarehouse().getName());
        }

        if (grn.getReceivedBy() != null) {
            dto.setReceivedBy(grn.getReceivedBy().getId());
            dto.setReceivedByName(grn.getReceivedBy().getName());
        }

        if (grn.getInspectedBy() != null) {
            dto.setInspectedBy(grn.getInspectedBy().getId());
            dto.setInspectedByName(grn.getInspectedBy().getName());
        }

        return dto;
    }


    public GoodsReceivedNote toEntity(GoodsReceivedNoteRequestDTO dto, PurchaseOrder po, Product product, User receivedBy, Warehouse warehouse, User inspectedBy) {

        // Create Note Entity
        GoodsReceivedNote grn = new GoodsReceivedNote();

        grn.setReceivedQuantity(dto.getReceivedQuantity());
        grn.setRemarks(dto.getRemarks());

        if (dto.getReceivedAt() != null && !dto.getReceivedAt().trim().isEmpty()) {
            grn.setReceivedAt(LocalDate.parse(dto.getReceivedAt(), dateFormatter));
        } else {
            grn.setReceivedAt(LocalDate.now());
        }

        if (dto.getInspectionDate() != null && !dto.getInspectionDate().trim().isEmpty()) {
            grn.setInspectionDate(LocalDate.parse(dto.getInspectionDate(), dateFormatter));
        }

        if (dto.getStatus() != null && !dto.getStatus().trim().isEmpty()) {
            grn.setStatus(GRNStatus.valueOf(dto.getStatus().toUpperCase()));
        } else {
            grn.setStatus(GRNStatus.PENDING);
        }

        grn.setPurchaseOrder(po);
        grn.setProduct(product);
        grn.setReceivedBy(receivedBy);
        grn.setWarehouse(warehouse);
        grn.setInspectedBy(inspectedBy);

        return grn;
    }


    public void updateEntity(GoodsReceivedNoteRequestDTO dto, GoodsReceivedNote grn, PurchaseOrder po, Product product, Warehouse warehouse, User inspectedBy) {
        if (dto == null || grn == null) {
            return;
        }

        grn.setReceivedQuantity(dto.getReceivedQuantity());
        grn.setRemarks(dto.getRemarks());

        if (dto.getReceivedAt() != null && !dto.getReceivedAt().trim().isEmpty()) {
            grn.setReceivedAt(LocalDate.parse(dto.getReceivedAt(), dateFormatter));
        }
        if (dto.getInspectionDate() != null && !dto.getInspectionDate().trim().isEmpty()) {
            grn.setInspectionDate(LocalDate.parse(dto.getInspectionDate(), dateFormatter));
        }

        if (dto.getStatus() != null && !dto.getStatus().trim().isEmpty()) {
            grn.setStatus(GRNStatus.valueOf(dto.getStatus().toUpperCase()));
        }

        if (po != null) grn.setPurchaseOrder(po);
        if (product != null) grn.setProduct(product);
        if (warehouse != null) grn.setWarehouse(warehouse);
        if (inspectedBy != null) grn.setInspectedBy(inspectedBy);
    }

}