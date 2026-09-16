package com.example.SCM.serviceImp;

import com.example.SCM.Util.MailService;
import com.example.SCM.dto.mapper.PurchaseOrderMapper;
import com.example.SCM.dto.request.PurchaseOrderRequestDTO;
import com.example.SCM.dto.response.PurchaseOrderResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.enumClass.PurchaseOrderStatus;
import com.example.SCM.repository.PurchaseOrderRepository;
import com.example.SCM.repository.PurchaseOrderTokenRepository;
import com.example.SCM.repository.QuotationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.ActivityLogService;
import com.example.SCM.service.NotificationService;
import com.example.SCM.service.PurchaseOrderService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PurchaseOrderServiceImp implements PurchaseOrderService {

    private final PurchaseOrderRepository purchaseOrderRepository;
    private final QuotationRepository quotationRepository;
    private final PurchaseOrderMapper purchaseOrderMapper;
    private final MailService mailService;
    private final PurchaseOrderTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    // Activity Log & Request Context Dependencies
    private final ActivityLogService activityLogService;
    private final HttpServletRequest request;

    private static final int APPROVAL_LINK_VALID_DAYS = 7;
    private static final int RECEIVE_LINK_VALID_DAYS = 30;


     // Dynamically resolves the current logged-in user or system actor

    private String resolveCurrentUserId() {
        String userId = request.getHeader("X-User-Id");
        if (userId != null && !userId.isBlank()) {
            return userId;
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !authentication.getName().equals("anonymousUser")) {
            return authentication.getName();
        }
        return "SYSTEM_AUTOMATION";
    }

    @Override
    @Transactional
    public PurchaseOrderResponseDTO save(PurchaseOrderRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Purchase Order data cannot be null");
        }

        Quotation quotation = quotationRepository.findById(dto.getQuotationId())
                .orElseThrow(() -> new RuntimeException("Quotation not found with ID: " + dto.getQuotationId()));

        Supplier supplier = quotation.getSupplier();
        if (supplier == null) {
            throw new RuntimeException("No Supplier is linked with the selected Quotation!");
        }

        PurchaseRequisition purchaseRequisition = quotation.getPurchaseRequisition();
        if (purchaseRequisition == null) {
            throw new RuntimeException("No Purchase Requisition is linked with the selected Quotation!");
        }

        PurchaseOrder po = purchaseOrderMapper.toEntity(dto, quotation, supplier, purchaseRequisition);
        po.setStatus(PurchaseOrderStatus.DRAFT);
        PurchaseOrder savedPo = purchaseOrderRepository.save(po);

        try {
            if (savedPo.getSupplier() != null && savedPo.getSupplier().getUser() != null) {
                notificationService.send(
                        savedPo.getSupplier().getUser().getId().toString(),
                        "PURCHASE_ORDER",
                        "New Purchase Order #" + savedPo.getPoNumber(),
                        "A new purchase order has been created for you. Please review the details."
                );
            }
        } catch (Exception e) {
            System.out.println("Error sending notification for PO creation: " + e.getMessage());
        }

        PurchaseOrderToken token = new PurchaseOrderToken();
        token.setToken(UUID.randomUUID().toString());
        token.setActive(true);
        token.setExpiryDate(LocalDateTime.now().plusDays(APPROVAL_LINK_VALID_DAYS));
        token.setPurchaseOrderId(savedPo.getId());
        token.setPoNumber(savedPo.getPoNumber());
        token.setIssuedBy(savedPo.getIssuedBy());
        token.setQuantity(savedPo.getQuantity());
        token.setTotalAmount(savedPo.getTotalAmount());
        token.setCurrency(savedPo.getCurrency());
        token.setExpectedDeliveryDate(savedPo.getExpectedDeliveryDate());
        token.setStatus(savedPo.getStatus());
        token.setSupplierId(savedPo.getSupplier().getId());
        token.setPurchaseRequisitionId(savedPo.getPurchaseRequisition().getId());
        token.setQuotationId(savedPo.getQuotation().getId());
        token.setPurchaseCreatedAt(savedPo.getCreatedAt());
        token.setPurchaseUpdatedAt(savedPo.getUpdatedAt());

        PurchaseOrderToken savedToken = tokenRepository.save(token);

        sendPoApprovalMailToManager(savedPo, savedToken);

        //  ACTIVITY LOG: CREATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "CREATE",
                "PURCHASE_ORDER",
                savedPo.getId().toString(),
                "New Purchase Order drafted successfully. PO Number: " + savedPo.getPoNumber(),
                null,
                "{\"status\":\"" + savedPo.getStatus().name() + "\", \"totalAmount\":" + savedPo.getTotalAmount() + "}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return purchaseOrderMapper.convertTOResponseDTO(savedPo);
    }

    @Override
    @Transactional
    public PurchaseOrderResponseDTO managerIssuedOrderByToken(String token) {
        PurchaseOrderToken poToken = tokenRepository.findByTokenAndActiveTrue(token)
                .orElseThrow(() -> new RuntimeException("Invalid or expired approval link"));

        if (poToken.getExpiryDate() != null && poToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("This approval link has expired");
        }

        PurchaseOrder po = purchaseOrderRepository.findById(poToken.getPurchaseOrderId())
                .orElseThrow(() -> new RuntimeException("Purchase Order node missing at ID: " + poToken.getPurchaseOrderId()));

        if (po.getStatus() != PurchaseOrderStatus.DRAFT) {
            throw new RuntimeException("Order has already been processed or Issued!");
        }

        PurchaseOrderStatus oldStatus = po.getStatus();
        po.setStatus(PurchaseOrderStatus.ISSUED);
        PurchaseOrder issuedPo = purchaseOrderRepository.save(po);

        poToken.setToken(UUID.randomUUID().toString());
        poToken.setExpiryDate(LocalDateTime.now().plusDays(RECEIVE_LINK_VALID_DAYS));
        poToken.setStatus(issuedPo.getStatus());
        poToken.setPurchaseUpdatedAt(issuedPo.getUpdatedAt());
        PurchaseOrderToken receiveToken = tokenRepository.save(poToken);

        sendPoIssuedMailToSupplier(issuedPo, receiveToken);

        //  ACTIVITY LOG: TOKEN ISSUED BY MANAGER
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "APPROVE",
                "PURCHASE_ORDER",
                issuedPo.getId().toString(),
                "Purchase Order officially ISSUED by Manager via secure email token link. PO Number: " + issuedPo.getPoNumber(),
                "{\"status\":\"" + oldStatus + "\"}",
                "{\"status\":\"" + issuedPo.getStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return purchaseOrderMapper.convertTOResponseDTO(issuedPo);
    }

    @Override
    @Transactional
    public PurchaseOrderResponseDTO supplierReceivedOrder(String token) {
        PurchaseOrderToken poToken = tokenRepository.findByTokenAndActiveTrue(token)
                .orElseThrow(() -> new RuntimeException("Invalid or expired acknowledgement link"));

        if (poToken.getExpiryDate() != null && poToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("This acknowledgement link has expired");
        }

        PurchaseOrder po = purchaseOrderRepository.findById(poToken.getPurchaseOrderId())
                .orElseThrow(() -> new RuntimeException("Purchase Order node missing at ID: " + poToken.getPurchaseOrderId()));

        if (po.getStatus() != PurchaseOrderStatus.ISSUED) {
            throw new RuntimeException("Only ISSUED orders can be acknowledged or Received by Supplier!");
        }

        PurchaseOrderStatus oldStatus = po.getStatus();
        po.setStatus(PurchaseOrderStatus.RECEIVED);
        PurchaseOrder receivedPo = purchaseOrderRepository.save(po);

        poToken.setActive(false);
        poToken.setStatus(receivedPo.getStatus());
        poToken.setPurchaseUpdatedAt(receivedPo.getUpdatedAt());
        tokenRepository.save(poToken);

        //  ACTIVITY LOG: SUPPLIER ACKNOWLEDGEMENT
        activityLogService.log(
                "SUPPLIER_PORTAL",
                null,
                "ACKNOWLEDGE",
                "PURCHASE_ORDER",
                receivedPo.getId().toString(),
                "Purchase Order acknowledged & RECEIVED by Supplier via email link. PO Number: " + receivedPo.getPoNumber(),
                "{\"status\":\"" + oldStatus + "\"}",
                "{\"status\":\"" + receivedPo.getStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return purchaseOrderMapper.convertTOResponseDTO(receivedPo);
    }

    @Override
    @Transactional
    public PurchaseOrderResponseDTO approveOrder(Long id) {
        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase Order node missing at ID: " + id));

        if (po.getStatus() != PurchaseOrderStatus.DRAFT) {
            throw new RuntimeException("Order has already been processed or Issued!");
        }

        PurchaseOrderStatus oldStatus = po.getStatus();
        po.setStatus(PurchaseOrderStatus.ISSUED);
        PurchaseOrder issuedPo = purchaseOrderRepository.save(po);

        PurchaseOrderToken poToken = tokenRepository.findByPurchaseOrderId(id).orElse(null);

        if (poToken != null && poToken.isActive()) {
            poToken.setToken(UUID.randomUUID().toString());
            poToken.setExpiryDate(LocalDateTime.now().plusDays(RECEIVE_LINK_VALID_DAYS));
            poToken.setStatus(issuedPo.getStatus());
            poToken.setPurchaseUpdatedAt(issuedPo.getUpdatedAt());
            tokenRepository.save(poToken);

            sendPoIssuedMailToSupplier(issuedPo, poToken);
        }

        //  ACTIVITY LOG: MANUAL APPROVAL
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "APPROVE",
                "PURCHASE_ORDER",
                issuedPo.getId().toString(),
                "Purchase Order manually approved and ISSUED by Manager. PO Number: " + issuedPo.getPoNumber(),
                "{\"status\":\"" + oldStatus + "\"}",
                "{\"status\":\"" + issuedPo.getStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return purchaseOrderMapper.convertTOResponseDTO(issuedPo);
    }

    @Override
    @Transactional
    public PurchaseOrderResponseDTO updateShipmentQuantityCheck(Long id, int shippedQuantity) {
        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase Order missing for Cargo Update at ID: " + id));

        PurchaseOrderStatus oldStatus = po.getStatus();
        int oldQuantity = po.getQuantity();

        if (shippedQuantity < po.getQuantity()) {
            po.setStatus(PurchaseOrderStatus.PARTIALLY_RECEIVED);
        } else {
            po.setStatus(PurchaseOrderStatus.RECEIVED);
        }

        PurchaseOrder updatedPo = purchaseOrderRepository.save(po);

        //  ACTIVITY LOG: SHIPMENT UPDATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE_SHIPMENT",
                "PURCHASE_ORDER",
                updatedPo.getId().toString(),
                "Shipment quantity verified for PO Number: " + updatedPo.getPoNumber() + " (Shipped: " + shippedQuantity + "/" + oldQuantity + ")",
                "{\"status\":\"" + oldStatus + "\", \"quantity\":" + oldQuantity + "}",
                "{\"status\":\"" + updatedPo.getStatus() + "\", \"shippedQuantity\":" + shippedQuantity + "}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return purchaseOrderMapper.convertTOResponseDTO(updatedPo);
    }

    @Override
    @Transactional
    public PurchaseOrderResponseDTO updateStatus(Long id, PurchaseOrderStatus status) {
        if (id == null || status == null) {
            throw new IllegalArgumentException("Purchase Order ID and Status cannot be null");
        }

        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase Order node missing at ID: " + id));

        if (po.getStatus() != PurchaseOrderStatus.ISSUED) {
            throw new RuntimeException("Action denied: Only ISSUED purchase orders can be updated by the supplier.");
        }

        PurchaseOrderStatus oldStatus = po.getStatus();
        po.setStatus(status);
        PurchaseOrder updatedPo = purchaseOrderRepository.save(po);

        Optional<PurchaseOrderToken> tokenOpt = tokenRepository.findByPurchaseOrderId(id);
        if (tokenOpt.isPresent()) {
            PurchaseOrderToken poToken = tokenOpt.get();
            poToken.setStatus(updatedPo.getStatus());
            poToken.setPurchaseUpdatedAt(updatedPo.getUpdatedAt());

            if (status == PurchaseOrderStatus.RECEIVED || status == PurchaseOrderStatus.CANCELLED) {
                poToken.setActive(false);
            }
            tokenRepository.save(poToken);
        }

        //  ACTIVITY LOG: STATUS UPDATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE_STATUS",
                "PURCHASE_ORDER",
                updatedPo.getId().toString(),
                "Purchase Order status changed from " + oldStatus + " to " + updatedPo.getStatus() + " for PO: " + updatedPo.getPoNumber(),
                "{\"status\":\"" + oldStatus + "\"}",
                "{\"status\":\"" + updatedPo.getStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return purchaseOrderMapper.convertTOResponseDTO(updatedPo);
    }

    @Override
    @Transactional
    public PurchaseOrderResponseDTO update(Long id, PurchaseOrderRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Update data cannot be null");
        }

        PurchaseOrder po = purchaseOrderRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new RuntimeException("PO not found with ID: " + id));

        if (po.getStatus() != PurchaseOrderStatus.DRAFT) {
            throw new RuntimeException(
                    "Cannot modify a Purchase Order that has already been " + po.getStatus() +
                            ". Please raise an amendment or cancel and recreate instead.");
        }

        Quotation quotation = po.getQuotation();
        Supplier supplier = po.getSupplier();
        PurchaseRequisition pr = po.getPurchaseRequisition();

        if (dto.getQuotationId() != null && !dto.getQuotationId().equals(quotation.getId())) {
            quotation = quotationRepository.findById(dto.getQuotationId())
                    .orElseThrow(() -> new RuntimeException("Quotation not found with ID: " + dto.getQuotationId()));
            supplier = quotation.getSupplier();
            pr = quotation.getPurchaseRequisition();
        }

        double oldTotalAmount = po.getTotalAmount();
        int oldQuantity = po.getQuantity();

        purchaseOrderMapper.updateEntity(dto, po, quotation, supplier, pr);
        PurchaseOrder updated = purchaseOrderRepository.save(po);

        PurchaseOrderToken token = tokenRepository.findByPurchaseOrderId(updated.getId()).orElse(null);
        if (token != null) {
            token.setPoNumber(updated.getPoNumber());
            token.setIssuedBy(updated.getIssuedBy());
            token.setQuantity(updated.getQuantity());
            token.setTotalAmount(updated.getTotalAmount());
            token.setCurrency(updated.getCurrency());
            token.setExpectedDeliveryDate(updated.getExpectedDeliveryDate());
            token.setStatus(updated.getStatus());
            token.setSupplierId(updated.getSupplier().getId());
            token.setPurchaseRequisitionId(updated.getPurchaseRequisition().getId());
            token.setQuotationId(updated.getQuotation().getId());
            token.setPurchaseUpdatedAt(updated.getUpdatedAt());
            tokenRepository.save(token);
        }

        //  ACTIVITY LOG: UPDATE METADATA
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE",
                "PURCHASE_ORDER",
                updated.getId().toString(),
                "Purchase Order details modified while in DRAFT mode for PO: " + updated.getPoNumber(),
                "{\"totalAmount\":" + oldTotalAmount + ", \"quantity\":" + oldQuantity + "}",
                "{\"totalAmount\":" + updated.getTotalAmount() + ", \"quantity\":" + updated.getQuantity() + "}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return purchaseOrderMapper.convertTOResponseDTO(updated);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("PO not found with ID: " + id));

        if (po.getStatus() != PurchaseOrderStatus.DRAFT) {
            throw new RuntimeException(
                    "Cannot delete a Purchase Order that has already been " + po.getStatus() +
                            ". Consider cancelling it instead.");
        }

        String poNumber = po.getPoNumber();
        purchaseOrderRepository.deleteById(id);

        //  ACTIVITY LOG: DELETE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "DELETE",
                "PURCHASE_ORDER",
                id.toString(),
                "Purchase Order permanently purged from system. PO Number was: " + poNumber,
                "{\"poNumber\":\"" + poNumber + "\", \"status\":\"DRAFT\"}",
                null,
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );
    }

    @Override
    @Transactional(readOnly = true)
    public List<PurchaseOrderResponseDTO> findAll() {
        return purchaseOrderRepository.findAllPurchaseOrders().stream()
                .map(purchaseOrderMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<PurchaseOrderResponseDTO> getById(Long id) {
        return purchaseOrderRepository.findByIdWithDetails(id)
                .map(purchaseOrderMapper::convertTOResponseDTO);
    }

    private void sendPoApprovalMailToManager(PurchaseOrder po, PurchaseOrderToken token) {
        List<User> managers = userRepository.findByRole(Role.MANAGER);

        String subject = "SCM Approval Request: Authorize Purchase Order #" + po.getPoNumber();
        String issueUrl = "http://localhost:8085/api/purchase-orders/email-issue?token=" + token.getToken();

        String mailContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: 'Segoe UI', Arial, sans-serif; color: #2D3748; }
                .container { max-width: 600px; margin: 20px auto; border: 1px solid #E2E8F0; border-radius: 8px; overflow: hidden; }
                .header { background-color: #2B6CB0; color: white; padding: 20px; text-align: center; }
                .btn { background-color: #3182CE; color: white !important; padding: 12px 30px; font-weight: bold; text-decoration: none; border-radius: 5px; display: inline-block; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'><h2>Purchase Order Review Authorization</h2></div>
                <div style='padding: 25px;'>
                    <p>Dear Manager,</p>
                    <p>A new purchase procurement track has been compiled. Please review the financial outline below:</p>
                    <ul>
                        <li><b>PO Number:</b> %s</li>
                        <li><b>Supplier:</b> %s</li>
                        <li><b>Total Volume:</b> %d Units</li>
                        <li><b>Financial Aggregate:</b> %.2f %s</li>
                        <li><b>Expected Delivery:</b> %s</li>
                    </ul>
                    <div style='text-align: center; margin: 30px 0;'>
                        <a href='%s' class='btn'>✔ ISSUE THIS ORDER NOW</a>
                    </div>
                    <p style='color:#718096; font-size:12px;'>This link is valid for %d days and can only be used once.</p>
                </div>
            </div>
        </body>
        </html>
        """.formatted(po.getPoNumber(), po.getSupplier().getName(), po.getQuantity(),
                po.getTotalAmount(), po.getCurrency(), po.getExpectedDeliveryDate().toString(),
                issueUrl, APPROVAL_LINK_VALID_DAYS);

        try {
            for (User manager : managers) {
                mailService.senderGeneralMail(manager.getEmail(), subject, mailContent);
            }
        } catch (Exception e) {
            System.err.println("Manager PO Dispatch Pipeline Failed: " + e.getMessage());
        }
    }

    private void sendPoIssuedMailToSupplier(PurchaseOrder po, PurchaseOrderToken token) {
        if (po.getSupplier() == null || po.getSupplier().getEmail() == null) return;

        String supplierEmail = po.getSupplier().getEmail();
        String subject = "SCM Commercial Dispatch: Official Purchase Order #" + po.getPoNumber();
        String receiveUrl = "http://localhost:8085/api/purchase-orders/email-receive?token=" + token.getToken();

        String mailContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: 'Segoe UI', Arial, sans-serif; color: #2D3748; }
                .container { max-width: 600px; margin: 20px auto; border: 1px solid #E2E8F0; border-radius: 8px; overflow: hidden; }
                .header { background-color: #1A202C; color: white; padding: 20px; text-align: center; }
                .btn { background-color: #38A169; color: white !important; padding: 12px 30px; font-weight: bold; text-decoration: none; border-radius: 5px; display: inline-block; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'><h2>Official Purchase Order Dispatched</h2></div>
                <div style='padding: 25px;'>
                    <p>Dear <b>%s</b>,</p>
                    <p>We are pleased to place an official firm corporate order with your production facility. Commercial parameters are enclosed below:</p>
                    <ul>
                        <li><b>Purchase Order Id:</b> #%s</li>
                        <li><b>Supply Quota Volume:</b> %d Units</li>
                        <li><b>Commercial Settlement:</b> %.2f %s</li>
                        <li><b>Latest Required Shipment Date:</b> %s</li>
                    </ul>
                    <p>Please click down under to instantly acknowledge receipt and confirm your delivery routing window:</p>
                    <div style='text-align: center; margin: 30px 0;'>
                        <a href='%s' class='btn'>🤝 ACKNOWLEDGE & RECEIVE ORDER</a>
                    </div>
                    <p style='color:#718096; font-size:12px;'>This link is valid for %d days and can only be used once.</p>
                </div>
            </div>
        </body>
        </html>
        """.formatted(po.getSupplier().getName(), po.getPoNumber(), po.getQuantity(),
                po.getTotalAmount(), po.getCurrency(), po.getExpectedDeliveryDate().toString(),
                receiveUrl, RECEIVE_LINK_VALID_DAYS);

        try {
            mailService.senderGeneralMail(supplierEmail, subject, mailContent);
        } catch (Exception e) {
            System.err.println("Supplier PO Dispatch Pipeline Failed: " + e.getMessage());
        }
    }
}