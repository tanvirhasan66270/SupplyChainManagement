package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.QCChecklistRequestDTO;
import com.example.SCM.dto.response.QCChecklistResponseDTO;
import com.example.SCM.entity.QCChecklist;
import com.example.SCM.entity.QCInspection;
import org.springframework.stereotype.Component;

@Component
public class QCChecklistMapper {

    public QCChecklistResponseDTO convertTOResponseDTO(QCChecklist entity) {

        QCChecklistResponseDTO dto = new QCChecklistResponseDTO();
        dto.setId(entity.getId());
        dto.setCheckpointName(entity.getCheckpointName());
        dto.setPassed(entity.isPassed());
        dto.setRemarks(entity.getRemarks());

        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        if (entity.getQcInspection() != null) {
            dto.setInspectionId(entity.getQcInspection().getId());
            dto.setInspectionType(entity.getQcInspection().getInspectionType());
        }

        return dto;
    }

    public QCChecklist toEntity(QCChecklistRequestDTO dto, QCInspection inspection) {

        QCChecklist entity = new QCChecklist();
        entity.setCheckpointName(dto.getCheckpointName());
        entity.setPassed(dto.isPassed());
        entity.setRemarks(dto.getRemarks());

        entity.setQcInspection(inspection);

        return entity;
    }

    public void updateEntity(QCChecklistRequestDTO dto, QCChecklist entity, QCInspection inspection) {
        if (dto == null || entity == null) {
            return;
        }

        entity.setCheckpointName(dto.getCheckpointName());
        entity.setPassed(dto.isPassed());
        entity.setRemarks(dto.getRemarks());

        if (inspection != null) {
            entity.setQcInspection(inspection);
        }
    }
}