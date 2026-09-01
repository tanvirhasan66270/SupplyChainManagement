package com.example.SCM.repository;

import com.example.SCM.dto.response.PurchaseOrderResponseDTO;
import com.example.SCM.entity.PurchaseOrder;
import com.example.SCM.enumClass.PurchaseOrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {


    @Query("""
        SELECT DISTINCT p FROM PurchaseOrder p
        LEFT JOIN FETCH p.supplier s
        LEFT JOIN FETCH p.purchaseRequisition pr
        LEFT JOIN FETCH p.quotation q
    """)
    List<PurchaseOrder> findAllPurchaseOrders();


    @Query("""
        SELECT p FROM PurchaseOrder p
        LEFT JOIN FETCH p.supplier s
        LEFT JOIN FETCH p.purchaseRequisition pr
        LEFT JOIN FETCH p.quotation q
        WHERE p.id = :id
    """)
    Optional<PurchaseOrder> findByIdWithDetails(@Param("id") Long id);




}