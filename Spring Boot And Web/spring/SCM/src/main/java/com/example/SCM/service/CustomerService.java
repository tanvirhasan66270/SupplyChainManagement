package com.example.SCM.service;

import com.example.SCM.dto.request.CustomerRequestDTO;
import com.example.SCM.dto.response.CustomerResponseDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

public interface CustomerService {

    CustomerResponseDTO save(CustomerRequestDTO dto, MultipartFile image);

    CustomerResponseDTO update(Long id, CustomerRequestDTO dto, MultipartFile image);

    List<CustomerResponseDTO> findAll();

    Optional<CustomerResponseDTO> getById(Long id);

    void delete(Long id);
    Optional<CustomerResponseDTO> findUserById(Long id);


}