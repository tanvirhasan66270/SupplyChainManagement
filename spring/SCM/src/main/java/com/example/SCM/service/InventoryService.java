package com.example.SCM.service;



import com.example.SCM.dto.request.InventoryRequestDTO;
import com.example.SCM.dto.response.InventoryResponseDTO;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
@Service
public interface InventoryService {

    InventoryResponseDTO save(InventoryRequestDTO dto);
    InventoryResponseDTO update(Long id, InventoryRequestDTO dto);
    List<InventoryResponseDTO> findAll();
    Optional<InventoryResponseDTO> getById(Long id);
    void delete(Long id);
}
