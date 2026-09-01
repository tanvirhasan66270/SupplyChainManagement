package com.example.SCM.controller;

import com.example.SCM.dto.request.InvoiceRequestDTO;
import com.example.SCM.dto.response.InvoiceResponseDTO;
import com.example.SCM.service.InvoiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService service;

    // 1. Create New Invoice Ledger Node (POST)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER')")
    @PostMapping
    public ResponseEntity<InvoiceResponseDTO> create(@RequestBody InvoiceRequestDTO dto) {
        InvoiceResponseDTO response = service.save(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    //Mutate/Update Existing Invoice State Matrix (PUT)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<InvoiceResponseDTO> update(@PathVariable Long id, @RequestBody InvoiceRequestDTO dto) {
        InvoiceResponseDTO response = service.update(id, dto);
        return ResponseEntity.ok(response);
    }
    // Fetch All Invoices Register Dataset (GET)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'CUSTOMER', 'PROCUREMENT')")
    @GetMapping
    public ResponseEntity<List<InvoiceResponseDTO>> findAll() {
        List<InvoiceResponseDTO> list = service.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    // Fetch Invoice Instance Details By Unique Record ID (GET)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'CUSTOMER', 'PROCUREMENT')")
    @GetMapping("/{id}")

    public ResponseEntity<InvoiceResponseDTO> getById(@PathVariable Long id) {
        return service.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Wipe/Drop Invoice Lifecycle Instance Pointer (DELETE)

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}