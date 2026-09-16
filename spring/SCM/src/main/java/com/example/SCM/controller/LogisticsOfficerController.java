package com.example.SCM.controller;

import com.example.SCM.dto.request.LogisticsOfficerRequestDTO;
import com.example.SCM.dto.response.LogisticsOfficerResponseDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.service.LogisticsOfficerService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.util.List;

@RestController
@RequestMapping("/api/logistics-officers")
@RequiredArgsConstructor
//@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
public class LogisticsOfficerController {

    private final LogisticsOfficerService officerService;
    private final ObjectMapper objectMapper;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @PostMapping(consumes = { MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<LogisticsOfficerResponseDTO> save(
            @RequestPart("officer") String officerJson,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        try {
            LogisticsOfficerRequestDTO dto = objectMapper.readValue(officerJson, LogisticsOfficerRequestDTO.class);
            return new ResponseEntity<>(officerService.save(dto, file), HttpStatus.CREATED);
        } catch (Exception e) {
            throw new RuntimeException("Officer profile compilation dropped at transactional layer: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @PutMapping(value = "/{id}", consumes = { MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<LogisticsOfficerResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("officer") String officerJson,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        try {
            LogisticsOfficerRequestDTO dto = objectMapper.readValue(officerJson, LogisticsOfficerRequestDTO.class);
            return ResponseEntity.ok(officerService.update(id, dto, file));
        } catch (Exception e) {
            throw new RuntimeException("Officer data mutation rejected at validation phase: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @GetMapping
    public ResponseEntity<List<LogisticsOfficerResponseDTO>> findAll() {
        return ResponseEntity.ok(officerService.findAll());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @GetMapping("/{id}")
    public ResponseEntity<LogisticsOfficerResponseDTO> getById(@PathVariable Long id) {
        return officerService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        officerService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @GetMapping("/user/{id}")
//    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER') or @logisticsOfficerSecurity.isSelf(#id, authentication)")
    public ResponseEntity<LogisticsOfficerResponseDTO> getByUserId(@PathVariable Long id) {
        return officerService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
