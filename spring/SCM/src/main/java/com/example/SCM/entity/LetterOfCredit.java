package com.example.SCM.entity;

import com.example.SCM.Util.TrakingCode.TrackingCodeGenerator;
import com.example.SCM.enumClass.LcStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import org.hibernate.annotations.NotFound;
import org.hibernate.annotations.NotFoundAction;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "letter_of_credits")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LetterOfCredit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // LC number unique
    @Column(nullable = false, unique = true)
    private String lcNumber;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "purchase_order_id", nullable = false)
    @NotFound(action = NotFoundAction.IGNORE)
    private PurchaseOrder purchaseOrder;

    private String poNumber;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "supplier_id", nullable = false)
    @NotFound(action = NotFoundAction.IGNORE)
    private Supplier supplier;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "issuing_bank", nullable = false)
    @NotFound(action = NotFoundAction.IGNORE)
    private LCBank issuingBank;

    @Column(nullable = false)
    private String shipmentIncoTerms; // FOB, CIF, CFR

    @Column(nullable = false)
    private LocalDate latestShipmentDate;

    @Column(nullable = false)
    private String portOfLoading;

    @Column(nullable = false)
    private String portOfDischarge;

    private int amendmentCount = 0;

    private double amount;

    @Column(nullable = false)
    private String currency = "USD";

    @Column(nullable = false)
    private LocalDate expiryDate;

    @Enumerated(EnumType.STRING)
    private LcStatus lcStatus = LcStatus.DRAFT;

    private String documentVaultUrl;

    private LocalDate openedAt;

    @Column(updatable = false, nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();

        if (this.lcNumber == null) {
            this.lcNumber = TrackingCodeGenerator.generateTrackingCode();
        }

        if (this.purchaseOrder != null && this.poNumber == null) {
            this.poNumber = this.purchaseOrder.getPoNumber();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();

        if (this.lcStatus == LcStatus.OPENED && this.openedAt == null) {
            this.openedAt = LocalDate.now();
        }
    }

    public void incrementAmendment() {
        if (this.lcStatus == LcStatus.OPENED || this.lcStatus == LcStatus.AMENDED) {
            this.lcStatus = LcStatus.AMENDED;
            this.amendmentCount += 1;
        }
    }
}