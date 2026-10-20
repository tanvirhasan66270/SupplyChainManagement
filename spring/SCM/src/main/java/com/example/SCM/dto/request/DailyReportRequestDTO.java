package com.example.SCM.dto.request;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class DailyReportRequestDTO {
    private String warehouseId;
    private String reportDate;
    private int totalTasksDone;
    private int issuesLogged;
    private String summary;
    private MultipartFile attachment;
}