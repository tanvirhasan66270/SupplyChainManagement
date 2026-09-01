package com.example.SCM.controller;

import com.example.SCM.dto.request.ProductRequirementRequestDTO;
import com.example.SCM.dto.response.ProductRequirementResponseDTO;
import com.example.SCM.service.ProductRequirementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/product-requirements")
@CrossOrigin("*")
@RequiredArgsConstructor
public class ProductRequirementController {
    private final ProductRequirementService service;

    // ─────────────────────────────────────────────────────
    // CREATE — ADMIN + LOGISTICS_OFFICER
    // LOGISTICS_OFFICER: status APPROVED হলে service layer-এ block হবে
    // ─────────────────────────────────────────────────────
    @PreAuthorize("hasAnyRole('ADMIN', 'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<ProductRequirementResponseDTO> create(
            @RequestBody ProductRequirementRequestDTO dto) {
        return new ResponseEntity<>(service.save(dto), HttpStatus.CREATED);
    }

    // ─────────────────────────────────────────────────────
    // GET ALL — ADMIN, MANAGER, LOGISTICS_OFFICER, PROCUREMENT
    // ─────────────────────────────────────────────────────
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'PROCUREMENT')")
    @GetMapping
    public ResponseEntity<List<ProductRequirementResponseDTO>> getAll() {
        List<ProductRequirementResponseDTO> list = service.findAll();
        if (list.isEmpty()) return ResponseEntity.noContent().build();
        return ResponseEntity.ok(list);
    }

    // ─────────────────────────────────────────────────────
    // GET BY ID — ADMIN, MANAGER, LOGISTICS_OFFICER, PROCUREMENT
    // ─────────────────────────────────────────────────────
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'PROCUREMENT')")
    @GetMapping("/{id}")
    public ResponseEntity<ProductRequirementResponseDTO> getById(@PathVariable Long id) {
        return service.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // ─────────────────────────────────────────────────────
    // UPDATE — ADMIN + LOGISTICS_OFFICER
    // LOGISTICS_OFFICER: status = APPROVED হলে service layer-এ block হবে
    // ─────────────────────────────────────────────────────
    @PreAuthorize("hasAnyRole('ADMIN', 'LOGISTICS_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<ProductRequirementResponseDTO> update(
            @PathVariable Long id,
            @RequestBody ProductRequirementRequestDTO dto) {
        return ResponseEntity.ok(service.update(id, dto));
    }

    // ─────────────────────────────────────────────────────
    // UPDATE STATUS — ADMIN + PROCUREMENT
    // ─────────────────────────────────────────────────────
    @PreAuthorize("hasAnyRole('ADMIN', 'PROCUREMENT')")
    @PatchMapping("/{id}/status")
    public ResponseEntity<ProductRequirementResponseDTO> updateStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        return ResponseEntity.ok(service.updateStatus(id, status));
    }

    // ─────────────────────────────────────────────────────
    // DELETE — শুধু ADMIN
    // ─────────────────────────────────────────────────────
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok("Product Requirement deleted successfully!");
    }
}
