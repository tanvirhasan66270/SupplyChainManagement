package com.example.SCM.repository;

import com.example.SCM.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query("SELECT p.name FROM Product p WHERE p.id = :id")
    Optional<String> findNameById(@Param("id") Long id);

    Optional<Product> findByProductCode(String productCode);

    List<Product> findByCategoryId(Long categoryId);



    @Query("SELECT p FROM Product p WHERE p.quantity <= p.reorderPoint AND p.isActive = true")
    List<Product> findLowStockProducts();

    @Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.productCode) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Product> searchProducts(@Param("keyword") String keyword);

    @Query(value = "SELECT SUM(p.unit_cost * p.quantity) FROM products p WHERE p.is_active = true", nativeQuery = true)
    Double calculateTotalInventoryValue();
}