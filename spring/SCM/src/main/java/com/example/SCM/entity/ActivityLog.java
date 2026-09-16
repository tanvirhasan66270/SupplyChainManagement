package com.example.SCM.entity;

import com.example.SCM.enumClass.ActionStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "activity_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ActivityLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String userId;


    private String userEmail;

    @Column(nullable = false) // CREATE, UPDATE, DELETE, LOGIN
    private String action;

    @Column(nullable = false) // PO, GRN, QC, LC, SHIPMENT
    private String module;

    @Column(nullable = false)
    private String referenceId;

    // বড় ডেটার জন্য TEXT অবশ্যই থাকবে
    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String oldValue;

    @Column(columnDefinition = "TEXT")
    private String newValue;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ActionStatus actionStatus = ActionStatus.SUCCESS;


    private String ipAddress;


    @Column(nullable = false, updatable = false)
    private LocalDateTime performedAt;

    @PrePersist
    protected void onCreate() {
        this.performedAt = LocalDateTime.now();
    }
}