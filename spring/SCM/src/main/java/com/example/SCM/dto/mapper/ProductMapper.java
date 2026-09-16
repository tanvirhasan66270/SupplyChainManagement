package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.ProductRequestDTO;
import com.example.SCM.dto.response.ProductResponseDTO;
import com.example.SCM.entity.Category;
import com.example.SCM.entity.Product;
import org.springframework.stereotype.Component;

@Component
public class ProductMapper {

    public ProductResponseDTO convertTOResponseDTO(Product entity) {

        ProductResponseDTO dto = new ProductResponseDTO();
        dto.setId(entity.getId());
        dto.setProductCode(entity.getProductCode());
        dto.setName(entity.getName());
        dto.setUnit(entity.getUnit());
        dto.setReorderPoint(entity.getReorderPoint());
        dto.setUnitCost(entity.getUnitCost());
        dto.setQuantity(entity.getQuantity());
        dto.setSellingPrice(entity.getSellingPrice());
        dto.setHasExpiryDate(entity.getHasExpiryDate());
        dto.setWeight(entity.getWeight());
        dto.setActive(entity.isActive());
        dto.setAvailability(entity.getAvailability());
        dto.setImage(entity.getImage());

        if (entity.getCategory() != null) {
            dto.setCategoryId(entity.getCategory().getId());
            dto.setCategoryName(entity.getCategory().getCategoryName());
        }
        return dto;
    }

    public Product toEntity(ProductRequestDTO dto, Category category) {

        Product entity = new Product();
        entity.setProductCode(dto.getProductCode());
        entity.setName(dto.getName());
        entity.setUnit(dto.getUnit());
        entity.setReorderPoint(dto.getReorderPoint());
        entity.setUnitCost(dto.getUnitCost());
        entity.setQuantity(dto.getQuantity());
        entity.setSellingPrice(dto.getSellingPrice());
        entity.setHasExpiryDate(dto.getHasExpiryDate());
        entity.setWeight(dto.getWeight());
        entity.setActive(dto.isActive());
        entity.setAvailability(dto.getAvailability());
        entity.setImage(dto.getImage());
        entity.setCategory(category);

        return entity;
    }

    public void updateEntity(ProductRequestDTO dto, Product entity, Category category) {
        if (dto == null || entity == null) return;

        if (dto.getProductCode() != null) entity.setProductCode(dto.getProductCode());
        if (dto.getName() != null) entity.setName(dto.getName());
        if (dto.getUnit() != null) entity.setUnit(dto.getUnit());
        entity.setReorderPoint(dto.getReorderPoint());
        entity.setUnitCost(dto.getUnitCost());
        entity.setQuantity(dto.getQuantity());
        entity.setSellingPrice(dto.getSellingPrice());
        if (dto.getHasExpiryDate() != null) entity.setHasExpiryDate(dto.getHasExpiryDate());
        entity.setWeight(dto.getWeight());
        entity.setActive(dto.isActive());
        if (dto.getAvailability() != null) entity.setAvailability(dto.getAvailability());
        if (dto.getImage() != null) entity.setImage(dto.getImage());
        if (category != null) entity.setCategory(category);
    }
}