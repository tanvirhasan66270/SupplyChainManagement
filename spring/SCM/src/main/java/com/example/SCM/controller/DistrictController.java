package com.example.SCM.controller;

import com.example.SCM.dto.request.DistrictRequestDTO;
import com.example.SCM.dto.response.DistrictResponseDTO;
import com.example.SCM.service.DistrictService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/district/")
@RequiredArgsConstructor
public class DistrictController {

    private final DistrictService districtService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PostMapping
    public ResponseEntity<DistrictResponseDTO> create(@RequestBody DistrictRequestDTO dto) {
        return new ResponseEntity<>(districtService.save(dto), HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @PutMapping("{id}")
    public ResponseEntity<DistrictResponseDTO> update(@PathVariable Long id, @RequestBody DistrictRequestDTO dto) {
        return ResponseEntity.ok(districtService.update(id, dto));
    }

    @GetMapping
    public ResponseEntity<List<DistrictResponseDTO>> getAll(
            @RequestParam(value = "onlyActive", defaultValue = "true") boolean onlyActive) {
        List<DistrictResponseDTO> list = districtService.findAll(onlyActive);
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }


    @GetMapping("division/{divisionId}")
    public ResponseEntity<List<DistrictResponseDTO>> getByDivisionId(@PathVariable Long divisionId) {
        List<DistrictResponseDTO> list = districtService.getByDivisionId(divisionId);
        return list.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(list);
    }

    @GetMapping("{id}")
    public ResponseEntity<DistrictResponseDTO> getById(@PathVariable Long id) {
        return districtService.getById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @DeleteMapping("{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        districtService.delete(id);
        return ResponseEntity.ok("District deleted successfully");
    }
}
