package com.example.SCM.service;

import com.example.SCM.dto.request.CountryRequestDTO;
import com.example.SCM.dto.response.CountryResponseDTO;

import java.util.List;
import java.util.Optional;

public interface CountryService {
    CountryResponseDTO save(CountryRequestDTO dto);
    CountryResponseDTO update(Long id, CountryRequestDTO dto);
    List<CountryResponseDTO> findAll(boolean onlyActive);
    Optional<CountryResponseDTO> getById(Long id);
    void delete(Long id);
}