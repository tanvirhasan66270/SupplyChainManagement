package com.example.SCM.repository;

import com.example.SCM.entity.Warehouse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WarehouseRepository extends JpaRepository<Warehouse, Long> {

    @Query("SELECT w.name FROM Warehouse w WHERE w.id = :id")
    Optional<String> findNameById(@Param("id") Long id);

    Optional<Warehouse> findByName(String name);

    Optional<Warehouse> findByEmail(String email);

    // Performance Optimization: Fetch location graphs eagerly to solve N+1 query problem
    @Query("SELECT DISTINCT w FROM Warehouse w " +
            "LEFT JOIN FETCH w.policeStation ps " +
            "LEFT JOIN FETCH ps.district d " +
            "LEFT JOIN FETCH d.division")
    List<Warehouse> findAllWithLocationDetails();

    @Query("SELECT w FROM Warehouse w " +
            "LEFT JOIN FETCH w.policeStation ps " +
            "LEFT JOIN FETCH ps.district d " +
            "LEFT JOIN FETCH d.division " +
            "WHERE w.id = :id")
    Optional<Warehouse> findByIdWithLocationDetails(@Param("id") Long id);
}