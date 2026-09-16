package com.example.SCM.entity;

import com.example.SCM.enumClass.UrgencyLevel;
import com.example.SCM.enumClass.PurchaseRequisitionStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Entity
@Table(name = "purchase_requisitions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseRequisition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long requestedBy;

    @JsonIgnore
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "requisition_products",
            joinColumns = @JoinColumn(name = "requisition_id"),
            inverseJoinColumns = @JoinColumn(name = "product_id")
    )
    private Set<Product> products = new LinkedHashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "requisition_suppliers",
            joinColumns = @JoinColumn(name = "requisition_id"),
            inverseJoinColumns = @JoinColumn(name = "supplier_id")
    )
    private Set<Supplier> suppliers = new LinkedHashSet<>();

    @Column(nullable = false)
    private String currency;

    private int quantityRequired;

    @Enumerated(EnumType.STRING)
    private UrgencyLevel urgencyLevel;

    @Column(nullable = false)
    private LocalDate requiredByDate;

    @Enumerated(EnumType.STRING)
    private PurchaseRequisitionStatus approvalStatus = PurchaseRequisitionStatus.PENDING;

    private Long approvedBy;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(columnDefinition = "TEXT")
    private String productNames;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.approvalStatus == null) {
            this.approvalStatus = PurchaseRequisitionStatus.PENDING;
        }
        this.compileProductNames();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        this.compileProductNames();
    }


    private void compileProductNames() {
        if (this.products != null && !this.products.isEmpty()) {
            this.productNames = this.products.stream()
                    .map(Product::getName)
                    .collect(Collectors.joining(", "));
        }
    }
}