package com.example.SCM.service;

import com.example.SCM.dto.request.LogisticsOfficerRequestDTO;
import com.example.SCM.dto.response.DriverResponseDTO;
import com.example.SCM.dto.response.LogisticsOfficerResponseDTO;
import com.example.SCM.entity.Logistics_Officer;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface LogisticsOfficerService {
    LogisticsOfficerResponseDTO save(LogisticsOfficerRequestDTO dto, MultipartFile file);
    LogisticsOfficerResponseDTO update(Long id, LogisticsOfficerRequestDTO dto, MultipartFile file);
    List<LogisticsOfficerResponseDTO> findAll();
    Optional<LogisticsOfficerResponseDTO> getById(Long id);
    void delete(Long id);
    Optional<LogisticsOfficerResponseDTO> findUserById(Long id);



}