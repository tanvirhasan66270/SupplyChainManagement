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
        ///jdasdhjfh
        return loginIdentifier != null && loginIdentifier.equals(driver.getDriverName());
    }
}