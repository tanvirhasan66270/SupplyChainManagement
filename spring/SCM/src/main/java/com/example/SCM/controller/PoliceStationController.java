package com.example.SCM.controller;

import com.example.SCM.dto.request.PoliceStationRequestDTO;
import com.example.SCM.dto.response.PoliceStationResponseDTO;
import com.example.SCM.service.PoliceStationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/policestation/")
@RequiredArgsConstructor
public class PoliceStationController {

    private final PoliceStationService policeStationService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PostMapping
    public ResponseEntity<PoliceStationResponseDTO> create(@RequestBody PoliceStationRequestDTO dto) {
        return new ResponseEntity<>(policeStationService.save(dto), HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PutMapping("{id}")
    public ResponseEntity<PoliceStationResponseDTO> update(@PathVariable Long id, @RequestBody PoliceStationRequestDTO dto) {
        return ResponseEntity.ok(policeStationService.update(id, dto));
    }

    @GetMapping
    public ResponseEntity<List<PoliceStationResponseDTO>> getAll(
            @RequestParam(value = "onlyActive", defaultValue = "true") boolean onlyActive) {
        List<PoliceStationResponseDTO> list = policeStationService.findAll(onlyActive);
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }

    // URL: /api/police-stations/district/1

    @GetMapping("district/{districtId}")
    public ResponseEntity<List<PoliceStationResponseDTO>> getByDistrictId(@PathVariable Long districtId) {
        List<PoliceStationResponseDTO> list = policeStationService.getByDistrictId(districtId);
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }

    @GetMapping("{id}")
    public ResponseEntity<PoliceStationResponseDTO> getById(@PathVariable Long id) {
        return policeStationService.getById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @DeleteMapping("{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        policeStationService.delete(id);
        return ResponseEntity.ok("Police Station deleted successfully");
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("search")
    public ResponseEntity<List<PoliceStationResponseDTO>> search(@RequestParam String keyword) {
        return ResponseEntity.ok(policeStationService.search(keyword));
    }
}
