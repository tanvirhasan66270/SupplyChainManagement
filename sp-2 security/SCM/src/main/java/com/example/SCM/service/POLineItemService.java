package com.example.SCM.service;



import com.example.SCM.dto.request.POLineItemRequestDTO;
import com.example.SCM.dto.response.POLineItemResponseDTO;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

public interface POLineItemService {

    POLineItemResponseDTO save(POLineItemRequestDTO dto);
    POLineItemResponseDTO update(Long id,POLineItemRequestDTO dto);
    List<POLineItemResponseDTO> findAll();
    Optional<POLineItemResponseDTO> getById(Long id);
    void delete(Long id);
    POLineItemResponseDTO tracking (String trackingNumber);

}
