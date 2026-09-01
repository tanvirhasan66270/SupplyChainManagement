package com.example.SCM.dto.request;

import lombok.Data;

import java.util.List;

@Data
public class GoodsReceivedNoteRequestDTO {
    private Long poId;
    private Long productId;
    private int receivedQuantity;
    private Long receivedBy;
    private Long warehouseId;
    private String receivedAt;       // "YYYY-MM-DD"
    private String status;           // PENDING, RECEIVED, APPROVED
    private String remarks;
    private Long inspectedBy;
    private String inspectionDate;   // "YYYY-MM-DD"

    private List<GRNLineItemRequestDTO> lineItems;
}