package com.example.SCM.dto.response;

import com.example.SCM.enumClass.POLineItemStatus;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class POLineItemResponseDTO {
    private Long id;
    private Long poId;
    private Long productId;
    private String productName;
    private String productCode;
    private Long supplierId;
    private String supplierName;
    private int quantity;
    private double unitPrice;
    private double lineTotal;      // quantity * unitPrice
    private double totalAmount;    //  oldTotal lineTotal + newUpdateTotal lineTotal
    private String quotationRef;
    private String poNumber;
    private LocalDate deliveryDate;
    private String shipmentMethod;
    private String trackingNumber; // PENDING -> SHIPPED হলে জেনারেট হওয়া কোড
    private String notes;
    private POLineItemStatus status;
    private LocalDateTime createdAt;
}