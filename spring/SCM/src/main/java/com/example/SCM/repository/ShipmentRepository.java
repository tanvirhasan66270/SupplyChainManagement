package com.example.SCM.repository;

import com.example.SCM.entity.Shipment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ShipmentRepository extends JpaRepository<Shipment, Long> {

    @Query("""
        SELECT DISTINCT s FROM Shipment s 
        LEFT JOIN FETCH s.purchaseOrder 
        LEFT JOIN FETCH s.supplier
    """)
    List<Shipment> findAllShipmentsWithDetails();

    @Query("""
        SELECT s FROM Shipment s 
        LEFT JOIN FETCH s.purchaseOrder 
        LEFT JOIN FETCH s.supplier 
        WHERE s.id = :id
    """)
    Optional<Shipment> findByIdWithDetails(@Param("id") Long id);


}