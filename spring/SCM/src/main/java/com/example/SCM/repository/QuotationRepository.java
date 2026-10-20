package com.example.SCM.repository;

import com.example.SCM.entity.Quotation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface QuotationRepository extends JpaRepository<Quotation, Long> {
    @Query("SELECT q FROM Quotation q JOIN q.supplier s WHERE s.id = :supplierId")
    List<Quotation> findBySupplierId(@Param("supplierId") Long supplierId);

    @Query("SELECT q FROM Quotation q " +
            "LEFT JOIN FETCH q.supplier " +
            "LEFT JOIN FETCH q.purchaseRequisition " +
            "WHERE q.id = :id")
    Optional<Quotation> findByIdWithDetails(@Param("id") Long id);

    @Query("SELECT q FROM Quotation q " +
            "LEFT JOIN FETCH q.supplier " +
            "LEFT JOIN FETCH q.purchaseRequisition " +
            "ORDER BY q.createdAt DESC")
    List<Quotation> findAllWithDetails();

    Optional<Quotation> findByQuotationNumber(String quotationNumber);

    List<Quotation> findByValidUntilLessThanEqual(LocalDate validUntilIsLessThan);
}