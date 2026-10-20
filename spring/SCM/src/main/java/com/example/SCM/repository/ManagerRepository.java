package com.example.SCM.repository;

import com.example.SCM.entity.Manager;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ManagerRepository extends JpaRepository<Manager, Long> {
    Optional<Manager> findByUserId(Long userId);

    @Query("SELECT DISTINCT m FROM Manager m LEFT JOIN FETCH m.user LEFT JOIN FETCH m.policeStation")
    List<Manager> findAllWithDetails();


}