package com.example.SCM.service;

import com.example.SCM.dto.request.QCChecklistRequestDTO;
import com.example.SCM.dto.response.QCChecklistResponseDTO;

import java.util.List;
import java.util.Optional;

public interface QCChecklistService {
    QCChecklistResponseDTO save(QCChecklistRequestDTO dto);
    QCChecklistResponseDTO update(Long id, QCChecklistRequestDTO dto);
    List<QCChecklistResponseDTO> findByInspectionId(Long inspectionId);
    Optional<QCChecklistResponseDTO> getById(Long id);
    void delete(Long id);
}