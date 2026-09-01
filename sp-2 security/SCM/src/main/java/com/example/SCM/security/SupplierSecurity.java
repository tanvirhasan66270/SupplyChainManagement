package com.example.SCM.security;

import com.example.SCM.entity.Supplier;
import com.example.SCM.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

@Component("supplierSecurity")
@RequiredArgsConstructor
public class SupplierSecurity {

    private final SupplierRepository supplierRepository;

    public boolean isSelf(Long supplierId, Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()
                || supplierId == null) {
            return false;
        }

        String loginEmail = authentication.getName();

        return supplierRepository.findById(supplierId)
                .map(Supplier::getUser)
                .filter(user -> user != null)
                .map(user -> loginEmail.equalsIgnoreCase(user.getEmail()))
                .orElse(false);
    }

    public boolean isSelfUser(Long userId, Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()
                || userId == null) {
            return false;
        }

        String loginEmail = authentication.getName();

        return supplierRepository.findByUserId(userId)
                .map(Supplier::getUser)
                .filter(user -> user != null)
                .map(user -> loginEmail.equalsIgnoreCase(user.getEmail()))
                .orElse(false);
    }
}