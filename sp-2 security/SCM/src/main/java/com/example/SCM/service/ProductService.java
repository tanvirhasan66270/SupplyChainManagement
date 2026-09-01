package com.example.SCM.service;

import com.example.SCM.dto.response.ProductResponseDTO;
import com.example.SCM.dto.request.ProductRequestDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface ProductService {

    ProductResponseDTO save(ProductRequestDTO dto, MultipartFile image);
    ProductResponseDTO update(Long id, ProductRequestDTO dto ,MultipartFile image);
    List<ProductResponseDTO> findAll();
    List<ProductResponseDTO> findByCategoryId(Long categoryId);
    Optional<ProductResponseDTO> getById(Long id);
    void delete(Long id);
}
