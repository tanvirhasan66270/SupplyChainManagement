package com.example.SCM.security;

import com.example.SCM.entity.Logistics_Officer;
import com.example.SCM.repository.LogisticsOfficerRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;

@Component("logisticsOfficerSecurity")
@RequiredArgsConstructor
public class LogisticsOfficerSecurity {

    private final LogisticsOfficerRepository logisticsOfficerRepository;

    public boolean isSelf(Long requestedId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || requestedId == null) {
            return false;
        }

        String loginIdentifier = authentication.getName();

        return logisticsOfficerRepository.findById(requestedId)
                .map(officer -> matches(officer, loginIdentifier))
                .orElse(false);
    }

    private boolean matches(Logistics_Officer officer, String loginIdentifier) {
        // TODO: same unresolved question as Driver/Customer — wire to the real
        // login-credential field once confirmed:
        // return loginIdentifier.equalsIgnoreCase(officer.getEmail());
        // return officer.getUser() != null
        //         && loginIdentifier.equalsIgnoreCase(officer.getUser().getUsername());

        return false; // safe default until wired up
    }
}