package com.example.SCM.entity;

import com.example.SCM.enumClass.ReportStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "daily_reports")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String warehouseId;

    @Column(nullable = false)
    private LocalDate reportDate;

    private int totalTasksDone;

    private int issuesLogged;

    @Column(columnDefinition = "TEXT")
    private String summary;

    @Enumerated(EnumType.STRING)
    private ReportStatus reportStatus = ReportStatus.DRAFT;


    private String attachmentUrl;// image

    @Column(nullable = false, updatable = false)
    private LocalDateTime generatedAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.generatedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}