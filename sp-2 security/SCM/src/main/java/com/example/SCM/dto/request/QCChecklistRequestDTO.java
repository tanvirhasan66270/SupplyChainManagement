package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class QCChecklistRequestDTO {
    private Long inspectionId; // FK → QCInspection
    private String checkpointName;
    private boolean isPassed;
    private String remarks;
}