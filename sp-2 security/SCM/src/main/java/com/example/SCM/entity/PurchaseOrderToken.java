package com.example.SCM.entity;

import com.example.SCM.enumClass.PurchaseOrderStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "purchase_order_tokens")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOrderToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String token;

    @Column(nullable = false)
    private boolean active = true;

    private LocalDateTime expiryDate;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime deletedAt;

    // Purchase Order History
    private Long purchaseOrderId;

    private String poNumber;

    private Long issuedBy;

    private Integer quantity;

    private Double totalAmount;

    private String currency;

    private LocalDate expectedDeliveryDate;

    @Enumerated(EnumType.STRING)
    private PurchaseOrderStatus status;

    private Long supplierId;

    private Long purchaseRequisitionId;

    private Long quotationId;

    private LocalDateTime purchaseCreatedAt;

    private LocalDateTime purchaseUpdatedAt;

    @PrePersist
    public void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}