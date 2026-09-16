package com.example.SCM.controller;

import com.example.SCM.dto.request.QCInspectionRequestDTO;
import com.example.SCM.dto.response.QCInspectionResponseDTO;
import com.example.SCM.service.QCInspectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/qc-inspections")
@RequiredArgsConstructor
public class QCInspectionController {

    private final QCInspectionService qcInspectionService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @PostMapping
    public ResponseEntity<QCInspectionResponseDTO> create(
            @RequestPart("inspection") String inspectionJson,
            @RequestPart(value = "file", required = false) MultipartFile file) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        QCInspectionRequestDTO dto = mapper.readValue(inspectionJson, QCInspectionRequestDTO.class);
        return new ResponseEntity<>(qcInspectionService.save(dto, file), HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @PutMapping(value = "/{id}")
    public ResponseEntity<QCInspectionResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("inspection") String inspectionJson,
            @RequestPart(value = "file", required = false) MultipartFile file) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        QCInspectionRequestDTO dto = mapper.readValue(inspectionJson, QCInspectionRequestDTO.class);
        return ResponseEntity.ok(qcInspectionService.update(id, dto, file));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<QCInspectionResponseDTO>> getAll() {
        List<QCInspectionResponseDTO> list = qcInspectionService.findAll();
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<QCInspectionResponseDTO> getById(@PathVariable Long id) {
        return qcInspectionService.getById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        qcInspectionService.delete(id);
        return ResponseEntity.ok("QC Record with checklist chain deleted successfully");
    }
}
