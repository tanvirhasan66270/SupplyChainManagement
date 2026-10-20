package com.example.SCM.service;

import com.example.SCM.dto.request.CommercialOfficerRequestDTO;
import com.example.SCM.dto.response.CommercialOfficerResponseDTO;
import com.example.SCM.dto.response.CustomerResponseDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;

public interface CommercialOfficerService {
    CommercialOfficerResponseDTO save(CommercialOfficerRequestDTO dto, MultipartFile file);
    CommercialOfficerResponseDTO update(Long id, CommercialOfficerRequestDTO dto, MultipartFile file);
    List<CommercialOfficerResponseDTO> findAll();
    Optional<CommercialOfficerResponseDTO> getById(Long id);
    void delete(Long id);
    Optional<CommercialOfficerResponseDTO> findUserById(Long id);

}