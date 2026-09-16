package com.example.SCM.controller;

import com.example.SCM.dto.request.VehicleRequestDTO;
import com.example.SCM.dto.response.VehicleResponseDTO;
import com.example.SCM.service.VehicleService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/vehicles")
@RequiredArgsConstructor
public class VehicleController {

    private final VehicleService vehicleService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<VehicleResponseDTO> create(@RequestBody VehicleRequestDTO dto) {
        return new ResponseEntity<>(vehicleService.save(dto), HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'DRIVER')")
    @PutMapping("/{id}")
    public ResponseEntity<VehicleResponseDTO> update(@PathVariable Long id, @RequestBody VehicleRequestDTO dto) {
        return ResponseEntity.ok(vehicleService.update(id, dto));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<VehicleResponseDTO>> getAll() {
        List<VehicleResponseDTO> list = vehicleService.findAll();
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<VehicleResponseDTO> getById(@PathVariable Long id) {
        return vehicleService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        vehicleService.delete(id);
        return ResponseEntity.ok("Vehicle successfully decommissioned from active tracking logistics");
    }
}
