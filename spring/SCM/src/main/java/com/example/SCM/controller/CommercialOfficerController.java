package com.example.SCM.controller;

import com.example.SCM.dto.request.CommercialOfficerRequestDTO;
import com.example.SCM.dto.response.CommercialOfficerResponseDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.service.CommercialOfficerService;
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
@RequestMapping("/api/commercial-officer")
@RequiredArgsConstructor
//@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
public class CommercialOfficerController {

    private final CommercialOfficerService officerService;
    private final ObjectMapper objectMapper;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @PostMapping
    public ResponseEntity<CommercialOfficerResponseDTO> save(
            @RequestPart("commercialOfficer") String officerJson,
            @RequestPart(value = "file", required = false) MultipartFile file
    ) {
        try {
            CommercialOfficerRequestDTO dto = objectMapper.readValue(officerJson, CommercialOfficerRequestDTO.class);
            return new ResponseEntity<>(
                    officerService.save(dto, file),
                    HttpStatus.CREATED
            );
        } catch (Exception e) {
            throw new RuntimeException("Commercial profile deployment failed: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @PutMapping(value = "/{id}")
    public ResponseEntity<CommercialOfficerResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("officer") String officerJson,
            @RequestPart(value = "file", required = false) MultipartFile file
    ) {
        try {
            CommercialOfficerRequestDTO dto = objectMapper.readValue(officerJson, CommercialOfficerRequestDTO.class);
            return ResponseEntity.ok(officerService.update(id, dto, file));
        } catch (Exception e) {
            throw new RuntimeException("Commercial structural data modification failed: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<CommercialOfficerResponseDTO>> findAll() {
        return ResponseEntity.ok(officerService.findAll());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<CommercialOfficerResponseDTO> getById(@PathVariable Long id) {
        return officerService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        officerService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/user/{id}")
    public ResponseEntity<CommercialOfficerResponseDTO> getByUserId(@PathVariable Long id) {
        return officerService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

}
