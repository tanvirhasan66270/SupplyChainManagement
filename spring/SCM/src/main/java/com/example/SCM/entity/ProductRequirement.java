package com.example.SCM.entity;

import com.example.SCM.enumClass.ProductRequestStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "product_requirements")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductRequirement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String requestReferenceNo;

    private String customerOrderNumber;

    private String productName;

    @Column(columnDefinition = "TEXT")
    private String description;

    private int requestedQuantity;

    private String unit;

    private String targetPriceRange;

    private String urgencyLevel;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProductRequestStatus status = ProductRequestStatus.PENDING;

    private Long requestedByOfficerId;

    private String requestedByOfficerName;

    @Column(columnDefinition = "TEXT")
    private String procurementRemarks;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;}