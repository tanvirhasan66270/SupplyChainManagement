package com.example.SCM.service;

import com.example.SCM.dto.request.ProductRequirementRequestDTO;
import com.example.SCM.dto.response.ProductRequirementResponseDTO;
import java.util.List;
import java.util.Optional;

public interface ProductRequirementService {

    ProductRequirementResponseDTO save(ProductRequirementRequestDTO dto);

    ProductRequirementResponseDTO update(Long id, ProductRequirementRequestDTO dto);

    ProductRequirementResponseDTO updateStatus(Long id, String status);

    List<ProductRequirementResponseDTO> findAll();

    Optional<ProductRequirementResponseDTO> getById(Long id);

    void delete(Long id);
}
