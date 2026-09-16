package com.example.SCM.controller;

import com.example.SCM.dto.request.InventoryRequestDTO;
import com.example.SCM.dto.response.InventoryResponseDTO;
import com.example.SCM.service.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventories")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    // 1. Save/Create New Inventory Stock (POST)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<InventoryResponseDTO> save(@RequestBody InventoryRequestDTO dto) {
        InventoryResponseDTO response = inventoryService.save(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // 2. Update Existing Inventory Stock (PUT)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<InventoryResponseDTO> update(
            @PathVariable Long id,
            @RequestBody InventoryRequestDTO dto) {
        InventoryResponseDTO response = inventoryService.update(id, dto);
        return ResponseEntity.ok(response);
    }

    //3. Get All Inventory Records (GET)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping

    public ResponseEntity<List<InventoryResponseDTO>> getAll() {
        List<InventoryResponseDTO> list = inventoryService.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    //4. Get Inventory Record By ID (GET)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")

    public ResponseEntity<InventoryResponseDTO> getById(@PathVariable Long id) {
        return inventoryService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. Delete Inventory Record (DELETE)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'SALES_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        inventoryService.delete(id);
        return ResponseEntity.ok("Inventory record deleted successfully from the tracking system!");
    }
}
