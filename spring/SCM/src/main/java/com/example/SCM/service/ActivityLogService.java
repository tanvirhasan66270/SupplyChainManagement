package com.example.SCM.service;

import com.example.SCM.enumClass.ActionStatus;

public interface ActivityLogService {
    void log(String userId, String userEmail, String action, String module,
             String referenceId, String description, String oldValue,
             String newValue, ActionStatus actionStatus, String ipAddress);
}