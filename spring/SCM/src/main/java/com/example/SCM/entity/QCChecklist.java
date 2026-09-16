package com.example.SCM.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "qc_checklists")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class QCChecklist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // FK → QCInspection (Parent Relationship)
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inspection_id", nullable = false)
    private QCInspection qcInspection;

    @Column(nullable = false, length = 150)
    private String checkpointName;

    private boolean isPassed;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {

        this.updatedAt = LocalDateTime.now();
    }
}