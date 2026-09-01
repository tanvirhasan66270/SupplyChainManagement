package com.example.SCM.entity;

import com.example.SCM.enumClass.VehicleStatus;
import com.example.SCM.enumClass.VehicleType;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "vehicles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

     @Column(nullable = false, unique = true, length = 50)
    private String plateNumber;

    @Enumerated(EnumType.STRING)
     private VehicleType type;

    @Column(nullable = false)
    private Double capacity;

    @Enumerated(EnumType.STRING)
    private VehicleStatus status;

    private LocalDate lastServiceDate;

    @Column(nullable = false)
    private Integer fuelLevel; // 0 - 100

    // One-to-One or Many-to-One with Driver (FK -> driver_id)
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = true)
    private Driver driver;


}