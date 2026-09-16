package com.example.SCM.controller;

import com.example.SCM.dto.request.StockMovementRequestDTO;
import com.example.SCM.dto.response.StockMovementResponseDTO;
import com.example.SCM.service.StockMovementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/stock-movements")
@RequiredArgsConstructor
public class StockMovementController {

    private final StockMovementService service;


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<StockMovementResponseDTO> logMovement(@RequestBody StockMovementRequestDTO dto) {
        StockMovementResponseDTO response = service.logMovement(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT',  'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping
    public ResponseEntity<List<StockMovementResponseDTO>> findAll() {
        List<StockMovementResponseDTO> list = service.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<StockMovementResponseDTO> getById(@PathVariable Long id) {
        return service.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
