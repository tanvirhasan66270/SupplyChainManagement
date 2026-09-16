package com.example.SCM.repository;

import com.example.SCM.entity.Manager;
import com.example.SCM.entity.QCInspector;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QCInspectorRepository extends JpaRepository<QCInspector, Long> {


    Optional<QCInspector> findByUserId(Long userId);


    @Query("""
        SELECT DISTINCT q FROM QCInspector q
        LEFT JOIN FETCH q.user
        LEFT JOIN FETCH q.policeStation ps
        LEFT JOIN FETCH ps.district d
        LEFT JOIN FETCH d.division
    """)
    List<QCInspector> findAllInspectors();

    @Query("""
        SELECT q FROM QCInspector q
        LEFT JOIN FETCH q.user
        LEFT JOIN FETCH q.policeStation ps
        LEFT JOIN FETCH ps.district d
        LEFT JOIN FETCH d.division
        WHERE q.id = :id
    """)
    Optional<QCInspector> findByIdWithDetails(@Param("id") Long id);


}