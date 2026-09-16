package com.example.SCM.controller;

import com.example.SCM.dto.request.LetterOfCreditRequestDTO;
import com.example.SCM.dto.response.LetterOfCreditResponseDTO;
import com.example.SCM.service.LetterOfCreditService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.util.List;

@RestController
@RequestMapping("/api/lc")
@RequiredArgsConstructor
//@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'PROCUREMENT', 'COMMERCIAL_OFFICER')")
public class LetterOfCreditController {

    private final LetterOfCreditService lcService;

    // 1. Create New Letter of Credit (POST - Multipart Form Data)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<LetterOfCreditResponseDTO> createLC(
            @RequestPart("lcData") String lcDataJson,
            @RequestPart(value = "file", required = false) MultipartFile file) throws Exception {

        ObjectMapper objectMapper = new ObjectMapper();
        LetterOfCreditRequestDTO dto = objectMapper.readValue(lcDataJson, LetterOfCreditRequestDTO.class);

        LetterOfCreditResponseDTO response = lcService.save(dto, file);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // 2. Update Existing Letter of Credit (PUT - Multipart Form Data)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<LetterOfCreditResponseDTO> updateLC(
            @PathVariable Long id,
            @RequestPart("lcData") String lcDataJson,
            @RequestPart(value = "file", required = false) MultipartFile file) throws Exception {

        ObjectMapper objectMapper = new ObjectMapper();
        LetterOfCreditRequestDTO dto = objectMapper.readValue(lcDataJson, LetterOfCreditRequestDTO.class);

        LetterOfCreditResponseDTO response = lcService.update(id, dto, file);
        return ResponseEntity.ok(response);
    }

    // 3. Commercial Amendment Gateway (PATCH - Standard JSON Request)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @PatchMapping("/amend/{id}")
    public ResponseEntity<LetterOfCreditResponseDTO> amendLC(
            @PathVariable Long id,
            @RequestBody LetterOfCreditRequestDTO dto) {
        LetterOfCreditResponseDTO response = lcService.amendLC(id, dto);
        return ResponseEntity.ok(response);
    }

    // 4. Get All LCs (GET)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<LetterOfCreditResponseDTO>> getAllLCs() {
        return ResponseEntity.ok(lcService.findAll());
    }

    // 5. Get LC By ID (GET)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<LetterOfCreditResponseDTO> getLCById(@PathVariable Long id) {
        return lcService.getById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // 6. Delete LC (DELETE)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'COMMERCIAL_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteLC(@PathVariable Long id) {
        lcService.delete(id);
        return ResponseEntity.ok("Letter of credit cluster mapping wiped successfully.");
    }
}
