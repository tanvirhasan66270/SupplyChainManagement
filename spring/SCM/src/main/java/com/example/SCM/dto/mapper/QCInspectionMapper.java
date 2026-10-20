package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.QCInspectionRequestDTO;
import com.example.SCM.dto.response.QCInspectionResponseDTO;
import com.example.SCM.dto.response.QCChecklistResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.ResultStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.stream.Collectors;

@Component
public class QCInspectionMapper {

    public QCInspectionResponseDTO convertTOResponseDTO(QCInspection entity) {

        QCInspectionResponseDTO dto = new QCInspectionResponseDTO();
        dto.setId(entity.getId());
        dto.setInspectionType(entity.getInspectionType());
        dto.setSampleSize(entity.getSampleSize());
        dto.setDefectsFound(entity.getDefectsFound());
        dto.setDefectDescription(entity.getDefectDescription());
        dto.setResult(entity.getResult() != null ? entity.getResult().name() : null);
        dto.setCertificateRef(entity.getCertificateRef());
        dto.setLabTestReport(entity.getLabTestReport());
        dto.setInspectedAt(entity.getInspectedAt());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        if (entity.getGoodsReceivedNote() != null) {
            dto.setGrnId(entity.getGoodsReceivedNote().getId());
            dto.setGrnNumber(entity.getGoodsReceivedNote().getGrnNumber());
        }
        if (entity.getProduct() != null) {
            dto.setProductId(entity.getProduct().getId());
            dto.setProductName(entity.getProduct().getName());
        }
        if (entity.getInspectedBy() != null) {
            dto.setInspectedBy(entity.getInspectedBy().getId());
            dto.setInspectedByName(entity.getInspectedBy().getName());
        }

        if (entity.getChecklists() != null) {
            dto.setChecklists(entity.getChecklists().stream().map(chk -> {
                QCChecklistResponseDTO cDto = new QCChecklistResponseDTO();
                cDto.setId(chk.getId());
                cDto.setCheckpointName(chk.getCheckpointName());
                cDto.setPassed(chk.isPassed());
                cDto.setRemarks(chk.getRemarks());

                cDto.setCreatedAt(chk.getCreatedAt());
                cDto.setUpdatedAt(chk.getUpdatedAt());

                cDto.setInspectionId(entity.getId());
                cDto.setInspectionType(entity.getInspectionType());
                return cDto;
            }).collect(Collectors.toList()));
        }

        return dto;
    }

    public QCInspection toEntity(QCInspectionRequestDTO dto, GoodsReceivedNote grn, Product product, User inspector) {

        QCInspection entity = new QCInspection();
        entity.setInspectionType(dto.getInspectionType());
        entity.setSampleSize(dto.getSampleSize());
        entity.setDefectsFound(dto.getDefectsFound());
        entity.setDefectDescription(dto.getDefectDescription());
        entity.setCertificateRef(dto.getCertificateRef());
        entity.setLabTestReport(dto.getLabTestReport());

        if (dto.getResult() != null) {
            entity.setResult(ResultStatus.valueOf(dto.getResult().toUpperCase()));
        }
        if (dto.getInspectedAt() != null && !dto.getInspectedAt().isEmpty()) {
            entity.setInspectedAt(LocalDate.parse(dto.getInspectedAt()));
        }

        entity.setGoodsReceivedNote(grn);
        entity.setProduct(product);
        entity.setInspectedBy(inspector);

        return entity;
    }

    public void updateEntity(QCInspectionRequestDTO dto, QCInspection entity, GoodsReceivedNote grn, Product product, User inspector) {

        entity.setInspectionType(dto.getInspectionType());
        entity.setSampleSize(dto.getSampleSize());
        entity.setDefectsFound(dto.getDefectsFound());
        entity.setDefectDescription(dto.getDefectDescription());
        entity.setCertificateRef(dto.getCertificateRef());

        if (dto.getResult() != null) {
            entity.setResult(ResultStatus.valueOf(dto.getResult().toUpperCase()));
        }
        if (dto.getInspectedAt() != null && !dto.getInspectedAt().isEmpty()) {
            entity.setInspectedAt(LocalDate.parse(dto.getInspectedAt()));
        }

        if (grn != null) entity.setGoodsReceivedNote(grn);
        if (product != null) entity.setProduct(product);
        if (inspector != null) entity.setInspectedBy(inspector);
    }
}