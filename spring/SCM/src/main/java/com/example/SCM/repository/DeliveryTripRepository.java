package com.example.SCM.repository;

import com.example.SCM.entity.DeliveryTrip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryTripRepository extends JpaRepository<DeliveryTrip, Long> {

    @Query("""
        SELECT DISTINCT t FROM DeliveryTrip t 
        LEFT JOIN FETCH t.customer 
        LEFT JOIN FETCH t.driver 
        LEFT JOIN FETCH t.vehicle
    """)
    List<DeliveryTrip> findAllTripsWithDetails();

    @Query("""
        SELECT t FROM DeliveryTrip t 
        LEFT JOIN FETCH t.customer 
        LEFT JOIN FETCH t.driver 
        LEFT JOIN FETCH t.vehicle 
        WHERE t.id = :id
    """)
    Optional<DeliveryTrip> findByIdWithDetails(@Param("id") Long id);

}