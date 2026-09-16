package com.example.SCM.entity;

import com.example.SCM.enumClass.StockMovementType;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "stock_movements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class StockMovement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_warehouse_id")
    private Warehouse sourceWarehouse;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StockMovementType movementType; // INBOUND, OUTBOUND, TRANSFER, ADJUSTMENT

    private int quantity;

    @Column(nullable = false)
    private String referenceId; // GRN-Code, Invoice-Code, QC-Id

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "performed_by", nullable = false)
    private User performedBy;

    @Column(nullable = false)
    private LocalDateTime movedAt;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @PrePersist
    protected void onCreate() {
        if (this.movedAt == null) {
            this.movedAt = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.movedAt = LocalDateTime.now();
    }
}