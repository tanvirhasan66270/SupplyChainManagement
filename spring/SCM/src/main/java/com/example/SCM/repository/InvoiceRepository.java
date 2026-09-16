package com.example.SCM.repository;

import com.example.SCM.entity.Invoice;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {


    List<Invoice> findByCustomerEmail(String customerEmail);

    // 5. Custom JPQL Query: Fetch pending due invoices
    @Query("SELECT i FROM Invoice i WHERE i.dueAmount > 0 AND i.invoiceStatus = com.example.SCM.enumClass.InvoiceStatus.ISSUED")
    List<Invoice> findPendingDueInvoices();

    @Query(value = "SELECT SUM(i.due_amount) FROM invoices i WHERE i.invoice_status = 'ISSUED'", nativeQuery = true)
    Double calculateTotalOutstandingRevenue();
}