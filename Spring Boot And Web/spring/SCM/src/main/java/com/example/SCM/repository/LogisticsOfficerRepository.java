package com.example.SCM.repository;

import com.example.SCM.entity.Logistics_Officer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface LogisticsOfficerRepository extends JpaRepository<Logistics_Officer, Long> {
    Optional<Logistics_Officer> findByUserId(Long userId);

    @Query("SELECT DISTINCT l FROM Logistics_Officer l LEFT JOIN FETCH l.user LEFT JOIN FETCH l.policeStation")
    List<Logistics_Officer> findAllWithDetails();
}