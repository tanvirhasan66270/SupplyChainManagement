package com.example.SCM.controller;

import com.example.SCM.dto.request.QCInspectorRequestDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.dto.response.QCInspectorResponseDTO;
import com.example.SCM.service.QCInspectorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/qc-inspectors")
@RequiredArgsConstructor
public class QCInspectorController {

    private final QCInspectorService qcInspectorService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<QCInspectorResponseDTO> create(
            @RequestPart("qcInspector") QCInspectorRequestDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile image) {

        return new ResponseEntity<>(
                qcInspectorService.save(dto, image),
                HttpStatus.CREATED
        );
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<QCInspectorResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("qcInspector") QCInspectorRequestDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile image) {

        return ResponseEntity.ok(qcInspectorService.update(id, dto, image));
    }


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<QCInspectorResponseDTO>> getAll() {
        List<QCInspectorResponseDTO> inspectors = qcInspectorService.findAll();

        if (inspectors.isEmpty()) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(inspectors);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<QCInspectorResponseDTO> getById(@PathVariable Long id) {
        return qcInspectorService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        qcInspectorService.delete(id);
        return ResponseEntity.ok("Deleted successfully");
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/user/{id}")
    public ResponseEntity<QCInspectorResponseDTO> getByUserId(@PathVariable Long id) {
        return qcInspectorService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
