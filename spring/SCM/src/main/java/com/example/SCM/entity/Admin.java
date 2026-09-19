package com.example.SCM.entity;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Table(name = "admin")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Admin {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String email;
    private String phone;


    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

}
