package com.example.SCM.service;

import com.example.SCM.dto.request.DriverRequestDTO;
import com.example.SCM.dto.response.CommercialOfficerResponseDTO;
import com.example.SCM.dto.response.DriverResponseDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface DriverService {
    DriverResponseDTO save(DriverRequestDTO dto, MultipartFile file);
    DriverResponseDTO update(Long id, DriverRequestDTO dto, MultipartFile file);
    List<DriverResponseDTO> findAll();
    Optional<DriverResponseDTO> getById(Long id);
    void delete(Long id);

    Optional<DriverResponseDTO> findUserById(Long id);

}