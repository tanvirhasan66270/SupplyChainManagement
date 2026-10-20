package com.example.SCM.dto.response;

import com.example.SCM.enumClass.GRNStatus;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class GoodsReceivedNoteResponseDTO {
    private Long id;
    private String grnNumber;
    private Integer quantity;
    private int receivedQuantity;
    private LocalDate receivedAt;
    private GRNStatus status;
    private String remarks;
    private LocalDate inspectionDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;


    private Long poId;
    private String poNumber;

    private Long productId;
    private String productName;

    private Long warehouseId;
    private String warehouseName;

    private Long receivedBy;
    private String receivedByName;

    private Long inspectedBy;
    private String inspectedByName;

}