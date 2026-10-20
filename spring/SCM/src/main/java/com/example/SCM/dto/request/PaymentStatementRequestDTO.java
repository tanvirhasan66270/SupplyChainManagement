package com.example.SCM.dto.request;



import com.example.SCM.enumClass.PaymentMethod;
import com.example.SCM.enumClass.PaymentIssueStatus;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PaymentStatementRequestDTO {

    private Long customerOrderId;
    private double paidAmount;
    private PaymentMethod paymentMethod;
    private String customerAccountNumber;
    private PaymentIssueStatus issueStatus;
    private String transactionId;
    private String paymentCheckImage;
}