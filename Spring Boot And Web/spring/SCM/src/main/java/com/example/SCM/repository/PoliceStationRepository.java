package com.example.SCM.repository;

import com.example.SCM.entity.PoliceStation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PoliceStationRepository extends JpaRepository<PoliceStation, Long> {

    @Query("""
        SELECT DISTINCT p FROM PoliceStation p 
        LEFT JOIN FETCH p.district d 
        LEFT JOIN FETCH d.division div 
        LEFT JOIN FETCH div.country
    """)
    List<PoliceStation> findAllStationsWithDetails();

    @Query("""
        SELECT p FROM PoliceStation p 
        LEFT JOIN FETCH p.district d 
        LEFT JOIN FETCH d.division div 
        LEFT JOIN FETCH div.country 
        WHERE p.id = :id
    """)
        Optional<PoliceStation> findByIdWithDetails(@Param("id") Long id);
    @Query("SELECT p FROM PoliceStation p WHERE " +
            "LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "p.nameBn LIKE CONCAT('%', :keyword, '%') OR " +
            "p.postalCode LIKE CONCAT('%', :keyword, '%')")
    List<PoliceStation> searchStations(@Param("keyword") String keyword);

    @Query("SELECT DISTINCT p FROM PoliceStation p LEFT JOIN FETCH p.district WHERE p.district.id = :districtId")
    List<PoliceStation> findByDistrictId(@Param("districtId") Long districtId);

    @Query("SELECT DISTINCT p FROM PoliceStation p LEFT JOIN FETCH p.district d WHERE p.active = true")
    List<PoliceStation> findAllActiveStations();
}