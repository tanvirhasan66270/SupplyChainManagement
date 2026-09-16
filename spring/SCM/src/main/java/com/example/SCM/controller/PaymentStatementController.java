package com.example.SCM.controller;

import com.example.SCM.dto.request.PaymentStatementRequestDTO;
import com.example.SCM.dto.response.PaymentStatementResponseDTO;
import com.example.SCM.enumClass.PaymentIssueStatus;
import com.example.SCM.service.PaymentStatementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/payment-statements")
@RequiredArgsConstructor
public class PaymentStatementController {

    private final PaymentStatementService paymentStatementService;

    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER')")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PaymentStatementResponseDTO> addPayment(
            @RequestPart("payment") PaymentStatementRequestDTO requestDTO,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        PaymentStatementResponseDTO response = paymentStatementService.addPayment(requestDTO, image);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER')")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PaymentStatementResponseDTO> updatePayment(
            @PathVariable Long id,
            @RequestPart("payment") PaymentStatementRequestDTO requestDTO,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        PaymentStatementResponseDTO response = paymentStatementService.updatePayment(id, requestDTO, image);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'COMMERCIAL_OFFICER')")
    @PatchMapping("/{id}/status")
    public ResponseEntity<PaymentStatementResponseDTO> updatePaymentStatus(
            @PathVariable Long id,
            @RequestParam String status
    ) {
        PaymentIssueStatus issueStatus = PaymentIssueStatus.valueOf(status.toUpperCase());
        PaymentStatementResponseDTO response = paymentStatementService.updatePaymentStatus(id, issueStatus);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'COMMERCIAL_OFFICER', 'CUSTOMER')")
    @GetMapping("/order/{orderId}")
    public ResponseEntity<List<PaymentStatementResponseDTO>> getPaymentsByOrderId(@PathVariable Long orderId) {
        return ResponseEntity.ok(paymentStatementService.getPaymentsByOrderId(orderId));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'COMMERCIAL_OFFICER', 'CUSTOMER')")
    @GetMapping("/order-number/{orderNumber}")
    public ResponseEntity<List<PaymentStatementResponseDTO>> getPaymentsByOrderNumber(@PathVariable String orderNumber) {
        return ResponseEntity.ok(paymentStatementService.getPaymentsByOrderNumber(orderNumber));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'COMMERCIAL_OFFICER')")
    @GetMapping("/status/{status}")
    public ResponseEntity<List<PaymentStatementResponseDTO>> getPaymentsByStatus(@PathVariable String status) {
        PaymentIssueStatus issueStatus = PaymentIssueStatus.valueOf(status.toUpperCase());
        return ResponseEntity.ok(paymentStatementService.getPaymentsByStatus(issueStatus));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'COMMERCIAL_OFFICER', 'CUSTOMER')")
    @GetMapping("/{id}")
    public ResponseEntity<PaymentStatementResponseDTO> getPaymentById(@PathVariable Long id) {
        return ResponseEntity.ok(paymentStatementService.getPaymentById(id));
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deletePayment(@PathVariable Long id) {
        paymentStatementService.deletePayment(id);
        return ResponseEntity.ok("Payment statement deleted successfully.");
    }
}
