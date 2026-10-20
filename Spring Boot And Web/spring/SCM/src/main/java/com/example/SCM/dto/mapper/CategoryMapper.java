package com.example.SCM.dto.mapper;

import com.example.SCM.dto.response.CategoryResponseDTO;
import com.example.SCM.dto.request.CategoryRequestDTO;
import com.example.SCM.entity.Category;
import org.springframework.stereotype.Component;


@Component
public class CategoryMapper {


    public Category toEntity(CategoryRequestDTO dto) {


        Category category = new Category();
        category.setCategoryName(dto.getCategoryName());
        category.setDescription(dto.getDescription());

        return category;
    }


    public CategoryResponseDTO toResponseDTO(Category category) {

        CategoryResponseDTO dto = new CategoryResponseDTO();
        dto.setId(category.getId());
        dto.setCategoryName(category.getCategoryName());
        dto.setDescription(category.getDescription());

        return dto;
    }


    public void updateEntity(CategoryRequestDTO dto, Category category) {

        if (dto.getCategoryName() != null && !dto.getCategoryName().trim().isEmpty()) {
            category.setCategoryName(dto.getCategoryName());
        }

        if (dto.getDescription() != null) {
            category.setDescription(dto.getDescription());
        }
    }

}