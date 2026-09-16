package com.example.SCM.controller;

import com.example.SCM.dto.request.SalesOfficerRequestDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.dto.response.SalesOfficerResponseDTO;
import com.example.SCM.service.SalesOfficerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/sales-officers")
@RequiredArgsConstructor
public class SalesOfficerController {

    private final SalesOfficerService officerService;
    private final ObjectMapper objectMapper;

    @PreAuthorize("hasAnyRole('ADMIN')")
    @PostMapping
    public ResponseEntity<SalesOfficerResponseDTO> save(
            @RequestPart("salesOfficer") String officerJson,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        try {
            SalesOfficerRequestDTO dto = objectMapper.readValue(officerJson, SalesOfficerRequestDTO.class);
            return new ResponseEntity<>(officerService.save(dto, file), HttpStatus.CREATED);
        } catch (Exception e) {
            throw new RuntimeException("Sales profile deployment failed at edge gateway: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN',  'SALES_OFFICER')")
    @PutMapping( "/{id}")
    public ResponseEntity<SalesOfficerResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("salesOfficer") String officerJson,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        try {
            SalesOfficerRequestDTO dto = objectMapper.readValue(officerJson, SalesOfficerRequestDTO.class);
            return ResponseEntity.ok(officerService.update(id, dto, file));
        } catch (Exception e) {
            throw new RuntimeException("Sales structural modification matrix rejected: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER')")
    @GetMapping
    public ResponseEntity<List<SalesOfficerResponseDTO>> findAll() {
        return ResponseEntity.ok(officerService.findAll());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER')")
    @GetMapping("/{id}")
    public ResponseEntity<SalesOfficerResponseDTO> getById(@PathVariable Long id) {
        return officerService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        officerService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER')")
    @GetMapping("/user/{id}")
    public ResponseEntity<SalesOfficerResponseDTO> getByUserId(@PathVariable Long id) {
        return officerService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
