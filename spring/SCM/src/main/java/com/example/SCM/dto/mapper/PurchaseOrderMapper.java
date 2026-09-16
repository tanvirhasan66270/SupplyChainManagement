package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.PurchaseOrderRequestDTO;
import com.example.SCM.dto.response.PurchaseOrderResponseDTO;
import com.example.SCM.entity.PurchaseOrder;
import com.example.SCM.entity.PurchaseRequisition;
import com.example.SCM.entity.Quotation;
import com.example.SCM.entity.Supplier;
import com.example.SCM.enumClass.PurchaseOrderStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Component
public class PurchaseOrderMapper {

    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public PurchaseOrderResponseDTO convertTOResponseDTO(PurchaseOrder po) {
        if (po == null) {
            return null;
        }

        PurchaseOrderResponseDTO dto = new PurchaseOrderResponseDTO();

        dto.setId(po.getId());
        dto.setPoNumber(po.getPoNumber());
        dto.setQuantity(po.getQuantity());
        dto.setTotalAmount(po.getTotalAmount());
        dto.setCurrency(po.getCurrency());
        dto.setExpectedDeliveryDate(po.getExpectedDeliveryDate());
        dto.setStatus(po.getStatus());
        dto.setIssuedBy(po.getIssuedBy());
        dto.setCreatedAt(po.getCreatedAt());
        dto.setUpdatedAt(po.getUpdatedAt());

        try {
            if (po.getSupplier() != null) {
                dto.setSupplierId(po.getSupplier().getId());
                dto.setSupplierName(po.getSupplier().getName());
                dto.setSupplierEmail(po.getSupplier().getEmail());
            } else if (po.getQuotation() != null && po.getQuotation().getSupplier() != null) {
                dto.setSupplierId(po.getQuotation().getSupplier().getId());
                dto.setSupplierName(po.getQuotation().getSupplier().getName());
                dto.setSupplierEmail(po.getQuotation().getSupplier().getEmail());
            }
        } catch (Exception e) {
        }
        try {
            PurchaseRequisition pr = null;
            if (po.getPurchaseRequisition() != null) {
                pr = po.getPurchaseRequisition();
            } else if (po.getQuotation() != null && po.getQuotation().getPurchaseRequisition() != null) {
                pr = po.getQuotation().getPurchaseRequisition();
            }
            
            if (pr != null) {
                dto.setPurchaseRequisitionId(pr.getId());
                if (pr.getProducts() != null) {
                    dto.setProductIds(pr.getProducts().stream().map(com.example.SCM.entity.Product::getId).collect(java.util.stream.Collectors.toList()));
                    dto.setProductNames(pr.getProducts().stream().map(com.example.SCM.entity.Product::getName).collect(java.util.stream.Collectors.toList()));
                }
            }
        } catch (Exception e) {
        }

        if (po.getQuotation() != null) {
            dto.setQuotationId(po.getQuotation().getId());
        }

        return dto;
    }

    public PurchaseOrder toEntity(PurchaseOrderRequestDTO dto, Quotation quotation, Supplier supplier, PurchaseRequisition pr) {
        PurchaseOrder po = new PurchaseOrder();

        po.setTotalAmount(dto.getTotalAmount());
        po.setIssuedBy(dto.getIssuedBy());
        po.setCurrency(dto.getCurrency() != null ? dto.getCurrency() : "USD");

        if (quotation != null && quotation.getQuantity() != null) {
            po.setQuantity(quotation.getQuantity());
        }

        if (dto.getExpectedDeliveryDate() != null && !dto.getExpectedDeliveryDate().trim().isEmpty()) {
            po.setExpectedDeliveryDate(LocalDate.parse(dto.getExpectedDeliveryDate(), dateFormatter));
        }

        po.setStatus(PurchaseOrderStatus.DRAFT);
        po.setQuotation(quotation);
        po.setSupplier(supplier);
        po.setPurchaseRequisition(pr);

        return po;
    }

    public void updateEntity(PurchaseOrderRequestDTO dto, PurchaseOrder po, Quotation quotation, Supplier supplier, PurchaseRequisition pr) {
        if (dto == null || po == null) {
            return;
        }

        po.setTotalAmount(dto.getTotalAmount());
        po.setIssuedBy(dto.getIssuedBy());

        if (dto.getCurrency() != null) {
            po.setCurrency(dto.getCurrency());
        }

        if (quotation != null && quotation.getQuantity() != null) {
            po.setQuantity(quotation.getQuantity());
        }

        if (dto.getExpectedDeliveryDate() != null && !dto.getExpectedDeliveryDate().trim().isEmpty()) {
            po.setExpectedDeliveryDate(LocalDate.parse(dto.getExpectedDeliveryDate(), dateFormatter));
        }

        if (quotation != null) po.setQuotation(quotation);
        if (supplier != null) po.setSupplier(supplier);
        if (pr != null) po.setPurchaseRequisition(pr);
    }
}
