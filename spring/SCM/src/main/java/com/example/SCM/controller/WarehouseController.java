package com.example.SCM.controller;

import com.example.SCM.dto.request.WarehouseRequestDTO;
import com.example.SCM.dto.response.WarehouseResponseDTO;
import com.example.SCM.service.WarehouseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/warehouse")
@RequiredArgsConstructor
public class WarehouseController {

    private final WarehouseService warehouseService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<WarehouseResponseDTO> create(@RequestBody WarehouseRequestDTO dto) {
        return new ResponseEntity<>(warehouseService.save(dto), HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<WarehouseResponseDTO> update(@PathVariable Long id, @RequestBody WarehouseRequestDTO dto) {
        return ResponseEntity.ok(warehouseService.update(id, dto));
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping
    public ResponseEntity<List<WarehouseResponseDTO>> getAll() {
        List<WarehouseResponseDTO> list = warehouseService.findAll();
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/{id}")
    public ResponseEntity<WarehouseResponseDTO> getById(@PathVariable Long id) {
        return warehouseService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        warehouseService.delete(id);
        return ResponseEntity.ok("Warehouse deleted successfully from system tracking");
    }
}
