package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.DailyReportRequestDTO;
import com.example.SCM.dto.response.DailyReportResponseDTO;
import com.example.SCM.entity.DailyReport;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
public class DailyReportMapper {


    public DailyReport toEntity(DailyReportRequestDTO dto) {
        if (dto == null) return null;

        DailyReport report = new DailyReport();
        report.setWarehouseId(dto.getWarehouseId());
        report.setTotalTasksDone(dto.getTotalTasksDone());
        report.setIssuesLogged(dto.getIssuesLogged());
        report.setSummary(dto.getSummary());

        if (dto.getReportDate() != null && !dto.getReportDate().isBlank()) {
            report.setReportDate(LocalDate.parse(dto.getReportDate()));
        }
        return report;
    }





    public DailyReportResponseDTO convertTOResponseDTO(DailyReport entity) {
        if (entity == null) return null;

        DailyReportResponseDTO dto = new DailyReportResponseDTO();
        dto.setId(entity.getId());
        dto.setUserId(entity.getUserId());
        dto.setWarehouseId(entity.getWarehouseId());
        dto.setSummary(entity.getSummary());
        dto.setTotalTasksDone(entity.getTotalTasksDone());
        dto.setIssuesLogged(entity.getIssuesLogged());

        dto.setAttachmentUrl(entity.getAttachmentUrl());

        if (entity.getReportStatus() != null) {
            dto.setReportStatus(entity.getReportStatus().name());
        }

        if (entity.getReportDate() != null) dto.setReportDate(entity.getReportDate().toString());
        if (entity.getGeneratedAt() != null) dto.setGeneratedAt(entity.getGeneratedAt().toString());
        if (entity.getUpdatedAt() != null) dto.setUpdatedAt(entity.getUpdatedAt().toString());

        return dto;
    }
}