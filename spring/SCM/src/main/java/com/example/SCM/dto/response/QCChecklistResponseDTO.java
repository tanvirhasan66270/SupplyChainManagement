package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class QCChecklistResponseDTO {
    private Long id;
    private String checkpointName;
    private boolean isPassed;
    private String remarks;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    //  Flattened QC Inspection Details ---
    private Long inspectionId;
    private String inspectionType;
}