package com.example.SCM.service;


import com.example.SCM.dto.response.DriverResponseDTO;
import com.example.SCM.dto.response.SupplierResponseDTO;
import com.example.SCM.dto.request.SupplierRequestDTO;

import com.example.SCM.entity.Supplier;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

@Service
public interface SupplierService {

    SupplierResponseDTO save(SupplierRequestDTO dto, MultipartFile file);
    SupplierResponseDTO update(Long id, SupplierRequestDTO dto, MultipartFile file);
    List<SupplierResponseDTO> findAll();
    Optional<SupplierResponseDTO> getById(Long id);
    void delete(Long id);
    Optional<SupplierResponseDTO> findUserById(Long id);


}
