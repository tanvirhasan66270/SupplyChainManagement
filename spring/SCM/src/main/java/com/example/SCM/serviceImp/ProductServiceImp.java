package com.example.SCM.serviceImp;

import com.example.SCM.dto.response.ProductResponseDTO;
import com.example.SCM.dto.mapper.ProductMapper;
import com.example.SCM.dto.request.ProductRequestDTO;
import com.example.SCM.entity.Category;
import com.example.SCM.entity.Product;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.repository.CategoryRepository;
import com.example.SCM.repository.ProductRepository;
import com.example.SCM.service.ActivityLogService;
import com.example.SCM.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductServiceImp implements ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ProductMapper productMapper;
    private final ActivityLogService activityLogService;
    private final HttpServletRequest request;


    private String resolveCurrentUserId() {
        String userId = request.getHeader("X-User-Id");
        if (userId != null && !userId.isBlank()) {
            return userId;
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !authentication.getName().equals("anonymousUser")) {
            return authentication.getName();
        }
        return "UNKNOWN_USER";
    }

    // from application.properties upload deractory path loaded
    @Value("${image.upload.dir}")
    private String uploadDir;


    @Transactional
    @Override
    public ProductResponseDTO save(ProductRequestDTO dto, MultipartFile image) {
        if (dto == null) {
            throw new IllegalArgumentException("Product request data cannot be null");
        }

        // duplicate product check
        if (dto.getProductCode() != null && !dto.getProductCode().trim().isEmpty()) {
            Optional<Product> existingProduct = productRepository.findByProductCode(dto.getProductCode());
            if (existingProduct.isPresent()) {
                throw new RuntimeException("Product code '" + dto.getProductCode() + "' already exists!");
            }
        }

        // finding relasional catagory from database
        Category category = categoryRepository.findById(dto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found with ID: " + dto.getCategoryId()));


        if (image != null && !image.isEmpty()) {
            String uploadedFileName = uploadProductImage(image, dto.getName());
            dto.setImage(uploadedFileName);
        }

        //Mapper from Entity- convert and database save (with weight )
        Product product = productMapper.toEntity(dto, category);
        Product savedProduct = productRepository.save(product);

       //Activity log
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "CREATE",
                "PRODUCT",
                savedProduct.getId().toString(),
                "New Product successfully created. Code: "
                        + savedProduct.getProductCode() + ", Name: " + savedProduct.getName(),
                null,
                "{\"productCode\":\"" + savedProduct.getProductCode() + "\", \"name\":\"" + savedProduct.getName() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return productMapper.convertTOResponseDTO(savedProduct);
    }


    @Transactional
    @Override
    public ProductResponseDTO update(Long id, ProductRequestDTO dto, MultipartFile image) {
        if (dto == null) {
            throw new IllegalArgumentException("Product request data cannot be null");
        }

        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + id));

        String oldName = product.getName();
        String oldCode = product.getProductCode();
        Long oldCategoryId = product.getCategory() != null ? product.getCategory().getId() : null;

        if (dto.getProductCode() != null && !dto.getProductCode().equals(product.getProductCode())) {
            Optional<Product> duplicateCheck = productRepository.findByProductCode(dto.getProductCode());
            if (duplicateCheck.isPresent()) {
                throw new RuntimeException("Product code '" + dto.getProductCode() + "' is already taken!");
            }
        }

        Category category = product.getCategory();
        if (dto.getCategoryId() != null && !dto.getCategoryId().equals(category.getId())) {
            category = categoryRepository.findById(dto.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("New Category not found with ID: " + dto.getCategoryId()));
        }

        if (image != null && !image.isEmpty()) {
            String newImageName = uploadProductImage(image, dto.getName());
            dto.setImage(newImageName);
        } else {
            dto.setImage(product.getImage());
        }

        productMapper.updateEntity(dto, product, category);
        Product updatedProduct = productRepository.save(product);

        //Activity log
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE",
                "PRODUCT",
                updatedProduct.getId().toString(),
                "Product metadata updated for Code: " + updatedProduct.getProductCode(),
                "{\"name\":\"" + oldName + "\", \"code\":\"" + oldCode + "\", \"categoryId\":" + oldCategoryId + "}",
                "{\"name\":\"" + updatedProduct.getName() + "\", \"code\":\"" + updatedProduct.getProductCode() + "\", \"categoryId\":" + updatedProduct.getCategory().getId() + "}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return productMapper.convertTOResponseDTO(updatedProduct);
    }


    @Override
    @Transactional(readOnly = true)
    public List<ProductResponseDTO> findAll() {
        return productRepository.findAll().stream()
                .map(productMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductResponseDTO> findByCategoryId(Long categoryId) {
        return productRepository.findByCategoryId(categoryId).stream()
                .map(productMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }


    @Override
    @Transactional(readOnly = true)
    public Optional<ProductResponseDTO> getById(Long id) {
        return productRepository.findById(id)
                .map(productMapper::convertTOResponseDTO);
    }


    @Override
    @Transactional
    public void delete(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + id));

        String deletedProductCode = product.getProductCode();
        String deletedProductName = product.getName();

        productRepository.delete(product);

        //Activity log
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "DELETE",
                "PRODUCT",
                id.toString(),
                "Product permanently deleted from inventory. Code was: " + deletedProductCode + ", Name: " + deletedProductName,
                "{\"productCode\":\"" + deletedProductCode + "\", \"name\":\"" + deletedProductName + "\"}",
                null,
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );
    }


    private String uploadProductImage(MultipartFile file, String productName) {
        try {
            Path path = Paths.get(uploadDir, "product");

            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            //  (.png, .jpg etc) extract
            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = (productName != null ? productName : "product").trim().replaceAll("\\s+", "_");
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);

            return fileName;

        } catch (Exception e) {
            throw new RuntimeException("Product profile image upload failed: " + e.getMessage());
        }
    }
}