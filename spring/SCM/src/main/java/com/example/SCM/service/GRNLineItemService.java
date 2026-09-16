package com.example.SCM.service;



import com.example.SCM.dto.request.GRNLineItemRequestDTO;
import com.example.SCM.dto.response.GRNLineItemResponseDTO;

import java.util.List;
import java.util.Optional;

public interface GRNLineItemService {
    GRNLineItemResponseDTO save(GRNLineItemRequestDTO dto);
    GRNLineItemResponseDTO update(Long id, GRNLineItemRequestDTO dto);
    List<GRNLineItemResponseDTO> findAll();
    Optional<GRNLineItemResponseDTO> getById(Long id);
    void delete(Long id);
}
