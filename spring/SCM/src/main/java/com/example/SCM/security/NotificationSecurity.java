package com.example.SCM.security;

import com.example.SCM.entity.User;
import com.example.SCM.repository.NotificationRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;

@Component("notificationSecurity")
@RequiredArgsConstructor
public class NotificationSecurity {

    private final NotificationRepository notificationRepository;

    public boolean isOwner(Long notificationId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || notificationId == null) {
            return false;
        }
        if (!(authentication.getPrincipal() instanceof User user)) {
            return false;
        }

        String currentUserId = user.getId().toString();

        return notificationRepository.findById(notificationId)
                .map(n -> currentUserId.equals(n.getRecipientId()))
                .orElse(false);
    }
}