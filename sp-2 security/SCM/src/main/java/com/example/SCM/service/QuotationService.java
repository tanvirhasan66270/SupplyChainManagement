package com.example.SCM.service;

import com.example.SCM.dto.request.QuotationRequestDTO;
import com.example.SCM.dto.response.QuotationResponseDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

public interface QuotationService {
    QuotationResponseDTO save(QuotationRequestDTO dto , MultipartFile imge);
    QuotationResponseDTO update(Long id, QuotationRequestDTO dto);
    List<QuotationResponseDTO> findAll();
    List<QuotationResponseDTO> findBySupplierId(Long supplierId);
    Optional<QuotationResponseDTO> getById(Long id);
    void delete(Long id);
    QuotationResponseDTO updateStatus(Long id, String status);
}
