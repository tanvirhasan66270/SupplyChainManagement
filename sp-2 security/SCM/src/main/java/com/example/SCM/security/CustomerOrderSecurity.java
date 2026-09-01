package com.example.SCM.security;

import com.example.SCM.entity.CustomerOrder;
import com.example.SCM.repository.CustomerOrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

@Component("customerOrderSecurity")
@RequiredArgsConstructor
public class CustomerOrderSecurity {

    private final CustomerOrderRepository orderRepository;

    @org.springframework.transaction.annotation.Transactional(readOnly = true)
    public boolean isOwner(Long orderId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || orderId == null) {
            return false;
        }

        String loginIdentifier = authentication.getName();

        return orderRepository.findById(orderId)
                .map(order -> {
                    if (order.getCustomer() != null) {
                        return loginIdentifier.equalsIgnoreCase(order.getCustomer().getUsername()) ||
                                loginIdentifier.equalsIgnoreCase(order.getCustomer().getEmail());
                    }
                    return false;
                })
                .orElse(false);
    }
}