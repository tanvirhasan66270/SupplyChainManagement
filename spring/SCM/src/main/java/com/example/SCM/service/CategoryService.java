package com.example.SCM.service;


import com.example.SCM.dto.response.CategoryResponseDTO;
import com.example.SCM.dto.request.CategoryRequestDTO;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public interface CategoryService {
    CategoryResponseDTO save(CategoryRequestDTO dto);
    CategoryResponseDTO update(Long id, CategoryRequestDTO dto);
    List<CategoryResponseDTO> findAll();
    Optional<CategoryResponseDTO> getById(Long id);
    void delete(Long id);
}
