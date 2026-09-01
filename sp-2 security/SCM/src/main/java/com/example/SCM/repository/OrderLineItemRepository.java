package com.example.SCM.repository;
import com.example.SCM.entity.OrderLineItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface OrderLineItemRepository extends JpaRepository<OrderLineItem, Long> {

    @Query("SELECT i FROM OrderLineItem i LEFT JOIN FETCH i.product WHERE i.customerOrder.id = :orderId")
    List<OrderLineItem> findByCustomerOrderIdWithProduct(@Param("orderId") Long orderId);


}