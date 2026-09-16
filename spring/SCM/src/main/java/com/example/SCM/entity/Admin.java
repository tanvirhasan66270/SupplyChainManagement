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

    // ── User Management / Auth Relations ─────────────────────────
    // Auth account — source of truth for name, phone, email, password, role
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

}
