package com.example.SCM.entity;

import com.example.SCM.enumClass.PaymentMethod;
import com.example.SCM.enumClass.PaymentIssueStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "payment_statements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PaymentStatement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private double paidAmount;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    private String customerAccountNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentIssueStatus issueStatus = PaymentIssueStatus.PENDING_VERIFICATION;

    private String transactionId;

    private String paymentCheckImage;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_order_id", nullable = false)
    private CustomerOrder customerOrder;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
        if (this.transactionId == null) {
            this.transactionId = "TXN-" + System.currentTimeMillis();
        }
        if (this.issueStatus == null) {
            this.issueStatus = PaymentIssueStatus.PENDING_VERIFICATION;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}