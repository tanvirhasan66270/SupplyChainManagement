package com.example.SCM.service;

import com.example.SCM.dto.request.SalesOfficerRequestDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.dto.response.SalesOfficerResponseDTO;
import com.example.SCM.entity.SalesOfficer;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface SalesOfficerService {
    SalesOfficerResponseDTO save(SalesOfficerRequestDTO dto, MultipartFile file);
    SalesOfficerResponseDTO update(Long id, SalesOfficerRequestDTO dto, MultipartFile file);
    List<SalesOfficerResponseDTO> findAll();
    Optional<SalesOfficerResponseDTO> getById(Long id);
    void delete(Long id);
    Optional<SalesOfficerResponseDTO> findUserById(Long id);




}