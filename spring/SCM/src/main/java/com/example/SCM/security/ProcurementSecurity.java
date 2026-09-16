package com.example.SCM.security;

import com.example.SCM.entity.Procurement;
import com.example.SCM.entity.User;
import com.example.SCM.repository.ProcurementRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;

@Component("procurementSecurity")
@RequiredArgsConstructor
public class ProcurementSecurity {

    private final ProcurementRepository procurementRepository;

    public boolean isSelf(Long requestedId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || requestedId == null) {
            return false;
        }
        if (!(authentication.getPrincipal() instanceof User user)) {
            return false;
        }

        return procurementRepository.findById(requestedId)
                .map(procurement -> matches(procurement, user))
                .orElse(false);
    }

    private boolean matches(Procurement procurement, User user) {
        // TODO: wire once entity relation is confirmed, e.g.:
        // return procurement.getUser() != null && user.getId().equals(procurement.getUser().getId());
        return false; // safe default until wired up
    }
}