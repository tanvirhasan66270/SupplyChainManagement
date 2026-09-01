package com.example.SCM.repository;

import com.example.SCM.entity.CommercialOfficer;
import com.example.SCM.entity.Manager;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CommercialOfficerRepository extends JpaRepository<CommercialOfficer, Long> {

    @Query("SELECT DISTINCT c FROM CommercialOfficer c LEFT JOIN FETCH c.user LEFT JOIN FETCH c.policeStation")
    List<CommercialOfficer> findAllWithDetails();

    boolean existsByPassportNumber(String passportNumber);

    boolean existsByNidNumber(String nidNumber);
    Optional<CommercialOfficer> findByUserId(Long userId);


}