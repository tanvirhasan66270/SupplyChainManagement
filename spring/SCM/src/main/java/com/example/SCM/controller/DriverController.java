package com.example.SCM.controller;

import com.example.SCM.dto.request.DriverRequestDTO;
import com.example.SCM.dto.response.DriverResponseDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.service.DriverService;
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
@RequestMapping("/api/drivers")
@RequiredArgsConstructor
//@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
public class DriverController {

    private final DriverService driverService;
    private final ObjectMapper objectMapper;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'DRIVER', 'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<DriverResponseDTO> save(
            @RequestPart("driver") String driverJson,
            @RequestPart(value = "image", required = false) MultipartFile file
    ) {
        try {
            DriverRequestDTO dto = objectMapper.readValue(driverJson, DriverRequestDTO.class);
            DriverResponseDTO response = driverService.save(dto, file);
            return new ResponseEntity<>(
                    response,
                    HttpStatus.CREATED
            );
        } catch (Exception e) {
            throw new RuntimeException("Driver profile mapping transaction aborted: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'DRIVER', 'LOGISTICS_OFFICER')")
    @PutMapping(value = "/{id}", consumes = { MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<DriverResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("driver") String driverJson,
            @RequestPart(value = "file", required = false) MultipartFile file
    ) {
        try {
            DriverRequestDTO dto = objectMapper.readValue(driverJson, DriverRequestDTO.class);
            DriverResponseDTO response = driverService.update(id, dto, file);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            throw new RuntimeException("Driver data mutation transaction aborted: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'DRIVER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<DriverResponseDTO>> findAll() {
        return ResponseEntity.ok(driverService.findAll());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'DRIVER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<DriverResponseDTO> getById(@PathVariable Long id) {
        return driverService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'DRIVER', 'LOGISTICS_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        driverService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'DRIVER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/user/{id}")
    public ResponseEntity<DriverResponseDTO> getByUserId(@PathVariable Long id) {
        return driverService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

}
