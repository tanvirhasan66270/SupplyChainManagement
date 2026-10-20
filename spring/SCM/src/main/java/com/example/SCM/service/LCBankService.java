package com.example.SCM.service;

import com.example.SCM.dto.request.LCBankRequestDTO;
import com.example.SCM.dto.response.LCBankResponseDTO;
import java.util.List;
import java.util.Optional;

public interface LCBankService {
    LCBankResponseDTO save(LCBankRequestDTO dto);
    LCBankResponseDTO update(Long id, LCBankRequestDTO dto);
    List<LCBankResponseDTO> findAll();
    Optional<LCBankResponseDTO> getById(Long id);
    void delete(Long id);
}