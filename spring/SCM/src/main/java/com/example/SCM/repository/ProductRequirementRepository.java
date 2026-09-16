package com.example.SCM.repository;

import com.example.SCM.entity.ProductRequirement;
import com.example.SCM.enumClass.ProductRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRequirementRepository extends JpaRepository<ProductRequirement, Long> {

    List<ProductRequirement> findAllByOrderByCreatedAtDesc();

    List<ProductRequirement> findByStatus(ProductRequestStatus status);

    List<ProductRequirement> findByRequestedByOfficerId(Long officerId);

    List<ProductRequirement> findByUrgencyLevelIgnoreCase(String urgencyLevel);
}
