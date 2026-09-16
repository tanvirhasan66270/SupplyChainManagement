package com.example.SCM.repository;

import com.example.SCM.entity.LCBank;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface LCBankRepository extends JpaRepository<LCBank, Long> {
    Optional<LCBank> findBySwiftCode(String swiftCode);
}