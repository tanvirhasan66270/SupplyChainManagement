package com.example.SCM.service;

import com.example.SCM.dto.request.DeliveryTripRequestDTO;
import com.example.SCM.dto.response.DeliveryTripResponseDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface DeliveryTripService {
    DeliveryTripResponseDTO save(DeliveryTripRequestDTO dto);
    DeliveryTripResponseDTO update(Long id, DeliveryTripRequestDTO dto);
    DeliveryTripResponseDTO updateTripStatus(Long id, String status, MultipartFile signature, MultipartFile deliveryPhoto);
    List<DeliveryTripResponseDTO> findAll();
    Optional<DeliveryTripResponseDTO> getById(Long id);
    void delete(Long id);
}