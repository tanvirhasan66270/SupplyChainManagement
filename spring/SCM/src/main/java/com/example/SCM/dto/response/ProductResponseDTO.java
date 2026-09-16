package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class ProductResponseDTO {
    private Long id;
    private String productCode;
    private String name;
    private String unit;
    private int reorderPoint;
    private double unitCost;
    private int quantity;
    private double sellingPrice;
    private String hasExpiryDate;
    private double weight;
    private boolean isActive;
    private String availability;
    private String image;
    private Long categoryId;
    private String categoryName;
}