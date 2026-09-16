package com.example.SCM.service;

import com.example.SCM.dto.request.DistrictRequestDTO;
import com.example.SCM.dto.response.DistrictResponseDTO;

import java.util.List;
import java.util.Optional;

public interface DistrictService {
    DistrictResponseDTO save(DistrictRequestDTO dto);
    DistrictResponseDTO update(Long id, DistrictRequestDTO dto);
    List<DistrictResponseDTO> findAll(boolean onlyActive);
    List<DistrictResponseDTO> getByDivisionId(Long divisionId);
    Optional<DistrictResponseDTO> getById(Long id);
    void delete(Long id);
}