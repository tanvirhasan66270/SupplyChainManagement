package com.example.SCM.repository;

import com.example.SCM.entity.PaymentStatement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentStatementRepository extends JpaRepository<PaymentStatement, Long> {
    List<PaymentStatement> findByCustomerOrderId(Long customerOrderId);
    List<PaymentStatement> findByCustomerOrderOrderNumber(String orderNumber);
    List<PaymentStatement> findByIssueStatus(com.example.SCM.enumClass.PaymentIssueStatus status);
}