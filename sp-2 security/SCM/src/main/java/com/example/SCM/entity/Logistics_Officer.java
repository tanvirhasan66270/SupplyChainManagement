package com.example.SCM.entity;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "logistics_officers")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Logistics_Officer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    // Auth account — Source of truth for name, phone, email, password, role

    @JsonIgnore
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "contact_person", nullable = false)
    private String contactPerson;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column( nullable = false, unique = true)
    private String nidNumber;

    @Column(unique = true)
    private String passportNumber;

    @Column(nullable = false)
    private LocalDate dob;

    @Enumerated(EnumType.STRING)
     private GenderStatus gender;


    private String image;

    @Column(name = "is_active", nullable = false)
    private boolean isActive ;


    private LocalDate joiningDate;

    private String designation;

    @Enumerated(EnumType.STRING)

    private LanguageStatus language;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "police_station_id")
    private PoliceStation policeStation;

    @Column(name = "created_at", updatable = false)
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