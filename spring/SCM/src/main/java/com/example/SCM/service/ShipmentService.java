package com.example.SCM.service;

import com.example.SCM.dto.request.ShipmentRequestDTO;
import com.example.SCM.dto.response.ShipmentResponseDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface ShipmentService {
    ShipmentResponseDTO save(ShipmentRequestDTO dto, MultipartFile file);
    ShipmentResponseDTO update(Long id, ShipmentRequestDTO dto, MultipartFile file);
    List<ShipmentResponseDTO> findAll();
    Optional<ShipmentResponseDTO> getById(Long id);
    void delete(Long id);
}