package com.example.SCM.service;

import com.example.SCM.entity.Notification;
import java.util.List;

public interface NotificationService {
    Notification send(String recipientId, String type, String title, String message);
    List<Notification> getNotificationsForUser(String userId);
    List<Notification> getNotificationsForUserAndRole(String userId, String role);
    void markAsRead(Long id);
    void markAllAsRead(String userId);
    long getUnreadCount(String userId);
    long getUnreadCountForUserAndRole(String userId, String role);
}