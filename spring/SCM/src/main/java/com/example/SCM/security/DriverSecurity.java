package com.example.SCM.security;

import com.example.SCM.entity.Driver;
import com.example.SCM.repository.DriverRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component("driverSecurity")
@RequiredArgsConstructor
@Slf4j
public class DriverSecurity {

    private final DriverRepository driverRepository;

    /**
     * Returns true only if the currently authenticated user IS the driver
     * identified by requestedId. Used to let a driver view/edit their own
     * profile without granting access to other drivers' records.
     */
    public boolean isSelf(Long requestedId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || requestedId == null) {
            return false;
        }

        String loginIdentifier = authentication.getName(); // username/email used at login

        return driverRepository.findById(requestedId)
                .map(driver -> matches(driver, loginIdentifier))
                .orElse(false);
    }

    private boolean matches(Driver driver, String loginIdentifier) {
        // TODO: replace this with whatever field actually links Driver -> login identity.
        // Pick ONE of the following depending on your entity design:

        // Option A — Driver has its own email field used for login:
        // return loginIdentifier.equalsIgnoreCase(driver.getEmail());

        // Option B — Driver has its own phone field used for login:
        // return loginIdentifier.equals(driver.getPhone());

        // Option C — Driver has a @ManyToOne/@OneToOne link to a User entity:
        // return driver.getUser() != null
        //         && loginIdentifier.equalsIgnoreCase(driver.getUser().getUsername());

        // Placeholder (INCORRECT for most schemas — driverName is a display name, not credential):
        return loginIdentifier != null && loginIdentifier.equals(driver.getDriverName());
    }
}