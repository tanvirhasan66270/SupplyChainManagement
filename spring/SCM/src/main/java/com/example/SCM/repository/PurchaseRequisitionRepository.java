package com.example.SCM.repository;

import com.example.SCM.entity.PurchaseRequisition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseRequisitionRepository extends JpaRepository<PurchaseRequisition, Long> {

    @Query("SELECT DISTINCT pr FROM PurchaseRequisition pr " +
            "LEFT JOIN FETCH pr.products " +
            "LEFT JOIN FETCH pr.suppliers " +
            "ORDER BY pr.createdAt DESC")
    List<PurchaseRequisition> findAllWithDetails();

    @Query("SELECT pr FROM PurchaseRequisition pr " +
            "LEFT JOIN FETCH pr.products " +
            "LEFT JOIN FETCH pr.suppliers " +
            "WHERE pr.id = :id")
    Optional<PurchaseRequisition> findByIdWithDetails(@Param("id") Long id);

    @Query("SELECT DISTINCT pr FROM PurchaseRequisition pr " +
            "LEFT JOIN FETCH pr.products " +
            "JOIN FETCH pr.suppliers s " +
            "WHERE s.user.id = :userId AND pr.approvalStatus = com.example.SCM.enumClass.PurchaseRequisitionStatus.APPROVED")
    List<PurchaseRequisition> findAllApprovedBySupplierUserId(@Param("userId") Long userId);
}