package com.example.SCM.repository;

import com.example.SCM.entity.POLineItem;
import com.example.SCM.enumClass.POLineItemStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface POLineItemRepository extends JpaRepository<POLineItem, Long> {



    // ৩. ইউনিক ট্র্যাকিং নাম্বার (trackingNumber) দিয়ে নির্দিষ্ট আইটেম খুঁজে বের করা (Optional টাইপ-সেফ সেটিং)
    Optional<POLineItem> findByTrackingNumber(String trackingNumber);


    @Query("SELECT COALESCE(SUM(p.lineTotal), 0.0) FROM POLineItem p WHERE p.purchaseOrder.id = :poId AND p.status <> com.example.SCM.enumClass.POLineItemStatus.CANCELLED")
    double getActiveTotalAmountByPoId(@Param("poId") Long poId);
}