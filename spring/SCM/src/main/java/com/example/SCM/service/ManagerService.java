package com.example.SCM.service;

import com.example.SCM.dto.request.ManagerRequestDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.entity.Manager;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Optional;
@Service
public interface ManagerService {
    ManagerResponseDTO save(ManagerRequestDTO dto, MultipartFile file);
    ManagerResponseDTO update(Long id, ManagerRequestDTO dto, MultipartFile file);
    List<ManagerResponseDTO> findAll();
    Optional<ManagerResponseDTO> getById(Long id);
    void delete(Long id);

    Optional<ManagerResponseDTO> findUserById(Long id);

    }