package com.example.SCM.entity;

import com.example.SCM.Util.ExecuteCalculations;
import com.example.SCM.enumClass.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "customer_orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CustomerOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String orderNumber;

    private String customerName;
    private String customerEmail;

    private double itemSubtotal;
    private double weight;

    @Enumerated(EnumType.STRING)
    private ServiceType serviceType = ServiceType.STANDARD;

    @Column(nullable = false)
    private String currency;

    private double codAmount = 0.0;
    private double deliveryCharge;
    private double totalAmount;

    @Column(nullable = false)
    private String paidAmount;

    private String dueAmount;

    @Enumerated(EnumType.STRING)
    private PaymentStatus paymentStatus = PaymentStatus.UNPAID;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    private String customerAccountNumber;

    private String paymentCheckImage;

    @Enumerated(EnumType.STRING)
    private CustomerOrderStatus status = CustomerOrderStatus.PENDING;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String deliveryAddress;

    @Column(nullable = false)
    private String deliveryPhone;

    private LocalDate estimatedDelivery;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(updatable = false, nullable = false)
    private LocalDateTime createdAt;

    // ── Zone management / Object Relations ───────────────────────
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @OneToMany(mappedBy = "customerOrder", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<OrderLineItem> lineItems = new ArrayList<>();

    // List of payment statements to track multiple payments
    @OneToMany(mappedBy = "customerOrder", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<PaymentStatement> paymentStatements = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.orderNumber == null) {
            this.orderNumber = "ORD-" + System.currentTimeMillis();
        }
        syncCustomerMetadata();
        executeCalculations();
    }

    @PreUpdate
    protected void onUpdate() {
        syncCustomerMetadata();
        executeCalculations();
    }

    private void syncCustomerMetadata() {
        if (this.customer != null) {
            this.customerName = this.customer.getName();
            this.customerEmail = this.customer.getEmail();
        }
    }

    public void executeCalculations() {
        // 1. Calculate the subtotal for all line items
        this.itemSubtotal = ExecuteCalculations.calculateItemSubtotal(this.lineItems);

        // 2. Calculate the total weight of all line items
        this.weight = ExecuteCalculations.calculateTotalOrderWeight(this.lineItems);

        // 3. Calculate delivery charge
        this.deliveryCharge = ExecuteCalculations.calculateDeliveryCharge(this.weight, this.serviceType, this.codAmount);

        // 4. Grand Total
        this.totalAmount = this.itemSubtotal + this.deliveryCharge;

        // 5. Calculate total paid amount ONLY from CONFIRMED_BY_OFFICER payments
        double totalPaid = 0.0;
        if (this.paymentStatements != null) {
            totalPaid = this.paymentStatements.stream()
                    .filter(ps -> ps.getIssueStatus() == PaymentIssueStatus.CONFIRMED_BY_OFFICER)
                    .mapToDouble(PaymentStatement::getPaidAmount)
                    .sum();
        }

        // COD amount is usually considered pre-paid or confirmed upon delivery,
        // so we keep it if you still use it as initial paid amount
        double finalPaid = totalPaid + this.codAmount;

        this.paidAmount = String.valueOf(finalPaid);

        // 6. Due Amount: Total - Paid
        double due = this.totalAmount - finalPaid;
        this.dueAmount = String.valueOf(due < 0 ? 0.0 : due);

        // Payment Status Logic
        if (finalPaid >= this.totalAmount && this.totalAmount > 0) {
            this.paymentStatus = PaymentStatus.PAID;
        } else if (finalPaid > 0 && finalPaid < this.totalAmount) {
            this.paymentStatus = PaymentStatus.PARTIALLY_PAID;
        } else {
            this.paymentStatus = PaymentStatus.UNPAID;
        }
    }

    public void addLineItem(OrderLineItem item) {
        if (item != null) {
            lineItems.add(item);
            item.setCustomerOrder(this);
        }
    }

    // Helper method to add a payment statement and refresh calculations
    public void addPaymentStatement(PaymentStatement statement) {
        if (statement != null) {
            paymentStatements.add(statement);
            statement.setCustomerOrder(this);
            executeCalculations();
        }
    }

    public Long getCustomerId() {
        return this.customer != null ? this.customer.getId() : null;
    }
}