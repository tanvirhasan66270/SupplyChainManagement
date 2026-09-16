package com.example.SCM.entity;

import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "commercial_officers")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CommercialOfficer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT")
    private String address;


    @Column(nullable = false, unique = true)
    private String nidNumber;

    @Column(unique = true)
    private String passportNumber;

    @Column(nullable = false)
    private LocalDate dob;

    @Enumerated(EnumType.STRING)
    private GenderStatus gender;

    private String image;

    private boolean isActive ;

    private LocalDate joiningDate;

    private String designation;

    @Enumerated(EnumType.STRING)
    private LanguageStatus language;

    // ── Zone management / Station Relations ──────────────────────
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "police_station_id")
    private PoliceStation policeStation;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

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