package com.example.SCM.repository;

import com.example.SCM.entity.GRNLineItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GRNLineItemRepository extends JpaRepository<GRNLineItem, Long> {


    @Query("""
        SELECT DISTINCT i FROM GRNLineItem i
        LEFT JOIN FETCH i.goodsReceivedNote g
        LEFT JOIN FETCH i.product p
    """)
    List<GRNLineItem> findAllItemsWithDetails();


    @Query("""
        SELECT i FROM GRNLineItem i
        LEFT JOIN FETCH i.goodsReceivedNote g
        LEFT JOIN FETCH i.product p
        WHERE i.id = :id
    """)
    Optional<GRNLineItem> findByIdWithDetails(@Param("id") Long id);


    @Query("""
        SELECT i FROM GRNLineItem i
        LEFT JOIN FETCH i.product p
        WHERE i.goodsReceivedNote.id = :grnId
    """)
    List<GRNLineItem> findByGoodsReceivedNoteId(@Param("grnId") Long grnId);


}