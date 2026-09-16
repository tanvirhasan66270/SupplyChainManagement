package com.example.SCM.controller;

import com.example.SCM.dto.request.GRNLineItemRequestDTO;
import com.example.SCM.dto.response.GRNLineItemResponseDTO;
import com.example.SCM.service.GRNLineItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/grn-line-items")
@RequiredArgsConstructor
public class GRNLineItemController {

    private final GRNLineItemService grnLineItemService;


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER',  'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<GRNLineItemResponseDTO> create(@RequestBody GRNLineItemRequestDTO dto) {
        GRNLineItemResponseDTO response = grnLineItemService.save(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // Update Existing GRN Line Item (PUT)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'QC_INSPECTOR', 'LOGISTICS_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<GRNLineItemResponseDTO> update(
            @PathVariable Long id,
            @RequestBody GRNLineItemRequestDTO dto) {

        GRNLineItemResponseDTO response = grnLineItemService.update(id, dto);
        return ResponseEntity.ok(response);
    }


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'QC_INSPECTOR', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<GRNLineItemResponseDTO>> getAll() {
        List<GRNLineItemResponseDTO> list = grnLineItemService.findAll();

        if (list.isEmpty()) {
            return ResponseEntity.noContent().build(); // 204 Content
        }

        return ResponseEntity.ok(list);
    }

    // 4. Get GRN Line Item By ID (GET)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'QC_INSPECTOR', 'LOGISTICS_OFFICER', 'SALES_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<GRNLineItemResponseDTO> getById(@PathVariable Long id) {
        return grnLineItemService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Delete GRN Line Item By ID (DELETE)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'QC_INSPECTOR', 'LOGISTICS_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        grnLineItemService.delete(id);
        return ResponseEntity.ok("GRN Line Item deleted successfully with ID: " + id);
    }
}
