package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class LetterOfCreditRequestDTO {
    private Long purchaseOrderId;
    private Long issuingBankId;
    private String shipmentIncoTerms;
    private String latestShipmentDate; // YYYY-MM-DD
    private String portOfLoading;
    private String portOfDischarge;
    private double amount;
    private Long supplierId;
    private String currency;
    private String expiryDate;         // YYYY-MM-DD
    private String lcStatus;
    private String documentVaultUrl; // image
}