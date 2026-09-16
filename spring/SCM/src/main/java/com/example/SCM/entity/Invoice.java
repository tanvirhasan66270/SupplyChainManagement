package com.example.SCM.entity;

import com.example.SCM.enumClass.InvoiceStatus;
import com.example.SCM.enumClass.PaymentMethod;
import com.example.SCM.enumClass.PaymentStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "invoices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String invoiceNumber;

    @Column(name = "order_id")
    private Long customerOrderId;

    @Column(nullable = false)
    private String customerEmail;

    private Long salesOfficerId;

    @Column(nullable = false)
    private String issuedToName;

    @Column(nullable = false)
    private String currency = "BDT";

    private double subtotal;

    private double taxRate = 0.0;

    private double taxAmount;

    private double discountAmount = 0.0;

    private double discountPercentage = 0.0;

    private double shippingFees = 0.0;

    private double totalAmount;

    private double paidAmount = 0.0;

    private double dueAmount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PaymentStatus paymentStatus = PaymentStatus.UNPAID;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    private String transactionReference;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InvoiceStatus invoiceStatus = InvoiceStatus.DRAFT;

    // Logistics Fields
    private LocalDate deliveryDate;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String deliveryAddress;

    // Audit Logs & Notes
    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(columnDefinition = "TEXT")
    private String cancelledReason;

    private LocalDate issuedAt;

    @Column(updatable = false) // making time lock
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    private LocalDateTime cancelledAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        syncStatusTimestamps();
        calculateFinancials();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        syncStatusTimestamps();
        calculateFinancials();
    }

    private void syncStatusTimestamps() {
        if (this.invoiceStatus == InvoiceStatus.ISSUED && this.issuedAt == null) {
            this.issuedAt = LocalDate.now();
        }
        if (this.invoiceStatus == InvoiceStatus.CANCELLED && this.cancelledAt == null) {
            this.cancelledAt = LocalDateTime.now();
        }
    }

    private void calculateFinancials() {
        if (this.discountPercentage > 0) {
            this.discountAmount = this.subtotal * (this.discountPercentage / 100.0);
        }

        this.taxAmount = this.subtotal * this.taxRate;
        this.totalAmount = this.subtotal + this.taxAmount + this.shippingFees - this.discountAmount;
        this.dueAmount = this.totalAmount - this.paidAmount;

        if (this.paidAmount <= 0) {
            this.paymentStatus = PaymentStatus.UNPAID;
        } else if (this.paidAmount < this.totalAmount) {
            this.paymentStatus = PaymentStatus.PARTIALLY_PAID;
        } else {
            this.paymentStatus = PaymentStatus.PAID;
        }
    }
}