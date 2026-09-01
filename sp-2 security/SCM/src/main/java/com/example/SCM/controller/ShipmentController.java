package com.example.SCM.controller;

import com.example.SCM.dto.request.ShipmentRequestDTO;
import com.example.SCM.dto.response.ShipmentResponseDTO;
import com.example.SCM.entity.User;
import com.example.SCM.service.ShipmentService;
import com.example.SCM.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.util.List;
import java.util.stream.Collectors;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/shipments")
@RequiredArgsConstructor
public class ShipmentController {

    private final ShipmentService shipmentService;
    private final SupplierRepository supplierRepository;

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPPLIER')")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ShipmentResponseDTO> create(
            @RequestPart("shipment") String shipmentJson,
            @RequestPart(value = "podFile", required = false) MultipartFile file) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        ShipmentRequestDTO dto = mapper.readValue(shipmentJson, ShipmentRequestDTO.class);
        return new ResponseEntity<>(shipmentService.save(dto, file), HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SUPPLIER')")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ShipmentResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("shipment") String shipmentJson,
            @RequestPart(value = "podFile", required = false) MultipartFile file) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        ShipmentRequestDTO dto = mapper.readValue(shipmentJson, ShipmentRequestDTO.class);
        return ResponseEntity.ok(shipmentService.update(id, dto, file));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'SUPPLIER',  'PROCUREMENT',  'QC_INSPECTOR', 'SALES_OFFICER')")
    @GetMapping
    public ResponseEntity<List<ShipmentResponseDTO>> getAll() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        List<ShipmentResponseDTO> list = shipmentService.findAll();

        if (principal instanceof User currentUser) {
            if ("SUPPLIER".equalsIgnoreCase(currentUser.getRole().name())) {
                return supplierRepository.findByUserId(currentUser.getId())
                        .map(supplier -> {
                            List<ShipmentResponseDTO> supplierFiltered = list.stream()
                                    .filter(s -> s.getSupplierId() != null && s.getSupplierId().equals(supplier.getId()))
                                    .collect(Collectors.toList());
                            return ResponseEntity.ok(supplierFiltered);
                        })
                        .orElse(ResponseEntity.ok(java.util.Collections.emptyList()));
            }
        }

        if (list.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(list);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'SUPPLIER', 'PROCUREMENT', 'QC_INSPECTOR', 'SALES_OFFICER')")
    @GetMapping("/{id}")
    public ResponseEntity<ShipmentResponseDTO> getById(@PathVariable Long id) {
        return shipmentService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        shipmentService.delete(id);
        return ResponseEntity.ok("Shipment record successfully removed from enterprise cluster");
    }
}
