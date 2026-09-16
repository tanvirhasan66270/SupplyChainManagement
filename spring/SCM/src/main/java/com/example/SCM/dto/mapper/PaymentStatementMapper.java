package com.example.SCM.dto.mapper;

import com.example.SCM.dto.response.PaymentStatementResponseDTO;
import com.example.SCM.entity.CustomerOrder;
import com.example.SCM.entity.PaymentStatement;
import com.example.SCM.enumClass.PaymentIssueStatus;
import org.springframework.stereotype.Component;

@Component
public class PaymentStatementMapper {

    public PaymentStatementResponseDTO toResponseDTO(PaymentStatement paymentStatement) {
        if (paymentStatement == null) {
            return null;
        }

        PaymentStatementResponseDTO dto = new PaymentStatementResponseDTO();
        dto.setId(paymentStatement.getId());
        dto.setPaidAmount(paymentStatement.getPaidAmount());
        dto.setPaymentMethod(paymentStatement.getPaymentMethod());
        dto.setIssueStatus(paymentStatement.getIssueStatus());
        dto.setTransactionId(paymentStatement.getTransactionId());
        dto.setCustomerAccountNumber(paymentStatement.getCustomerAccountNumber());
        dto.setPaymentCheckImage(paymentStatement.getPaymentCheckImage());
        dto.setCreatedAt(paymentStatement.getCreatedAt());
        dto.setUpdatedAt(paymentStatement.getUpdatedAt());

        if (paymentStatement.getCustomerOrder() != null) {
            CustomerOrder order = paymentStatement.getCustomerOrder();
            dto.setCustomerOrderId(order.getId());
            dto.setOrderNumber(order.getOrderNumber());

            double totalConfirmedPaid = order.getPaymentStatements().stream()
                    .filter(ps -> ps.getIssueStatus() == PaymentIssueStatus.CONFIRMED_BY_OFFICER)
                    .mapToDouble(PaymentStatement::getPaidAmount)
                    .sum();

            double oldPaid = 0.0;
            if (paymentStatement.getIssueStatus() == PaymentIssueStatus.CONFIRMED_BY_OFFICER) {
                oldPaid = totalConfirmedPaid - paymentStatement.getPaidAmount();
            } else {
                oldPaid = totalConfirmedPaid;
            }

            dto.setOldPaidAmount(Math.max(oldPaid, 0.0));
        }

        return dto;
    }
}