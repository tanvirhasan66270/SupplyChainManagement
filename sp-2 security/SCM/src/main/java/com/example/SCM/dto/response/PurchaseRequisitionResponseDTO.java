package com.example.SCM.dto.response;

import com.example.SCM.enumClass.PurchaseRequisitionStatus;
import com.example.SCM.enumClass.UrgencyLevel;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class PurchaseRequisitionResponseDTO {
    private Long id;
    private Long requestedBy;
    private String currency;
    private int quantityRequired;
    private UrgencyLevel urgencyLevel;
    private LocalDate requiredByDate;
    private PurchaseRequisitionStatus approvalStatus;
    private Long approvedBy;
    private String approvedByName;
    private String remarks;
    private LocalDateTime createdAt;

    private List<Long> productIds;
    private List<String> productNames;
    private List<Long> supplierIds;
    private List<String> supplierNames;

}