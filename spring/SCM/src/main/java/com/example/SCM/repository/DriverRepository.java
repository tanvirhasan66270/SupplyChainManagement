package com.example.SCM.repository;

import com.example.SCM.entity.Driver;
import com.example.SCM.entity.Manager;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DriverRepository extends JpaRepository<Driver, Long> {

    @Query("""
        SELECT DISTINCT d FROM Driver d 
        LEFT JOIN FETCH d.user 
        LEFT JOIN FETCH d.policeStation 
        LEFT JOIN FETCH d.warehouses
    """)
    List<Driver> findAllWithDetails();

    @Query("""
        SELECT d FROM Driver d 
        LEFT JOIN FETCH d.user 
        LEFT JOIN FETCH d.policeStation 
        LEFT JOIN FETCH d.warehouses 
        WHERE d.id = :id
    """)
    Optional<Driver> findByIdWithDetails(@Param("id") Long id);

    Optional<Driver> findByUserId(Long userId);

}