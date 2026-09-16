package com.example.SCM.service;

import com.example.SCM.dto.request.ProcurementRequestDTO;
import com.example.SCM.dto.response.CustomerResponseDTO;
import com.example.SCM.dto.response.ProcurementResponseDTO;
import com.example.SCM.entity.Procurement;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface ProcurementService {
    ProcurementResponseDTO save(ProcurementRequestDTO dto, MultipartFile file);
    ProcurementResponseDTO update(Long id, ProcurementRequestDTO dto, MultipartFile file);
    List<ProcurementResponseDTO> findAll();
    Optional<ProcurementResponseDTO> getById(Long id);
    void delete(Long id);
    Optional<ProcurementResponseDTO> findUserById(Long id);


}