package com.example.SCM.controller;

import com.example.SCM.dto.request.ManagerRequestDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.service.ManagerService;

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
@RequestMapping("/api/managers")
@RequiredArgsConstructor
//@PreAuthorize("hasRole('ADMIN')")
public class ManagerController {

    private final ManagerService managerService;
    private final ObjectMapper objectMapper;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PostMapping
    public ResponseEntity<ManagerResponseDTO> save(
            @RequestPart("manager") String managerJson,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        try {
            ManagerRequestDTO dto = objectMapper.readValue(managerJson, ManagerRequestDTO.class);
            return new ResponseEntity<>(managerService.save(dto, file), HttpStatus.CREATED);
        } catch (Exception e) {
            throw new RuntimeException("Manager compilation broken at transactional phase: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PutMapping(value = "/{id}")
    public ResponseEntity<ManagerResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("manager") String managerJson,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        try {
            ManagerRequestDTO dto = objectMapper.readValue(managerJson, ManagerRequestDTO.class);
            return ResponseEntity.ok(managerService.update(id, dto, file));
        } catch (Exception e) {
            throw new RuntimeException("Manager operational data mutation rejected: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<ManagerResponseDTO>> findAll() {
        return ResponseEntity.ok(managerService.findAll());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<ManagerResponseDTO> getById(@PathVariable Long id) {
        return managerService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        managerService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/user/{id}")
    public ResponseEntity<ManagerResponseDTO> getByUserId(@PathVariable Long id) {
        return managerService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

}
