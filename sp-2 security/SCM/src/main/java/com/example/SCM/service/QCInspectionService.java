package com.example.SCM.service;



import com.example.SCM.dto.request.QCInspectionRequestDTO;
import com.example.SCM.dto.response.QCInspectionResponseDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

public interface QCInspectionService {
    QCInspectionResponseDTO save(QCInspectionRequestDTO dto, MultipartFile file);
    QCInspectionResponseDTO update(Long id, QCInspectionRequestDTO dto,MultipartFile file);
    List<QCInspectionResponseDTO> findAll();
    Optional<QCInspectionResponseDTO> getById(Long id);
    void delete(Long id);
}
