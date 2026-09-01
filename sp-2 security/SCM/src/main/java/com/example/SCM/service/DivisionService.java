package com.example.SCM.service;

import com.example.SCM.dto.request.DivisionRequestDTO;
import com.example.SCM.dto.response.DivisionResponseDTO;

import java.util.List;
import java.util.Optional;

public interface DivisionService {
    DivisionResponseDTO save(DivisionRequestDTO dto);
    DivisionResponseDTO update(Long id, DivisionRequestDTO dto);
    List<DivisionResponseDTO> findAll(boolean onlyActive);
    List<DivisionResponseDTO> getByCountryId(Long countryId);
    Optional<DivisionResponseDTO> getById(Long id);
    void delete(Long id);
}