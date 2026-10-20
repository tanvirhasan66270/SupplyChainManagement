package com.example.SCM.repository;

import com.example.SCM.entity.LetterOfCredit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface LetterOfCreditRepository extends JpaRepository<LetterOfCredit, Long> {

    @Query("SELECT l FROM LetterOfCredit l LEFT JOIN FETCH l.purchaseOrder LEFT JOIN FETCH l.supplier LEFT JOIN FETCH l.issuingBank WHERE l.id = :id")
    Optional<LetterOfCredit> findByIdWithDetails(@Param("id") Long id);

    @Query("SELECT l FROM LetterOfCredit l LEFT JOIN FETCH l.purchaseOrder LEFT JOIN FETCH l.supplier LEFT JOIN FETCH l.issuingBank")
    List<LetterOfCredit> findAllWithDetails();

    Optional<LetterOfCredit> findByLcNumber(String lcNumber);
}