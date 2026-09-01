package com.example.SCM.entity;

import com.example.SCM.enumClass.PurchaseRequisitionStatus;
import com.example.SCM.enumClass.UrgencyLevel;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "purchase_requisition_tokens")
@Data
@NoArgsConstructor
@AllArgsConstructor

public class PurchaseRequisitionToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Unique Token
    @Column(nullable = false, unique = true, length = 200)
    private String token;


    private boolean active = true;

    // Token Creation Time
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

   // Auto Delete Time
    private LocalDateTime deletedAt;

    // ===========================
    // Purchase Requisition History
    // ===========================

    private Long purchaseRequisitionId;

    private Long requestedBy;

    private String currency;

    private Integer quantityRequired;

    @Enumerated(EnumType.STRING)
    private UrgencyLevel urgencyLevel;

    private LocalDate requiredByDate;

    @Enumerated(EnumType.STRING)
    private PurchaseRequisitionStatus approvalStatus;

    private Long approvedBy;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    private LocalDateTime purchaseCreatedAt;

    private LocalDateTime purchaseUpdatedAt;

    private Integer totalProducts;

    @Column(columnDefinition = "TEXT")
    private String productNames;

    @Column(columnDefinition = "TEXT")
    private String supplierNames;

    @PrePersist
    public void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
