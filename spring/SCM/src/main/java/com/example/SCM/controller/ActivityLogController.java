package com.example.SCM.controller;

import com.example.SCM.entity.ActivityLog;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.repository.ActivityLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/logs")
@RequiredArgsConstructor
//@PreAuthorize("hasRole('MANAGER')")
public class ActivityLogController {

    private final ActivityLogRepository logRepository;

    // 1. Fetch All Activity Logs
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @GetMapping
    public ResponseEntity<List<ActivityLog>> getAllLogs() {
        return ResponseEntity.ok(logRepository.findAllByOrderByPerformedAtDesc());
    }

    // 2. Filter Audit Trail By Module Name
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @GetMapping("/module/{moduleName}")
    public ResponseEntity<List<ActivityLog>> getLogsByModule(@PathVariable String moduleName) {
        return ResponseEntity.ok(logRepository.findByModuleOrderByPerformedAtDesc(moduleName.toUpperCase()));
    }

    // 3. Track Specific Employee By ID
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ActivityLog>> getLogsByUserId(@PathVariable String userId) {
        return ResponseEntity.ok(logRepository.findByUserIdOrderByPerformedAtDesc(userId));
    }

    // 4. Filter Logs By Action Status Enum (e.g., SUCCESS, FAILED)
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    @GetMapping("/status/{status}")
    public ResponseEntity<List<ActivityLog>> getLogsByStatus(@PathVariable String status) {
        try {
            ActionStatus actionStatus = ActionStatus.valueOf(status.toUpperCase());
            return ResponseEntity.ok(logRepository.findByActionStatusOrderByPerformedAtDesc(actionStatus));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build(); // ভুল এনাম স্ট্যাটাস পাঠালে ব্যাড রিকোয়েস্ট দেবে
        }
    }
}
