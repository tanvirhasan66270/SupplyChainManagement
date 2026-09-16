package com.example.SCM.repository;

import com.example.SCM.entity.PurchaseOrderToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOrderTokenRepository extends JpaRepository<PurchaseOrderToken, Long> {

    // Find token by Purchase Order ID
    Optional<PurchaseOrderToken> findByPurchaseOrderId(Long purchaseOrderId);

    // Find active token by token string
    Optional<PurchaseOrderToken> findByTokenAndActiveTrue(String token);

    // Find all active tokens that have expired
    List<PurchaseOrderToken> findByActiveTrueAndExpiryDateLessThanEqual(LocalDate expiryDate);

    // Optional: Find token only by token
    Optional<PurchaseOrderToken> findByToken(String token);

    // Optional: Check token exists
    boolean existsByToken(String token);

    // Optional: Find all active tokens
    List<PurchaseOrderToken> findByActiveTrue();

}