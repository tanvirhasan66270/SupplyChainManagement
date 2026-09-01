package com.example.SCM.repository;

import com.example.SCM.entity.GoodsReceivedNote;
import com.example.SCM.enumClass.GRNStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GoodsReceivedNoteRepository extends JpaRepository<GoodsReceivedNote, Long> {

    @Query("""
        SELECT DISTINCT g FROM GoodsReceivedNote g
        LEFT JOIN FETCH g.purchaseOrder po
        LEFT JOIN FETCH g.product p
        LEFT JOIN FETCH g.warehouse w
        LEFT JOIN FETCH g.receivedBy rb
        LEFT JOIN FETCH g.inspectedBy ib
    """)
    List<GoodsReceivedNote> findAllGRNs();


    @Query("""
        SELECT g FROM GoodsReceivedNote g
        LEFT JOIN FETCH g.purchaseOrder po
        LEFT JOIN FETCH g.product p
        LEFT JOIN FETCH g.warehouse w
        LEFT JOIN FETCH g.receivedBy rb
        LEFT JOIN FETCH g.inspectedBy ib
        WHERE g.id = :id
    """)
    Optional<GoodsReceivedNote> findByIdWithDetails(@Param("id") Long id);


}