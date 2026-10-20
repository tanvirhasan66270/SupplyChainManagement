package com.example.SCM.repository;

import com.example.SCM.entity.QCInspection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QCInspectionRepository extends JpaRepository<QCInspection, Long> {

    @Query("""
        SELECT DISTINCT q FROM QCInspection q
        LEFT JOIN FETCH q.goodsReceivedNote g
        LEFT JOIN FETCH q.product p
        LEFT JOIN FETCH q.inspectedBy u
        LEFT JOIN FETCH q.checklists c
    """)
    List<QCInspection> findAllInspectionsWithDetails();

    @Query("""
        SELECT q FROM QCInspection q
        LEFT JOIN FETCH q.goodsReceivedNote g
        LEFT JOIN FETCH q.product p
        LEFT JOIN FETCH q.inspectedBy u
        LEFT JOIN FETCH q.checklists c
        WHERE q.id = :id
    """)
    Optional<QCInspection> findByIdWithDetails(@Param("id") Long id);
}