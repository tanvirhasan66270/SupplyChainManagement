package com.example.SCM.controller;

import com.example.SCM.dto.request.POLineItemRequestDTO;
import com.example.SCM.dto.response.POLineItemResponseDTO;
import com.example.SCM.service.POLineItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/po-line-items")
@RequiredArgsConstructor
//@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT')")
public class POLineItemController {

    private final POLineItemService poLineItemService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER')")
    @PostMapping
    public ResponseEntity<POLineItemResponseDTO> save(@RequestBody POLineItemRequestDTO dto) {
        POLineItemResponseDTO response = poLineItemService.save(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER')")
    @PutMapping("/{id}")
    public ResponseEntity<POLineItemResponseDTO> update(
            @PathVariable Long id,
            @RequestBody POLineItemRequestDTO dto) {
        POLineItemResponseDTO response = poLineItemService.update(id, dto);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping
    public ResponseEntity<List<POLineItemResponseDTO>> getAll() {
        List<POLineItemResponseDTO> list = poLineItemService.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping("/{id}")
    public ResponseEntity<POLineItemResponseDTO> getById(@PathVariable Long id) {
        return poLineItemService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        poLineItemService.delete(id);
        return ResponseEntity.ok("Purchase Order Line Item deleted and parent order total amount updated successfully!");
    }

    // Track Purchase Order Line Item Status (GET)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping("/track/{trackingNumber}")

    public ResponseEntity<POLineItemResponseDTO> trackByNumber(@PathVariable String trackingNumber) {
        POLineItemResponseDTO response = poLineItemService.tracking(trackingNumber);
        return ResponseEntity.ok(response);
    }
}
