package com.example.SCM.controller;

import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.dto.response.SupplierResponseDTO;
import com.example.SCM.dto.request.SupplierRequestDTO;
import com.example.SCM.service.SupplierService;

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
@RequestMapping("/api/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;
    private final ObjectMapper objectMapper;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SUPPLIER')")
    @PostMapping(consumes = { MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<SupplierResponseDTO> save(
            @RequestPart("suppliers") String supplierJson,
            @RequestPart(value = "image", required = false) MultipartFile image) {
        try {
            SupplierRequestDTO dto = objectMapper.readValue(supplierJson, SupplierRequestDTO.class);
            return new ResponseEntity<>(supplierService.save(dto, image), HttpStatus.CREATED);
        } catch (Exception e) {
            throw new RuntimeException("Supplier profile node generation failed: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SUPPLIER', 'PROCUREMENT', 'COMMERCIAL_OFFICER')")
    @PutMapping(value = "/{id}", consumes = { MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<SupplierResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("suppliers") String supplierJson,
            @RequestPart(value = "image", required = false) MultipartFile image) {
        try {
            SupplierRequestDTO dto = objectMapper.readValue(supplierJson, SupplierRequestDTO.class);
            return ResponseEntity.ok(supplierService.update(id, dto, image));
        } catch (Exception e) {
            throw new RuntimeException("Supplier profile data mutation rejected: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SUPPLIER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping
//    @PreAuthorize("hasRole('ADMIN') or @supplierSecurity.isSelfUser(#id, authentication)")

    public ResponseEntity<List<SupplierResponseDTO>> getAll() {
        List<SupplierResponseDTO> list = supplierService.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SUPPLIER', 'PROCUREMENT', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping("/{id}")
    public ResponseEntity<SupplierResponseDTO> getById(@PathVariable Long id) {
        return supplierService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SUPPLIER', 'PROCUREMENT')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        supplierService.delete(id);
        return ResponseEntity.ok("Supplier profile and associated auth account deleted successfully!");
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SUPPLIER', 'PROCUREMENT', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping("/user/{id}")
    public ResponseEntity<SupplierResponseDTO> getByUserId(@PathVariable Long id) {
        return supplierService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
