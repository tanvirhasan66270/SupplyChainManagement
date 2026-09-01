package com.example.SCM.service;

import com.example.SCM.dto.request.GoodsReceivedNoteRequestDTO;
import com.example.SCM.dto.response.GoodsReceivedNoteResponseDTO;

import java.util.List;
import java.util.Optional;

public interface GoodsReceivedNoteService {
    GoodsReceivedNoteResponseDTO save(GoodsReceivedNoteRequestDTO dto);
    GoodsReceivedNoteResponseDTO update(Long id, GoodsReceivedNoteRequestDTO dto);
    List<GoodsReceivedNoteResponseDTO> findAll();
    Optional<GoodsReceivedNoteResponseDTO> getById(Long id);
    void delete(Long id);
}