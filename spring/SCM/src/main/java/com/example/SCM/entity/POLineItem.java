package com.example.SCM.entity;

import com.example.SCM.enumClass.POLineItemStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "po_line_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class POLineItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "po_id", nullable = false)
    private PurchaseOrder purchaseOrder;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    private int quantity;

    private double unitPrice;

    private double lineTotal; // calculate field

    private String quotationRef;

    private String poNumber;

    private LocalDate deliveryDate;

    private String shipmentMethod;

    private String trackingNumber;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Enumerated(EnumType.STRING)
    private POLineItemStatus status = POLineItemStatus.PENDING;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        calculateLineTotal();
        if (this.status == null) {
            this.status = POLineItemStatus.PENDING;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        calculateLineTotal();
    }

    private void calculateLineTotal() {
        if (this.status == POLineItemStatus.CANCELLED) {
            this.lineTotal = 0.0;
        } else {
            this.lineTotal = this.quantity * this.unitPrice;
        }
    }
}