package com.example.SCM.repository;

import com.example.SCM.entity.Procurement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProcurementRepository extends JpaRepository<Procurement, Long> {
    Optional<Procurement> findByUserId(Long userId);

    @Query("SELECT DISTINCT p FROM Procurement p LEFT JOIN FETCH p.user LEFT JOIN FETCH p.policeStation")
    List<Procurement> findAllWithDetails();

    boolean existsByPassportNumber(String passportNumber);
    boolean existsByNidNumber(String nidNumber);
}