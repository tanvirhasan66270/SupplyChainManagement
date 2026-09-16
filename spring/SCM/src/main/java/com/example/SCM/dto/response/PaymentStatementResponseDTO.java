package com.example.SCM.dto.response;

import com.example.SCM.enumClass.PaymentMethod;
import com.example.SCM.enumClass.PaymentIssueStatus;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class PaymentStatementResponseDTO {

    private Long id;
    private double paidAmount;
    private double oldPaidAmount;
    private PaymentMethod paymentMethod;
    private String customerAccountNumber;
    private PaymentIssueStatus issueStatus;
    private String transactionId;
    private String paymentCheckImage;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long customerOrderId;
    private String orderNumber;
}