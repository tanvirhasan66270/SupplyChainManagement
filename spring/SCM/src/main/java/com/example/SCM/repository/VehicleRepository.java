package com.example.SCM.repository;

import com.example.SCM.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {


    @Query("""
        SELECT DISTINCT v FROM Vehicle v
        LEFT JOIN FETCH v.driver d
    """)
    List<Vehicle> findAllWithDriverDetails();


    @Query("""
        SELECT v FROM Vehicle v
        LEFT JOIN FETCH v.driver d
        WHERE v.id = :id
    """)
    Optional<Vehicle> findByIdWithDriverDetails(@Param("id") Long id);


    Optional<Vehicle> findByPlateNumber(String plateNumber);


    boolean existsByPlateNumberAndIdNot(String plateNumber, Long id);
}