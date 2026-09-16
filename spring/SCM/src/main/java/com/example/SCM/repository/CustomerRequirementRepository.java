package com.example.SCM.repository;

import com.example.SCM.entity.CustomerRequirement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CustomerRequirementRepository extends JpaRepository<CustomerRequirement, Long> {


}
