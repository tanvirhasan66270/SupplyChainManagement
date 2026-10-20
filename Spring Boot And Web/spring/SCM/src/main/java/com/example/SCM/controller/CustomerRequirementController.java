package com.example.SCM.controller;

import com.example.SCM.dto.request.CustomerRequirementRequest;
import com.example.SCM.dto.response.CustomerRequirementResponse;
import com.example.SCM.service.CustomerRequirementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer-requirements")
@RequiredArgsConstructor
@CrossOrigin("*")
public class CustomerRequirementController {

    private final CustomerRequirementService service;

    @PostMapping("/public/submit")
    public ResponseEntity<CustomerRequirementResponse> submitRequirement(@RequestBody CustomerRequirementRequest request) {
        return ResponseEntity.ok(service.save(request));
    }

    @GetMapping
    public ResponseEntity<List<CustomerRequirementResponse>> getAllRequirements() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CustomerRequirementResponse> getRequirementById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<CustomerRequirementResponse> updateStatus(@PathVariable Long id, @RequestParam String status) {
        return ResponseEntity.ok(service.updateStatus(id, status));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRequirement(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
