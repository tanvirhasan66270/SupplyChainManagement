package com.example.SCM.security;

import com.example.SCM.repository.PaymentStatementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

@Component("paymentStatementSecurity")
@RequiredArgsConstructor
public class PaymentStatementSecurity {

    private final PaymentStatementRepository paymentStatementRepository;
    private final CustomerOrderSecurity customerOrderSecurity;

    public boolean isOwner(Long paymentId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || paymentId == null) {
            return false;
        }

        return paymentStatementRepository.findById(paymentId)
                .map(payment -> customerOrderSecurity.isOwner(payment.getCustomerOrder().getId(), authentication))
                .orElse(false);
    }
}
