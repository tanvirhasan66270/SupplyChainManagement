package com.example.SCM.controller;

import com.example.SCM.dto.request.CustomerRequestDTO;
import com.example.SCM.dto.response.CustomerResponseDTO;
import com.example.SCM.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/customer")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @PreAuthorize("permitAll() or hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'LOGISTICS_OFFICER')")
    @PostMapping
    public ResponseEntity<CustomerResponseDTO> create(
            @RequestPart("customer") CustomerRequestDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        CustomerResponseDTO response = customerService.save(dto, image);
        return new ResponseEntity<>(
                response,
                HttpStatus.CREATED
        );
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'LOGISTICS_OFFICER')")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<CustomerResponseDTO> update(
            @PathVariable Long id,
            @RequestPart("customer") CustomerRequestDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        return ResponseEntity.ok(customerService.update(id, dto, image));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<CustomerResponseDTO>> getAll() {
        List<CustomerResponseDTO> list = customerService.findAll();

        if (list.isEmpty()) {
            return ResponseEntity.noContent().build(); // 204
        }

        return ResponseEntity.ok(list);
    }

    //  এখানে @customerSecurity.isSelf যোগ করা হলো, যাতে কাস্টমার শুধু নিজের আইডি দিয়ে দেখতে পারে
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER') or @customerSecurity.isSelf(#id, authentication)")
    @GetMapping("/{id}")
    public ResponseEntity<CustomerResponseDTO> getById(@PathVariable Long id) {
        return customerService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'LOGISTICS_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        customerService.delete(id);
        return ResponseEntity.ok("Customer matrix index and associated auth account purged successfully.");
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'CUSTOMER', 'LOGISTICS_OFFICER', 'PROCUREMENT', 'COMMERCIAL_OFFICER', 'DRIVER', 'QC_INSPECTOR', 'SUPPLIER')")
    @GetMapping("/user/{id}")
    public ResponseEntity<CustomerResponseDTO> getByUserId(@PathVariable Long id) {
        return customerService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

}
