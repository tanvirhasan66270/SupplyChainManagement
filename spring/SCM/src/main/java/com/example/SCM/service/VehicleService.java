package com.example.SCM.service;

import com.example.SCM.dto.request.VehicleRequestDTO;
import com.example.SCM.dto.response.VehicleResponseDTO;

import java.util.List;
import java.util.Optional;

public interface VehicleService {
    VehicleResponseDTO save(VehicleRequestDTO dto);
    VehicleResponseDTO update(Long id, VehicleRequestDTO dto);
    List<VehicleResponseDTO> findAll();
    Optional<VehicleResponseDTO> getById(Long id);
    void delete(Long id);
}