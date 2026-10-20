package com.example.SCM.entity;

import com.example.SCM.enumClass.QuotationStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "quotations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Quotation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @Column(nullable = false, unique = true, length = 50)
    private String quotationNumber;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = false)
    private Supplier supplier;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    private String productName;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "purchase_requisition_id", nullable = false)
    private PurchaseRequisition purchaseRequisition;

    @Column(nullable = false)
    private LocalDate validUntil;

    private int leadTimeDays;


    @Column(nullable = false)
    private LocalDate receivedAt;

    @Enumerated(EnumType.STRING)
    private QuotationStatus status = QuotationStatus.PENDING;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String productDescription;

    private double unitPrice;

    @Column(nullable = false)
    private Integer quantity;

    private double totalPrice;
    private double isSelected;


    @Column(nullable = false)
    private LocalDate deliveryTime;


    private String warranty;

    @Column(columnDefinition = "TEXT")
    private String notes;


    private String attachmentUrl;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();

        if(this.validUntil == null){
            this.validUntil = LocalDate.now().plusDays(30);
        }

        calculateTotalPrice();

        if (this.status == null) {
            this.status = QuotationStatus.PENDING;
        }
        if (this.quotationNumber == null) {
            this.quotationNumber = "QTN-" + System.currentTimeMillis();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        calculateTotalPrice();
    }

    private void calculateTotalPrice() {
        if (this.quantity != null) {
            this.totalPrice = this.unitPrice * this.quantity;
        }
    }
}