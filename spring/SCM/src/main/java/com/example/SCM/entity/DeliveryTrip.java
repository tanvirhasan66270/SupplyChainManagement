package com.example.SCM.entity;

import com.example.SCM.enumClass.DeliveryTripStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "delivery_trips")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DeliveryTrip {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long dispatcherId;

    private LocalDateTime startedAt;

    private LocalDateTime completedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private DeliveryTripStatus status; // e.g., PENDING, IN_TRANSIT, DELIVERED, CANCELLED

    private String recipientSignature;

    private String deliveryPhotoUrl;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String customerAddress;


    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(updatable = false, nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;


    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false)
    private Driver driver;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        syncStatusTimestamps();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        syncStatusTimestamps();
    }

    private void syncStatusTimestamps() {
        if (this.status == DeliveryTripStatus.IN_TRANSIT && this.startedAt == null) {
            this.startedAt = LocalDateTime.now();
        } else if (this.status == DeliveryTripStatus.DELIVERED && this.completedAt == null) {
            if (this.startedAt == null) {
                this.startedAt = LocalDateTime.now();
            }
            this.completedAt = LocalDateTime.now();
        }
    }
}