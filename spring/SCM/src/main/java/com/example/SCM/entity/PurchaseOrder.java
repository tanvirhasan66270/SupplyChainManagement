package com.example.SCM.entity;

import com.example.SCM.enumClass.PurchaseOrderStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "purchase_orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column( nullable = false, unique = true)
    private String poNumber;

    @Column(name = "issued_by", nullable = false)
    private Long issuedBy;

    private Integer quantity;

    @Column( nullable = false)
    private double totalAmount;

    @Column(nullable = false)
    private String currency ; //USD



    @Column( nullable = false)
    private LocalDate expectedDeliveryDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PurchaseOrderStatus status = PurchaseOrderStatus.DRAFT;

    // FK → Supplier ( auto Load from Quotation)
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = false)
    private Supplier supplier;

    // FK → PurchaseRequisition (auto Load from Quotation)
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "purchase_requisition_id", nullable = false)
    private PurchaseRequisition purchaseRequisition;

    // FK → Quotation
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quotation_id", nullable = false)
    private Quotation quotation;

    @Column( updatable = false)
    private LocalDateTime createdAt;


    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = PurchaseOrderStatus.DRAFT;
        }
        if (this.poNumber == null) {
            this.poNumber = "PO-" + System.currentTimeMillis();
        }
        if (this.currency == null) {
            this.currency = "USD";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}