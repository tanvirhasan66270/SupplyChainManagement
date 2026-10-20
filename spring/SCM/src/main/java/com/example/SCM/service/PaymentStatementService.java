package com.example.SCM.service;


import com.example.SCM.dto.request.PaymentStatementRequestDTO;
import com.example.SCM.dto.response.PaymentStatementResponseDTO;
import com.example.SCM.enumClass.PaymentIssueStatus;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface PaymentStatementService {
    PaymentStatementResponseDTO addPayment(PaymentStatementRequestDTO requestDTO, MultipartFile image);
    PaymentStatementResponseDTO updatePayment(Long id, PaymentStatementRequestDTO requestDTO, MultipartFile image);
    PaymentStatementResponseDTO updatePaymentStatus(Long paymentId, PaymentIssueStatus newStatus);
    List<PaymentStatementResponseDTO> getPaymentsByOrderId(Long orderId);
    List<PaymentStatementResponseDTO> getPaymentsByOrderNumber(String orderNumber);
    List<PaymentStatementResponseDTO> getPaymentsByStatus(PaymentIssueStatus status);
    PaymentStatementResponseDTO getPaymentById(Long id);
    void deletePayment(Long id);
}