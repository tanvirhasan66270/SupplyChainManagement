package com.example.SCM.entity;


import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;


@Entity
@Table(name = "lc-banks")
@Data
@NoArgsConstructor
@AllArgsConstructor

public class LCBank {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;

    @Column(unique = true)
    private String swiftCode;

    private String branchName;
   private String address;
    private String contactEmail;
    private String contactPhone;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
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