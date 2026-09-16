package com.example.SCM.repository;

import com.example.SCM.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SupplierRepository extends JpaRepository<Supplier, Long> {
    Optional<Supplier> findByUserId(Long userId);

    Optional<Supplier> findByEmail(String email);

    List<Supplier> findByIsActiveTrue();

    @Query("SELECT s FROM Supplier s WHERE s.rating >= :minRating AND s.isActive = true ORDER BY s.rating DESC")
    List<Supplier> findTopRatedSuppliers(@Param("minRating") double minRating);

    @Query("SELECT s FROM Supplier s WHERE s.isActive = true ORDER BY s.averageLeadTimeDays Asc")
    List<Supplier> findFastestSuppliers();

    @Query("SELECT s FROM Supplier s WHERE s.policeStation.id = :psId")
    List<Supplier> findSuppliersByPoliceStation(@Param("psId") Long policeStationId);

    @Query(value = "SELECT COUNT(*) FROM suppliers WHERE is_active = true", nativeQuery = true)
    long countAllActiveSuppliers();
}