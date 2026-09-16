package com.example.SCM.controller;

import com.example.SCM.dto.response.CategoryResponseDTO;
import com.example.SCM.dto.request.CategoryRequestDTO;
import com.example.SCM.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/category")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER')")
    @PostMapping
    public ResponseEntity<CategoryResponseDTO> save(@RequestBody CategoryRequestDTO dto) {
        CategoryResponseDTO response = categoryService.save(dto);
        return new ResponseEntity<>(
                response,
                HttpStatus.CREATED
        );
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER')")
    @PutMapping("/{id}")
    public ResponseEntity<CategoryResponseDTO> update(
            @PathVariable Long id,
            @RequestBody CategoryRequestDTO dto
    ) {
        CategoryResponseDTO response = categoryService.update(id, dto);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping
    public ResponseEntity<List<CategoryResponseDTO>> getAll() {
        List<CategoryResponseDTO> list = categoryService.findAll();

        if (list.isEmpty()) {
            return ResponseEntity.noContent().build(); // 204
        }

        return ResponseEntity.ok(list);
    }

    @GetMapping("/public")
    public ResponseEntity<List<CategoryResponseDTO>> getAllPublic() {
        List<CategoryResponseDTO> list = categoryService.findAll();
        if (list.isEmpty()) return ResponseEntity.noContent().build();
        return ResponseEntity.ok(list);
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/{id}")
    public ResponseEntity<CategoryResponseDTO> getById(@PathVariable Long id) {
        return categoryService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'SALES_OFFICER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        categoryService.delete(id);
        return ResponseEntity.ok("Category and its cascades deleted successfully!");
    }

}
