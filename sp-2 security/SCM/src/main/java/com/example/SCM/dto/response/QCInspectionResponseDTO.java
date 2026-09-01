package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class QCInspectionResponseDTO {
    private Long id;
    private String inspectionType;
    private int sampleSize;
    private int defectsFound;
    private String defectDescription;
    private String result;
    private String certificateRef;
    private String labTestReport;
    private LocalDate inspectedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // --- Flattened Relations for UI ---
    private Long grnId;
    private String grnNumber;

    private Long productId;
    private String productName;

    private Long inspectedBy;
    private String inspectedByName;

    private List<QCChecklistResponseDTO> checklists;
}