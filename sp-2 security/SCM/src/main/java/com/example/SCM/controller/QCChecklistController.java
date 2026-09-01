package com.example.SCM.controller;

import com.example.SCM.dto.request.QCChecklistRequestDTO;
import com.example.SCM.dto.response.QCChecklistResponseDTO;
import com.example.SCM.service.QCChecklistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/qc-checklists")
@RequiredArgsConstructor
public class QCChecklistController {

    private final QCChecklistService qcChecklistService;


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @PostMapping
    public ResponseEntity<QCChecklistResponseDTO> create(@RequestBody QCChecklistRequestDTO dto) {
        QCChecklistResponseDTO response = qcChecklistService.save(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @PutMapping("/{id}")
    public ResponseEntity<QCChecklistResponseDTO> update(
            @PathVariable Long id,
            @RequestBody QCChecklistRequestDTO dto) {
        QCChecklistResponseDTO response = qcChecklistService.update(id, dto);
        return ResponseEntity.ok(response);
    }

    // 3. Get Checklist Items By Master Inspection ID (GET)
     //  ফ্রন্টএন্ড UI-তে একটি নির্দিষ্ট ইন্সেপশনের গ্রিড ডিটেইলস পপুলেট করার জন্য এটি ব্যবহৃত হবে।

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/inspection/{inspectionId}")
    public ResponseEntity<List<QCChecklistResponseDTO>> getByInspectionId(@PathVariable Long inspectionId) {
        List<QCChecklistResponseDTO> list = qcChecklistService.findByInspectionId(inspectionId);
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("/{id}")
    public ResponseEntity<QCChecklistResponseDTO> getById(@PathVariable Long id) {
        return qcChecklistService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }


    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        qcChecklistService.delete(id);
        return ResponseEntity.ok("QC Checklist item deleted successfully with ID: " + id);
    }
}
