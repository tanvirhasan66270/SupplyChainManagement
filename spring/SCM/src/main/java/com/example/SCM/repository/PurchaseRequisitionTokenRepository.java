package com.example.SCM.repository;

import com.example.SCM.entity.PurchaseRequisitionToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface PurchaseRequisitionTokenRepository extends JpaRepository<PurchaseRequisitionToken, Long> {

    // Token
    Optional<PurchaseRequisitionToken> findByToken(String token);

    // Purchase Requisition ID
    Optional<PurchaseRequisitionToken> findByPurchaseRequisitionId(Long purchaseRequisitionId);

    // Required token
    List<PurchaseRequisitionToken> findByRequiredByDateLessThanEqual(LocalDate date);

    // Active এবং Required token
    List<PurchaseRequisitionToken> findByActiveTrueAndRequiredByDateLessThanEqual(LocalDate date);
}