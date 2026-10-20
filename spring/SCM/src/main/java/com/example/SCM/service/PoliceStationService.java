package com.example.SCM.service;

import com.example.SCM.dto.request.PoliceStationRequestDTO;
import com.example.SCM.dto.response.PoliceStationResponseDTO;

import java.util.List;
import java.util.Optional;

public interface PoliceStationService {
    PoliceStationResponseDTO save(PoliceStationRequestDTO dto);
    PoliceStationResponseDTO update(Long id, PoliceStationRequestDTO dto);
    List<PoliceStationResponseDTO> findAll(boolean onlyActive);
    List<PoliceStationResponseDTO> getByDistrictId(Long districtId);
    Optional<PoliceStationResponseDTO> getById(Long id);
    void delete(Long id);
    List<PoliceStationResponseDTO> search(String keyword);
}