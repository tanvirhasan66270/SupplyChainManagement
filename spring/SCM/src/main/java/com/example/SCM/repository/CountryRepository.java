package com.example.SCM.repository;

import com.example.SCM.entity.Country;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CountryRepository extends JpaRepository<Country, Long> {


    @Query("SELECT DISTINCT c FROM Country c LEFT JOIN FETCH c.divisions")
    List<Country> findAllCountriesWithDivisions();


    @Query("SELECT c FROM Country c LEFT JOIN FETCH c.divisions WHERE c.id = :id")
    Optional<Country> findByIdWithDivisions(@Param("id") Long id);


    @Query("SELECT DISTINCT c FROM Country c LEFT JOIN FETCH c.divisions WHERE c.active = true")
    List<Country> findAllActiveCountriesWithDivisions();
}