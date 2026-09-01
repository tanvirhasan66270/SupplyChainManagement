package com.example.SCM.repository;

import com.example.SCM.entity.Division;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DivisionRepository extends JpaRepository<Division, Long> {


    @Query("SELECT DISTINCT d FROM Division d LEFT JOIN FETCH d.country LEFT JOIN FETCH d.districts")
    List<Division> findAllDivisionsWithDetails();


    @Query("SELECT DISTINCT d FROM Division d LEFT JOIN FETCH d.country LEFT JOIN FETCH d.districts WHERE d.active = true")
    List<Division> findAllActiveDivisions();


    @Query("SELECT d FROM Division d LEFT JOIN FETCH d.country LEFT JOIN FETCH d.districts WHERE d.id = :id")
    Optional<Division> findByIdWithDetails(@Param("id") Long id);


    @Query("SELECT DISTINCT d FROM Division d LEFT JOIN FETCH d.country LEFT JOIN FETCH d.districts WHERE d.country.id = :countryId")
    List<Division> findByCountryId(@Param("countryId") Long countryId);


}