package com.example.SCM.scheduler;

import com.example.SCM.entity.*;
import com.example.SCM.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
@Transactional
public class Scheduler {

    private final PurchaseRequisitionRepository requisitionRepository;
    private final PurchaseRequisitionTokenRepository tokenRepository;
    private final QuotationRepository quotationRepository;
    private final PurchaseOrderRepository purchaseOrderRepository;
    private final PurchaseOrderTokenRepository purchaseOrderTokenRepository;

    //Crone-jock


    @Scheduled(cron = "0 0 0 * * *")
    public void deleteExpiredPR() {

        LocalDate today = LocalDate.now();

        List<PurchaseRequisitionToken> list =
                tokenRepository.findByActiveTrueAndRequiredByDateLessThanEqual(today);

        for (PurchaseRequisitionToken token : list) {

            PurchaseRequisition pr =
                    requisitionRepository.findById(token.getPurchaseRequisitionId())
                            .orElse(null);

            if (pr != null) {

                if (pr.getProducts() != null) {
                    pr.getProducts().clear();
                }

                if (pr.getSuppliers() != null) {
                    pr.getSuppliers().clear();
                }

                requisitionRepository.save(pr);

                requisitionRepository.delete(pr);
            }


            // Token Expire
            token.setActive(false);
            token.setDeletedAt(LocalDateTime.now());


            token.setToken("EXPIRED_" + token.getId());

            tokenRepository.save(token);
        }
    }

    @Scheduled(cron = "0 15 5 * * *")
    public void deleteExpiredPurchaseOrders() {

        LocalDate today = LocalDate.now();

        List<PurchaseOrderToken> list =
                purchaseOrderTokenRepository
                        .findByActiveTrueAndExpiryDateLessThanEqual(today);

        for (PurchaseOrderToken token : list) {

            PurchaseOrder po =
                    purchaseOrderRepository
                            .findById(token.getPurchaseOrderId())
                            .orElse(null);

            if (po != null) {

                purchaseOrderRepository.delete(po);
            }

            token.setActive(false);
            token.setDeletedAt(LocalDateTime.now());
            token.setToken("EXPIRED_" + token.getId());

            purchaseOrderTokenRepository.save(token);
        }
    }

    // Quotation Delete
    @Scheduled(cron = "0 0 5 * * *")
    public void deleteExpiredQuotation() {

        LocalDate today = LocalDate.now();

        List<Quotation> quotations =
                quotationRepository.findByValidUntilLessThanEqual(today);

        if (quotations.isEmpty()) {
            return;
        }


        for (Quotation quotation : quotations) {

            // Attachment file delete
            if (quotation.getAttachmentUrl() != null
                    && !quotation.getAttachmentUrl().isEmpty()) {

                File file = new File(quotation.getAttachmentUrl());

                if (file.exists()) {
                    file.delete();
                }
            }


            // Delete database record
            quotationRepository.delete(quotation);
        }
    }
}