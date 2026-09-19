package com.example.SCM.controller;

import com.example.SCM.entity.Notification;
import com.example.SCM.entity.User;
import com.example.SCM.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@PreAuthorize("isAuthenticated()")
public class NotificationController {

    private final NotificationService service;

    @GetMapping
    public ResponseEntity<List<Notification>> getUserNotifications(
            @AuthenticationPrincipal User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId,
            @RequestHeader(value = "X-User-Role", required = false) String backupUserRole) {

        String finalUserId = resolveUserId(currentUser, backupUserId);
        String finalRole = (currentUser != null && currentUser.getRole() != null)
                ? currentUser.getRole().name()
                : backupUserRole;

        if (finalUserId == null && finalRole == null) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(service.getNotificationsForUserAndRole(finalUserId, finalRole));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Long> getCount(
            @AuthenticationPrincipal User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId,
            @RequestHeader(value = "X-User-Role", required = false) String backupUserRole) {

        String finalUserId = resolveUserId(currentUser, backupUserId);
        String finalRole = (currentUser != null && currentUser.getRole() != null)
                ? currentUser.getRole().name()
                : backupUserRole;

        if (finalUserId == null && finalRole == null) {
            return ResponseEntity.ok(0L);
        }

        return ResponseEntity.ok(service.getUnreadCountForUserAndRole(finalUserId, finalRole));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markRead(@PathVariable Long id) {
        service.markAsRead(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllRead(
            @AuthenticationPrincipal User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId) {

        String finalUserId = resolveUserId(currentUser, backupUserId);
        if (finalUserId != null) {
            service.markAllAsRead(finalUserId);
        }
        return ResponseEntity.noContent().build();
    }

    private String resolveUserId(User currentUser, String backupUserId) {
        if (currentUser != null && currentUser.getId() != null) {
            return currentUser.getId().toString();
        }
        if (backupUserId != null && !backupUserId.trim().isEmpty() && !"null".equalsIgnoreCase(backupUserId)) {
            return backupUserId.trim();
        }
        return null;
    }
}
