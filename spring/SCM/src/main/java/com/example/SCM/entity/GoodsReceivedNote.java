package com.example.SCM.entity;

import com.example.SCM.enumClass.GRNStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "goods_received_notes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GoodsReceivedNote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @Column(unique = true, nullable = false)
    private String grnNumber;

    private Integer quantity;

    private int receivedQuantity;

    @Column(nullable = false)
    private LocalDate receivedAt;

    @Enumerated(EnumType.STRING)
    private GRNStatus status;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    private LocalDate inspectionDate;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    // ── System Core / Warehouse Relations ────────────────────────
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "po_id", nullable = false)
    private PurchaseOrder purchaseOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "received_by", nullable = false)
    private User receivedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inspected_by")
    private User inspectedBy;

    @OneToMany(mappedBy = "goodsReceivedNote", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<GRNLineItem> lineItems = new ArrayList<>();

    @PrePersist
    protected void onCreate() {

        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}