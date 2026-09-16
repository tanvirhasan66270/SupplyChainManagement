package com.example.SCM.controller;

import com.example.SCM.dto.request.QuotationRequestDTO;
import com.example.SCM.dto.response.QuotationResponseDTO;
import com.example.SCM.entity.User;
import com.example.SCM.repository.SupplierRepository;
import com.example.SCM.service.QuotationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collections;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/quotations")
@RequiredArgsConstructor
@CrossOrigin("*") 
public class QuotationController {

    private final QuotationService quotationService;
    private final SupplierRepository supplierRepository;

    // 1. Create New Quotation (POST Multipart)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER')")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<QuotationResponseDTO> createQuotation(
            @RequestPart("quotation") String quotationJson,
            @RequestPart(value = "image", required = false) MultipartFile image) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        QuotationRequestDTO dto = mapper.readValue(quotationJson, QuotationRequestDTO.class);

        return new ResponseEntity<>(
                quotationService.save(dto, image),
                HttpStatus.CREATED
        );
    }

    // 2. Get Quotation By ID (GET)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping("/{id}")
    public ResponseEntity<QuotationResponseDTO> getQuotationById(@PathVariable Long id) {
        return quotationService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. Get All Quotations (GET)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER')")
    @GetMapping
    public ResponseEntity<List<QuotationResponseDTO>> getAllQuotations() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        if (principal instanceof User currentUser) {
            if ("SUPPLIER".equalsIgnoreCase(currentUser.getRole().name())) {
                return supplierRepository.findByUserId(currentUser.getId())
                        .map(supplier -> {
                            List<QuotationResponseDTO> supplierQuotations =
                                    quotationService.findBySupplierId(supplier.getId());
                            return ResponseEntity.ok(supplierQuotations);
                        })
                        .orElse(ResponseEntity.ok(Collections.emptyList()));
            }
        }

        List<QuotationResponseDTO> list = quotationService.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    // 4. Update Existing Quotation (PUT)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'COMMERCIAL_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<QuotationResponseDTO> updateQuotation(
            @PathVariable Long id,
            @RequestBody QuotationRequestDTO dto) {

        QuotationResponseDTO response = quotationService.update(id, dto);
        return ResponseEntity.ok(response);
    }

    // 5. Delete Quotation (DELETE)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'COMMERCIAL_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteQuotation(@PathVariable Long id) {
        quotationService.delete(id);
        return ResponseEntity.noContent().build();
    }
    // 6. Update Quotation Status (PATCH)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'SUPPLIER', 'COMMERCIAL_OFFICER')")
    @PatchMapping("/{id}/status")
    public ResponseEntity<QuotationResponseDTO> updateStatus(
            @PathVariable Long id,
            @RequestBody String status) {

        String cleanStatus = status.replaceAll("^\"|\"$", "");

        QuotationResponseDTO response = quotationService.updateStatus(id, cleanStatus);
        return ResponseEntity.ok(response);
    }
}
