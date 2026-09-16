package com.example.SCM.security;

import com.example.SCM.entity.Customer;
import com.example.SCM.repository.CustomerRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;

@Component("customerSecurity")
@RequiredArgsConstructor
public class CustomerSecurity {

    private final CustomerRepository customerRepository;

    public boolean isSelf(Long requestedId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || requestedId == null) {
            return false;
        }

        String loginIdentifier = authentication.getName();

        return customerRepository.findById(requestedId)
                .map(customer -> matches(customer, loginIdentifier))
                .orElse(false);
    }

    private boolean matches(Customer customer, String loginIdentifier) {
        // কাস্টমার টেবিলের ইমেইল অথবা এর সাথে যুক্ত User একাউন্টের ইউজারনেম/ইমেইলের সাথে মিলিয়ে দেখা
        boolean emailMatch = customer.getEmail() != null && loginIdentifier.equalsIgnoreCase(customer.getEmail());

        boolean userMatch = customer.getUser() != null &&
                (loginIdentifier.equalsIgnoreCase(customer.getUser().getUsername()) ||
                        loginIdentifier.equalsIgnoreCase(customer.getUser().getEmail()));

        return emailMatch || userMatch;
    }
}