package com.example.SCM.controller;

import com.example.SCM.dto.mapper.CustomerOrderMapper;
import com.example.SCM.dto.request.CustomerOrderRequestDTO;
import com.example.SCM.dto.response.CustomerOrderResponseDTO;
import com.example.SCM.repository.CustomerOrderRepository;
import com.example.SCM.service.CustomerOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Objects;

@RestController
@RequestMapping("/api/customerOrders")
@RequiredArgsConstructor
public class CustomerOrderController {

    private final CustomerOrderService orderService;
    private final CustomerOrderRepository orderRepository;
    private final CustomerOrderMapper orderMapper;

    // 1. Place a New Order
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'CUSTOMER')")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<CustomerOrderResponseDTO> createOrder(
            @RequestPart("order") CustomerOrderRequestDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        CustomerOrderResponseDTO response = orderService.save(dto, image);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // 2. General Update Order Metadata
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER') or @customerOrderSecurity.isOwner(#id, authentication)")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<CustomerOrderResponseDTO> updateOrder(
            @PathVariable Long id,
            @RequestPart("order") CustomerOrderRequestDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        CustomerOrderResponseDTO response = orderService.update(id, dto, image);
        return ResponseEntity.ok(response);
    }
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'CUSTOMER', 'PROCUREMENT', 'DRIVER', 'QC_INSPECTOR', 'SUPPLIER')")
    @GetMapping
    public ResponseEntity<List<CustomerOrderResponseDTO>> getAllOrders(Authentication authentication) {
        String currentUsername = authentication.getName();
        System.out.println(currentUsername);


        boolean isCustomer = authentication.getAuthorities().stream()
                .anyMatch(a -> Objects.equals(a.getAuthority(), "CUSTOMER") || Objects.equals(a.getAuthority(), "ROLE_CUSTOMER"));

        List<CustomerOrderResponseDTO> responseList;

        if (isCustomer) {
            responseList = orderService.findByCustomerUsername(currentUsername);
        } else {
            responseList = orderService.findAll();
        }

        return ResponseEntity.ok(responseList);
    }

    @GetMapping("/customer")
    public ResponseEntity<List<CustomerOrderResponseDTO>> getByEmail(Authentication auth){
        List<CustomerOrderResponseDTO> listC = orderRepository.findByCustomerEmail(auth.getName())
                .stream().map(orderMapper::convertTOResponseDTO)
                .toList();
        return ResponseEntity.ok(listC);
    }


    // 4. Find Single Order Context By ID
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER', 'LOGISTICS_OFFICER', 'COMMERCIAL_OFFICER', 'PROCUREMENT', 'DRIVER', 'QC_INSPECTOR', 'CUSTOMER', 'SUPPLIER') or @customerOrderSecurity.isOwner(#id, authentication)")
    @GetMapping("/{id}")
    public ResponseEntity<CustomerOrderResponseDTO> getOrderById(@PathVariable Long id) {
        return orderService.getById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // 5. Delete Order Record
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteOrder(@PathVariable Long id) {
        orderService.delete(id);
        return ResponseEntity.ok("Customer order instance purged successfully from cluster cache mapping.");
    }

    // 6. Live Track Package via Order Number
    @PreAuthorize("permitAll()")
    @GetMapping("/track")
    public ResponseEntity<CustomerOrderResponseDTO> trackOrderByNumber(@RequestParam String orderNumber) {
        return orderService.trackOrder(orderNumber)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // 8. Dedicated Status Lifecycle Update Endpoint
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER') or @customerOrderSecurity.isOwner(#id, authentication)")
    @PatchMapping("/{id}/status")
    public ResponseEntity<CustomerOrderResponseDTO> updateOrderStatus(
            @PathVariable Long id,
            @RequestParam String status
    ) {
        CustomerOrderResponseDTO response = orderService.updateOrderStatus(id, status);
        return ResponseEntity.ok(response);
    }

    // 7. Two-Step Email Link Verification Webhook
    @PreAuthorize("permitAll()")
    @GetMapping("/verify-link")
    public ResponseEntity<String> executeVerificationAndTriggerEmail(
            @RequestParam Long orderId,
            @RequestParam double amountPaid,
            @RequestParam String method) {

        orderService.processFinalPaymentConfirmation(orderId, amountPaid, method);

        return ResponseEntity.ok("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset='UTF-8'>
                <title>Payment Verified</title>
            </head>
            <body style='font-family: Arial, sans-serif; text-align: center; padding: 50px; background-color: #f7fafc;'>
                <div style='max-width: 500px; margin: auto; padding: 30px; border: 1px solid #e2e8f0; border-radius: 10px; background-color: #fff; box-shadow: 0 4px 6px rgba(0,0,0,0.05);'>
                    <h2 style='color: #2F855A; margin-bottom: 10px;'>Payment Matrix Verified!</h2>
                    <p style='color: #4A5568; line-height: 1.5;'>Thank you. Your order confirmation invoice and tracking metrics have been successfully transmitted via email system.</p>
                </div>
            </body>
            </html>
        """);
    }
}
