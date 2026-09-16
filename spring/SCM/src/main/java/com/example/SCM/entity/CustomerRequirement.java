package com.example.SCM.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "customer_requirements")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class CustomerRequirement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String productName;
    
    @Column(columnDefinition = "TEXT")
    private String productDescription;
    
    private String customerName;
    private String contactNumber;
    private String email;
    
    private String status;
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = "PENDING";
        }
    }
}
