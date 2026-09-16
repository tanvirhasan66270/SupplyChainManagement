package com.example.SCM.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "products")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column( unique = true)
    private String productCode;

    @Column(nullable = false)
    private String name;

    private String unit;

    private int reorderPoint;

    private double unitCost;

    private int quantity;

    private double sellingPrice;

    private String hasExpiryDate;

    @Column(name = "weight", nullable = false)
    private double weight;

    @Column( nullable = false)
    private boolean isActive = true;

    private String availability;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String image; // Base64

    // Relationship mapping with category
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;
}