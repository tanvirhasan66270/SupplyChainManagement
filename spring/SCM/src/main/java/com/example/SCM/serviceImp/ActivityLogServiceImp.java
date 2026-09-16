package com.example.SCM.serviceImp;

import com.example.SCM.entity.ActivityLog;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.repository.ActivityLogRepository;
import com.example.SCM.service.ActivityLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ActivityLogServiceImp implements ActivityLogService {

    private final ActivityLogRepository logRepository;

    @Override
    @Transactional
    public void log(String userId, String userEmail, String action, String module,String referenceId, String description,
                    String oldValue,String newValue, ActionStatus actionStatus, String ipAddress) {

        ActivityLog auditLog = new ActivityLog();
        auditLog.setUserId(userId);
        auditLog.setUserEmail(userEmail);
        auditLog.setAction(action);
        auditLog.setModule(module != null ? module.toUpperCase() : "UNKNOWN");
        auditLog.setReferenceId(referenceId);
        auditLog.setDescription(description);
        auditLog.setOldValue(oldValue);
        auditLog.setNewValue(newValue);
        auditLog.setActionStatus(actionStatus != null ? actionStatus : ActionStatus.SUCCESS);
        auditLog.setIpAddress(ipAddress != null ? ipAddress : "UNKNOWN_IP");

        logRepository.save(auditLog);
    }
}