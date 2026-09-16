package com.example.SCM.controller;

import com.example.SCM.dto.request.LCBankRequestDTO;
import com.example.SCM.dto.response.LCBankResponseDTO;
import com.example.SCM.service.LCBankService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/banks")
@RequiredArgsConstructor
//@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'COMMERCIAL_OFFICER')")
public class LCBankController {

    private final LCBankService bankService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @PostMapping
    public ResponseEntity<LCBankResponseDTO> createBank(@RequestBody LCBankRequestDTO dto) {
        LCBankResponseDTO response = bankService.save(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<LCBankResponseDTO> updateBank(
            @PathVariable Long id,
            @RequestBody LCBankRequestDTO dto) {
        LCBankResponseDTO response = bankService.update(id, dto);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<LCBankResponseDTO>> getAllBanks() {
        List<LCBankResponseDTO> list = bankService.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<LCBankResponseDTO> getBankById(@PathVariable Long id) {
        return bankService.getById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteBank(@PathVariable Long id) {
        bankService.delete(id);
        return ResponseEntity.ok("LC Bank mapping profile wiped successfully.");
    }
}
