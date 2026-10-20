package com.example.SCM.repository;

import com.example.SCM.entity.PurchaseOrderToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOrderTokenRepository extends JpaRepository<PurchaseOrderToken, Long> {

    Optional<PurchaseOrderToken> findByPurchaseOrderId(Long purchaseOrderId);

    Optional<PurchaseOrderToken> findByTokenAndActiveTrue(String token);

    List<PurchaseOrderToken> findByActiveTrueAndExpiryDateLessThanEqual(LocalDate expiryDate);

    Optional<PurchaseOrderToken> findByToken(String token);

    boolean existsByToken(String token);

    List<PurchaseOrderToken> findByActiveTrue();

}