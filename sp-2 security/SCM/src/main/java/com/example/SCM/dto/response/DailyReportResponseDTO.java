package com.example.SCM.dto.response;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
public class DailyReportResponseDTO {
    private Long id;
    private String userId;
    private String warehouseId;
    private String reportDate;
    private int totalTasksDone;
    private int issuesLogged;
    private String summary;
    private String reportStatus;
    private String attachmentUrl;
    private String generatedAt;
    private String updatedAt;

    private List<Map<String, String>> notifiedAuthorities = new ArrayList<>();
}