package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.LetterOfCreditRequestDTO;
import com.example.SCM.dto.response.LetterOfCreditResponseDTO;
import com.example.SCM.entity.LCBank;
import com.example.SCM.entity.LetterOfCredit;
import com.example.SCM.entity.PurchaseOrder;
import com.example.SCM.entity.Supplier;
import com.example.SCM.enumClass.LcStatus;
import com.example.SCM.repository.LCBankRepository;
import com.example.SCM.repository.PurchaseOrderRepository;
import com.example.SCM.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
@RequiredArgsConstructor
public class LetterOfCreditMapper {

    private final PurchaseOrderRepository poRepository;
    private final SupplierRepository supplierRepository;
    private final LCBankRepository bankRepository;


    public LetterOfCredit toEntity(LetterOfCreditRequestDTO dto) {
        if (dto == null) return null;

        LetterOfCredit lc = new LetterOfCredit();

        // 1. Bank Binding
        if (dto.getIssuingBankId() != null) {
            LCBank bank = bankRepository.findById(dto.getIssuingBankId())
                    .orElseThrow(() -> new RuntimeException("Selected Target Bank context missing for ID: " + dto.getIssuingBankId()));
            lc.setIssuingBank(bank);
        }

        // 2. Core SCM Terms & Routing
        lc.setShipmentIncoTerms(dto.getShipmentIncoTerms());
        lc.setPortOfLoading(dto.getPortOfLoading());
        lc.setPortOfDischarge(dto.getPortOfDischarge());
        lc.setAmount(dto.getAmount());

        // 3. Supplier Beneficiary Binding
        if (dto.getSupplierId() != null) {
            Supplier supplier = supplierRepository.findById(dto.getSupplierId())
                    .orElseThrow(() -> new RuntimeException("Supplier record missing for ID: " + dto.getSupplierId()));
            lc.setSupplier(supplier);
        }

        // 4. String & Vault Field Protection
        if (dto.getCurrency() != null && !dto.getCurrency().isBlank()) lc.setCurrency(dto.getCurrency());
        if (dto.getDocumentVaultUrl() != null) lc.setDocumentVaultUrl(dto.getDocumentVaultUrl());

        // 5. Temporal Chronology Parsing (String -> LocalDate)
        if (dto.getLatestShipmentDate() != null && !dto.getLatestShipmentDate().isBlank()) {
            lc.setLatestShipmentDate(LocalDate.parse(dto.getLatestShipmentDate()));
        }
        if (dto.getExpiryDate() != null && !dto.getExpiryDate().isBlank()) {
            lc.setExpiryDate(LocalDate.parse(dto.getExpiryDate()));
        }

        // 6. State Machine Enum Sync
        if (dto.getLcStatus() != null && !dto.getLcStatus().isBlank()) {
            lc.setLcStatus(LcStatus.valueOf(dto.getLcStatus().toUpperCase()));
        }

        // 7. Parent Purchase Order Rolling Sync
        if (dto.getPurchaseOrderId() != null) {
            PurchaseOrder po = poRepository.findById(dto.getPurchaseOrderId())
                    .orElseThrow(() -> new RuntimeException("Purchase Order not found for ID: " + dto.getPurchaseOrderId()));
            lc.setPurchaseOrder(po);
            lc.setPoNumber(po.getPoNumber());
        }

        return lc;
    }


    public LetterOfCreditResponseDTO convertTOResponseDTO(LetterOfCredit entity) {
        if (entity == null) return null;

        LetterOfCreditResponseDTO dto = new LetterOfCreditResponseDTO();
        dto.setId(entity.getId());
        dto.setLcNumber(entity.getLcNumber());
        dto.setPoNumber(entity.getPoNumber());

        // 1. Bank Data Flattening
        if (entity.getIssuingBank() != null) {
            LCBank bank = entity.getIssuingBank();
            dto.setIssuingBankId(bank.getId());
            dto.setIssuingBankName(bank.getName());
            dto.setIssuingBankSwiftCode(bank.getSwiftCode());
            dto.setIssuingBankBranch(bank.getBranchName());
            dto.setIssuingBankaddress(bank.getAddress());
        }

        // 2. Financial Metrics & Logistics
        dto.setShipmentIncoTerms(entity.getShipmentIncoTerms());
        dto.setAmount(entity.getAmount());
        dto.setCurrency(entity.getCurrency());
        dto.setAmendmentCount(entity.getAmendmentCount());
        dto.setPortOfLoading(entity.getPortOfLoading());
        dto.setPortOfDischarge(entity.getPortOfDischarge());
        dto.setDocumentVaultUrl(entity.getDocumentVaultUrl());

        // 3. Enum Name Conversion Safety
        if (entity.getLcStatus() != null) {
            dto.setLcStatus(entity.getLcStatus().name());
        }

        // 4. Supplier Profile Flattening
        if (entity.getSupplier() != null) {
            dto.setSupplierId(entity.getSupplier().getId());
            dto.setSupplierName(entity.getSupplier().getName());
            dto.setSupplierEmail(entity.getSupplier().getEmail());
        }

        // 5. Parent Relation Mapping
        if (entity.getPurchaseOrder() != null) {
            dto.setPurchaseOrderId(entity.getPurchaseOrder().getId());
        }

        // 6. Temporal Audit Conversion (LocalDate/LocalDateTime -> String)
        if (entity.getLatestShipmentDate() != null) dto.setLatestShipmentDate(entity.getLatestShipmentDate().toString());
        if (entity.getExpiryDate() != null) dto.setExpiryDate(entity.getExpiryDate().toString());
        if (entity.getOpenedAt() != null) dto.setOpenedAt(entity.getOpenedAt().toString());
        if (entity.getCreatedAt() != null) dto.setCreatedAt(entity.getCreatedAt().toString());
        if (entity.getUpdatedAt() != null) dto.setUpdatedAt(entity.getUpdatedAt().toString());

        return dto;
    }
}