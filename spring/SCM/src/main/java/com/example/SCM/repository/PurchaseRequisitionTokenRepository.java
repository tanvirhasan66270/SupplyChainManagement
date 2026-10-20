package com.example.SCM.repository;

import com.example.SCM.entity.PurchaseRequisitionToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface PurchaseRequisitionTokenRepository extends JpaRepository<PurchaseRequisitionToken, Long> {

    Optional<PurchaseRequisitionToken> findByToken(String token);

    Optional<PurchaseRequisitionToken> findByPurchaseRequisitionId(Long purchaseRequisitionId);

    List<PurchaseRequisitionToken> findByRequiredByDateLessThanEqual(LocalDate date);

    List<PurchaseRequisitionToken> findByActiveTrueAndRequiredByDateLessThanEqual(LocalDate date);
}