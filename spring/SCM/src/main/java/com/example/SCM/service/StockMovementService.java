package com.example.SCM.service;

import com.example.SCM.dto.request.StockMovementRequestDTO;
import com.example.SCM.dto.response.StockMovementResponseDTO;
import java.util.List;
import java.util.Optional;

public interface StockMovementService {
    StockMovementResponseDTO logMovement(StockMovementRequestDTO dto);
    List<StockMovementResponseDTO> findAll();
    Optional<StockMovementResponseDTO> getById(Long id);
    void delete(Long id);
}