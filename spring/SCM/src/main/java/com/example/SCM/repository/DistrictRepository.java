package com.example.SCM.repository;

import com.example.SCM.entity.District;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DistrictRepository extends JpaRepository<District, Long> {

    @Query("""
        SELECT DISTINCT d FROM District d 
        LEFT JOIN FETCH d.division div 
        LEFT JOIN FETCH div.country 
        LEFT JOIN FETCH d.policeStations
    """)
    List<District> findAllDistrictsWithDetails();

    @Query("""
        SELECT d FROM District d 
        LEFT JOIN FETCH d.division div 
        LEFT JOIN FETCH div.country 
        LEFT JOIN FETCH d.policeStations 
        WHERE d.id = :id
    """)
    Optional<District> findByIdWithDetails(@Param("id") Long id);

    @Query("SELECT DISTINCT d FROM District d LEFT JOIN FETCH d.division WHERE d.division.id = :divisionId")
    List<District> findByDivisionId(@Param("divisionId") Long divisionId);

    @Query("SELECT DISTINCT d FROM District d LEFT JOIN FETCH d.division div LEFT JOIN FETCH div.country WHERE d.active = true")
    List<District> findAllActiveDistricts();
}