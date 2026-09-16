package com.example.SCM.controller;

import com.example.SCM.dto.request.DailyReportRequestDTO;
import com.example.SCM.dto.response.DailyReportResponseDTO;
import com.example.SCM.service.DailyReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class DailyReportController {

    private final DailyReportService reportService;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<DailyReportResponseDTO> create(
            @RequestPart("report") DailyReportRequestDTO dto,
            @RequestPart(value = "attachment", required = false) MultipartFile attachment
    ) {
        DailyReportResponseDTO response = reportService.save(dto, attachment);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PutMapping(value = "{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<DailyReportResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("report") DailyReportRequestDTO dto,
            @RequestPart(value = "attachment", required = false) MultipartFile attachment
    ) {
        return ResponseEntity.ok(reportService.update(id, dto, attachment));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<DailyReportResponseDTO>> getAll() {
        List<DailyReportResponseDTO> list = reportService.findAll();
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("{id}")
    public ResponseEntity<DailyReportResponseDTO> getById(@PathVariable Long id) {
        return reportService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("warehouse/{warehouseId}")
    public ResponseEntity<List<DailyReportResponseDTO>> getByWarehouse(@PathVariable String warehouseId) {
        List<DailyReportResponseDTO> list = reportService.getByWarehouse(warehouseId);
        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    @Transactional
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PatchMapping("approve/{id}")
    public ResponseEntity<DailyReportResponseDTO> approve(@PathVariable Long id) {
        return ResponseEntity.ok(reportService.approveReport(id, null));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("email-approve")
    public ResponseEntity<String> emailApprove(
            @RequestParam Long id,
            @RequestParam String approverId
    ) {
        reportService.approveReport(id, approverId);
        return ResponseEntity.ok("""
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; margin-top: 60px; background-color: #F7FAFC; }
                    .card { display: inline-block; padding: 35px; border: 1px solid #38A169; border-radius: 12px; background-color: #F0FFF4; box-shadow: 0 4px 10px rgba(56,161,105,0.1); }
                    h2 { color: #38A169; margin: 0 0 12px 0; font-size: 24px; }
                    p { color: #2D3748; margin: 0; font-size: 15px; }
                </style>
            </head>
            <body>
                <div class="card">
                    <h2>✔ Report Approved Successfully!</h2>
                    <p>Daily Report ID: <b>#%d</b> has been officially locked and marked as <b>APPROVED</b> in SCM Cluster Nodes.</p>
                </div>
            </body>
            </html>
            """.formatted(id));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @DeleteMapping("{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        reportService.delete(id);
        return ResponseEntity.ok("Daily report record purged successfully.");
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'PROCUREMENT', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping("uploads/reports/{filename:.+}")
//    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'QC_INSPECTOR', 'LOGISTICS_OFFICER')")
    public ResponseEntity<Resource> viewReportImage(@PathVariable String filename) {
        try {
            Path fileStorageLocation = Paths.get(uploadDir).resolve("reports").normalize();
            Path filePath = fileStorageLocation.resolve(filename).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() || resource.isReadable()) {
                String contentType = "image/jpeg";
                if (filename.toLowerCase().endsWith(".png")) {
                    contentType = "image/png";
                } else if (filename.toLowerCase().endsWith(".pdf")) {
                    contentType = "application/pdf";
                }
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
