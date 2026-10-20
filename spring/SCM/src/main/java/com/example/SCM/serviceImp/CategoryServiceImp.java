package com.example.SCM.serviceImp;

import com.example.SCM.dto.response.CategoryResponseDTO;
import com.example.SCM.dto.mapper.CategoryMapper;
import com.example.SCM.dto.request.CategoryRequestDTO;
import com.example.SCM.entity.Category;
import com.example.SCM.repository.CategoryRepository;
import com.example.SCM.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryServiceImp implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final CategoryMapper categoryMapper;


    @Transactional
    @Override
    public CategoryResponseDTO save(CategoryRequestDTO dto) {

        Optional<Category> existingCategory = categoryRepository.findByCategoryName(dto.getCategoryName());
        if (existingCategory.isPresent()) {
            throw new RuntimeException("Category name '" + dto.getCategoryName() + "' already exists!");
        }

        // DTO -> Entity
        Category category = categoryMapper.toEntity(dto);
        Category savedCategory = categoryRepository.save(category);

        // Entity -> Response DTO
        return categoryMapper.toResponseDTO(savedCategory);
    }


    @Transactional
    @Override
    public CategoryResponseDTO update(Long id, CategoryRequestDTO dto) {


        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found with ID: " + id));

        if (dto.getCategoryName() != null && !dto.getCategoryName().equals(category.getCategoryName())) {
            Optional<Category> duplicateCheck = categoryRepository.findByCategoryName(dto.getCategoryName());
            if (duplicateCheck.isPresent()) {
                throw new RuntimeException("Category name '" + dto.getCategoryName() + "' already taken by another category!");
            }
        }

        categoryMapper.updateEntity(dto, category);

        Category updatedCategory = categoryRepository.save(category);

        return categoryMapper.toResponseDTO(updatedCategory);
    }


    @Transactional(readOnly = true)
    @Override
    public List<CategoryResponseDTO> findAll() {
        return categoryRepository.findAll()
                .stream()
                .map(categoryMapper::toResponseDTO)
                .collect(Collectors.toList());
    }


    @Transactional(readOnly = true)
    @Override
    public Optional<CategoryResponseDTO> getById(Long id) {
        return categoryRepository.findById(id)
                .map(categoryMapper::toResponseDTO);
    }


    @Transactional
    @Override
    public void delete(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found with ID: " + id));

        categoryRepository.delete(category);
    }

}