package com.example.SCM.service;

import com.example.SCM.dto.request.QCInspectorRequestDTO;
import com.example.SCM.dto.response.DriverResponseDTO;
import com.example.SCM.dto.response.QCInspectorResponseDTO;
import com.example.SCM.entity.QCInspector;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

public interface QCInspectorService {
    QCInspectorResponseDTO save(QCInspectorRequestDTO dto, MultipartFile image);

    QCInspectorResponseDTO update(Long id, QCInspectorRequestDTO dto, MultipartFile image);

    List<QCInspectorResponseDTO> findAll();
    Optional<QCInspectorResponseDTO> getById(Long id);
    void delete(Long id);
    Optional<QCInspectorResponseDTO> findUserById(Long id);


}