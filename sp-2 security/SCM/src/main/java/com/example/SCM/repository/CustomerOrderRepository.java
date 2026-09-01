package com.example.SCM.repository;

import com.example.SCM.entity.CustomerOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerOrderRepository extends JpaRepository<CustomerOrder, Long> {

    @Query("SELECT DISTINCT o FROM CustomerOrder o LEFT JOIN FETCH o.customer LEFT JOIN FETCH o.lineItems i LEFT JOIN FETCH i.product")
    List<CustomerOrder> findAllOrdersWithDetails();

    @Query("SELECT o FROM CustomerOrder o LEFT JOIN FETCH o.customer LEFT JOIN FETCH o.lineItems i LEFT JOIN FETCH i.product WHERE o.id = :id")
    Optional<CustomerOrder> findByIdWithDetails(@Param("id") Long id);

    @Query("SELECT o FROM CustomerOrder o LEFT JOIN FETCH o.customer LEFT JOIN FETCH o.lineItems i LEFT JOIN FETCH i.product WHERE o.orderNumber = :orderNumber")
    Optional<CustomerOrder> findByOrderNumberWithDetails(@Param("orderNumber") String orderNumber);
    List<CustomerOrder> findByCustomerEmail(String email);


}
