package com.example.SCM.serviceImp;

import com.example.SCM.Util.MailService;
import com.example.SCM.dto.mapper.PurchaseRequisitionMapper;
import com.example.SCM.dto.request.PurchaseRequisitionRequestDTO;
import com.example.SCM.dto.response.PurchaseRequisitionResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.enumClass.PurchaseRequisitionStatus;
import com.example.SCM.repository.*;
import com.example.SCM.service.ActivityLogService;
import com.example.SCM.role.Role;
import com.example.SCM.service.NotificationService;
import com.example.SCM.service.PurchaseRequisitionService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PurchaseRequisitionServiceImp implements PurchaseRequisitionService {

    private final PurchaseRequisitionRepository requisitionRepository;
    private final ProductRepository productRepository;
    private final SupplierRepository supplierRepository;
    private final UserRepository userRepository;
    private final PurchaseRequisitionMapper requisitionMapper;
    private final MailService mailService;
    private final ActivityLogService activityLogService;
    private final HttpServletRequest request;
    private final PurchaseRequisitionTokenRepository tokenRepository;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public PurchaseRequisitionResponseDTO save(PurchaseRequisitionRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Requisition data cannot be null");
        }

        List<Product> products = null;
        if (dto.getProductIds() != null && !dto.getProductIds().isEmpty()) {
            products = productRepository.findAllById(dto.getProductIds());
            if (products.size() != dto.getProductIds().size()) {
                throw new RuntimeException("One or more Product IDs are invalid!");
            }
        }

        List<Supplier> suppliers = null;
        if (dto.getSupplierIds() != null && !dto.getSupplierIds().isEmpty()) {
            suppliers = supplierRepository.findAllById(dto.getSupplierIds());
            if (suppliers.size() != dto.getSupplierIds().size()) {
                throw new RuntimeException("One or more Supplier IDs are invalid!");
            }
        }

        PurchaseRequisition pr = requisitionMapper.toEntity(dto, products, suppliers);
        pr.setApprovalStatus(PurchaseRequisitionStatus.PENDING);

        PurchaseRequisition savedPr = requisitionRepository.save(pr);

        // ==========================================
        //  Token Generation Log Matrix
        // ==========================================
        PurchaseRequisitionToken token = new PurchaseRequisitionToken();
        token.setToken(UUID.randomUUID().toString());
        token.setActive(true);
        token.setPurchaseRequisitionId(savedPr.getId());
        token.setRequestedBy(savedPr.getRequestedBy());
        token.setCurrency(savedPr.getCurrency());
        token.setQuantityRequired(savedPr.getQuantityRequired());
        token.setUrgencyLevel(savedPr.getUrgencyLevel());
        token.setRequiredByDate(savedPr.getRequiredByDate());
        token.setApprovalStatus(savedPr.getApprovalStatus());
        token.setApprovedBy(savedPr.getApprovedBy());
        token.setRemarks(savedPr.getRemarks());
        token.setPurchaseCreatedAt(savedPr.getCreatedAt());
        token.setPurchaseUpdatedAt(savedPr.getUpdatedAt());
        token.setTotalProducts(savedPr.getProducts() == null ? 0 : savedPr.getProducts().size());
        token.setProductNames(savedPr.getProductNames());

        if (savedPr.getSuppliers() != null && !savedPr.getSuppliers().isEmpty()) {
            token.setSupplierNames(savedPr.getSuppliers().stream()
                    .map(Supplier::getName)
                    .collect(Collectors.joining(", ")));
        }

        tokenRepository.save(token);


        try {
            // 1️ just system manager APPROVAL alert
            List<User> managers = userRepository.findByRole(Role.MANAGER);
            for (User manager : managers) {
                notificationService.send(
                        manager.getId().toString(),
                        "SHIPMENT",
                        "New Purchase Requisition #PRQ-" + savedPr.getId(),
                        "A new purchase requisition has been submitted and is pending approval."
                );
            }

            // 2 just requisition assain supplier inbox notification
            if (savedPr.getSuppliers() != null && !savedPr.getSuppliers().isEmpty()) {
                for (Supplier supplier : savedPr.getSuppliers()) {
                    if (supplier.getUser() != null && supplier.getUser().getId() != null) {
                        notificationService.send(
                                supplier.getUser().getId().toString(),
                                "SHIPMENT",
                                "New RFQ Invitation #PRQ-" + savedPr.getId(),
                                "You have been selected as a target vendor for a new procurement requirement. Please check your bidding board."
                        );
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("SCM Error: Failed to route isolated notifications: " + e.getMessage());
        }

        return requisitionMapper.convertTOResponseDTO(savedPr);
    }

    @Transactional
    @Override
    public PurchaseRequisitionResponseDTO approveRequisition(Long id) {
        PurchaseRequisition requisition = requisitionRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Purchase Requisition missing for ID: " + id));

        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long managerId = null;
        String managerEmail = "system@scm.com";

        if (principal instanceof User) {
            User currentManager = (User) principal;
            managerId = currentManager.getId();
            managerEmail = currentManager.getEmail();
        }

        else if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
            String email = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();

            User currentManager = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("Active corporate session missing in database index!"));

            managerId = currentManager.getId();
            managerEmail = currentManager.getEmail();
        }

        else {
            throw new RuntimeException("Unauthorized transaction: Active corporate session not found!");
        }

        requisition.setApprovalStatus(PurchaseRequisitionStatus.APPROVED);
        requisition.setApprovedBy(managerId);

        PurchaseRequisition savedRequisition = requisitionRepository.save(requisition);

        activityLogService.log(
                managerId.toString(),
                managerEmail,
                "APPROVE",
                "PURCHASE_REQUISITION",
                savedRequisition.getId().toString(),
                "Manager approved requisition for " + (savedRequisition.getSuppliers() != null ? savedRequisition.getSuppliers().size() : 0) + " suppliers.",
                "PENDING",
                "APPROVED",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        if (savedRequisition.getSuppliers() != null && !savedRequisition.getSuppliers().isEmpty()) {
            sendRequisitionEmailToSuppliers(savedRequisition);
        }

        return requisitionMapper.convertTOResponseDTO(savedRequisition);
    }

    @Transactional
    @Override
    public PurchaseRequisitionResponseDTO rejectOrCancelRequisition(Long id, String actionType) {
        PurchaseRequisition requisition = requisitionRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Purchase Requisition missing for ID: " + id));

        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long managerId = null;
        if (principal instanceof User) {
            managerId = ((User) principal).getId();
        }

        if ("REJECT".equalsIgnoreCase(actionType)) {
            requisition.setApprovalStatus(PurchaseRequisitionStatus.REJECTED);
        } else if ("CANCEL".equalsIgnoreCase(actionType)) {
            requisition.setApprovalStatus(PurchaseRequisitionStatus.CANCELLED);
        } else {
            throw new IllegalArgumentException("Invalid routing parameters for action status");
        }

        requisition.setApprovedBy(managerId);

        PurchaseRequisition savedRequisition = requisitionRepository.save(requisition);

        if (savedRequisition.getRequestedBy() != null) {
            userRepository.findById(savedRequisition.getRequestedBy())
                    .ifPresent(officer -> sendAlertEmailToProcurement(savedRequisition, officer));
        }

        return requisitionMapper.convertTOResponseDTO(savedRequisition);
    }

    @Override
    @Transactional
    public PurchaseRequisitionResponseDTO update(Long id, PurchaseRequisitionRequestDTO dto) {
        PurchaseRequisition pr = requisitionRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Purchase Requisition not found with ID: " + id));

        if (pr.getApprovalStatus() != PurchaseRequisitionStatus.PENDING) {
            throw new RuntimeException("Locked! Requisitions in " + pr.getApprovalStatus() + " state cannot be modified.");
        }

        List<Product> products = null;
        if (dto.getProductIds() != null && !dto.getProductIds().isEmpty()) {
            products = productRepository.findAllById(dto.getProductIds());
            if (products.size() != dto.getProductIds().size()) {
                throw new RuntimeException("One or more Product IDs are invalid!");
            }
        }

        List<Supplier> suppliers = null;
        if (dto.getSupplierIds() != null && !dto.getSupplierIds().isEmpty()) {
            suppliers = supplierRepository.findAllById(dto.getSupplierIds());
            if (suppliers.size() != dto.getSupplierIds().size()) {
                throw new RuntimeException("One or more Supplier IDs are invalid!");
            }
        }

        requisitionMapper.updateEntity(dto, pr, products, suppliers);
        PurchaseRequisition updated = requisitionRepository.save(pr);

        tokenRepository.findByPurchaseRequisitionId(updated.getId()).ifPresent(token -> {
            token.setRequestedBy(updated.getRequestedBy());
            token.setCurrency(updated.getCurrency());
            token.setQuantityRequired(updated.getQuantityRequired());
            token.setUrgencyLevel(updated.getUrgencyLevel());
            token.setRequiredByDate(updated.getRequiredByDate());
            token.setApprovalStatus(updated.getApprovalStatus());
            token.setApprovedBy(updated.getApprovedBy());
            token.setRemarks(updated.getRemarks());
            token.setPurchaseUpdatedAt(updated.getUpdatedAt());
            token.setTotalProducts(updated.getProducts() == null ? 0 : updated.getProducts().size());
            token.setProductNames(updated.getProductNames());

            if (updated.getSuppliers() != null && !updated.getSuppliers().isEmpty()) {
                token.setSupplierNames(updated.getSuppliers().stream()
                        .map(Supplier::getName)
                        .collect(Collectors.joining(", ")));
            }
            tokenRepository.save(token);
        });

        return requisitionMapper.convertTOResponseDTO(updated);
    }

    private void sendRequisitionEmailToSuppliers(PurchaseRequisition pr) {
        if (pr.getSuppliers() == null || pr.getSuppliers().isEmpty()) return;

        StringBuilder productRows = new StringBuilder();
        if (pr.getProducts() != null) {
            for (Product product : pr.getProducts()) {
                productRows.append("<tr>")
                        .append("<td style='padding:10px; border-bottom:1px solid #edf2f7;'>").append(product.getId()).append("</td>")
                        .append("<td style='padding:10px; border-bottom:1px solid #edf2f7; font-weight:bold;'>").append(product.getName()).append("</td>")
                        .append("</tr>");
            }
        }

        String urgency = (pr.getUrgencyLevel() != null) ? pr.getUrgencyLevel().name() : "NORMAL";
        String subject = "SCM RFQ [" + urgency + "]: Authorized Procurement Order Alert - ID #" + pr.getId();

        for (Supplier supplier : pr.getSuppliers()) {
            if (supplier.getEmail() == null || supplier.getEmail().isBlank()) continue;

            String mailContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #2D3748; background-color: #f7fafc; margin: 0; padding: 0; }
                    .container { max-width: 600px; margin: 20px auto; background-color: #ffffff; border: 1px solid #E2E8F0; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
                    .header { background-color: #2F855A; color: white; padding: 25px; text-align: center; }
                    .content { padding: 30px; }
                    .info-table { width: 100%%; margin-top: 15px; border-collapse: collapse; }
                    .info-table td { padding: 10px; border-bottom: 1px solid #edf2f7; font-size: 14px; }
                    .info-table td.label { font-weight: bold; color: #4A5568; width: 40%%; }
                    .product-table { width: 100%%; margin-top: 20px; border-collapse: collapse; text-align: left; }
                    .product-table th { background-color: #EDF2F7; padding: 10px; font-size: 14px; color: #2D3748; }
                    .remarks-box { background-color: #F7FAFC; border-left: 4px solid #2F855A; padding: 15px; margin-top: 15px; font-style: italic; }
                    .footer { background-color: #F7FAFC; padding: 15px; text-align: center; font-size: 12px; color: #718096; border-top: 1px solid #E2E8F0; }
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>
                        <h2 style='margin:0;'>SCM Approved Requisition</h2>
                        <span style='background:#FFF; color:#2F855A; padding:3px 10px; font-weight:bold; border-radius:12px; font-size:12px;'>STATUS: APPROVED</span>
                    </div>
                    <div class='content'>
                        <p>Dear <b>%s</b>,</p>
                        <p>A new purchase requisition has been officially audited and <b>APPROVED</b> by SCM Board Management. You have been authorized to review the requirement matrix:</p>
                        
                        <table class='info-table'>
                            <tr><td class='label'>Requisition Reference:</td><td><b>#%s</b></td></tr>
                            <tr><td class='label'>Required Quantity:</td><td><span style='color:#2F855A; font-weight:bold;'>%d Units</span></td></tr>
                            <tr><td class='label'>Target Timeline Date:</td><td><b>%s</b></td></tr>
                            <tr><td class='label'>Preferred Currency:</td><td><b>%s</b></td></tr>
                            <tr><td class='label'>Urgency Level:</td><td><span style='color:#C53030; font-weight:bold;'>%s</span></td></tr>
                        </table>

                        <h3 style='margin-top:25px; color:#2F855A; border-bottom:2px solid #EDF2F7; padding-bottom:5px;'>Requested Inventory Specifications:</h3>
                        <table class='product-table'>
                            <thead><tr><th style='width:30%%;'>Product ID</th><th>Product nomenclature</th></tr></thead>
                            <tbody>%s</tbody>
                        </table>

                        <h4 style='margin-bottom:5px; color:#4A5568;'>Sourcing Directives:</h4>
                        <div class='remarks-box'>"%s"</div>
                    </div>
                    <div class='footer'>&copy; 2026 SCM Logistics Operations Gateway.</div>
                </div>
            </body>
            </html>
            """.formatted(
                    supplier.getName(), pr.getId().toString(), pr.getQuantityRequired(),
                    pr.getRequiredByDate().toString(), pr.getCurrency(), pr.getUrgencyLevel().name(),
                    productRows.toString(), pr.getRemarks() != null ? pr.getRemarks() : "No additional specifications."
            );

            try {
                mailService.senderGeneralMail(supplier.getEmail(), subject, mailContent);
            } catch (Exception e) {
                System.err.println("Failed to route notice: " + supplier.getEmail());
            }
        }
    }

    private void sendAlertEmailToProcurement(PurchaseRequisition requisition, User procurementOfficer) {
        String officerEmail = procurementOfficer.getEmail();
        String currentStatus = requisition.getApprovalStatus().name();
        String subject = "⚠️ SCM Operations Alert: Requisition Status Locked - " + currentStatus;

        String mailContent = """
        <!DOCTYPE html><html><head><style>body{font-family:'Segoe UI',Arial,sans-serif;line-height:1.6;color:#2D3748;padding:20px}.container{max-width:600px;margin:0 auto;background:#fff;border:1px solid #E2E8F0;border-radius:8px;overflow:hidden}.header-alert{background-color:#C53030;color:#fff;padding:25px;text-align:center}.content{padding:30px}.alert-box{background-color:#FFF5F5;border-left:4px solid #C53030;padding:15px;margin:15px 0;font-weight:700;color:#9B2C2C}.footer{background-color:#F7FAFC;padding:15px;text-align:center;font-size:12px;color:#718096;border-top:1px solid #E2E8F0}</style></head>
        <body><div class='container'><div class='header-alert'><h2 style='margin:0;'>Requisition Tracking Node</h2></div><div class='content'><p>Dear SCM Procurement Node (<b>%s</b>),</p><p>Your generated purchase requisition profile has been locked with the following parameter matrix:</p><div class='alert-box'>Requisition ID: #%d<br>Evaluation State: %s</div><p>Please check your warehouse catalog guidelines before initiating any new pipeline requests.</p></div><div class='footer'>&copy; 2026 SCM Sourcing Engine.</div></div></body></html>
        """.formatted(procurementOfficer.getName(), requisition.getId(), currentStatus);

        try {
            mailService.senderGeneralMail(officerEmail, subject, mailContent);
        } catch (Exception e) {
            System.err.println("Back routing alert mail failed.");
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<PurchaseRequisitionResponseDTO> findAll() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        if (principal instanceof User currentUser) {
            if ("SUPPLIER".equalsIgnoreCase(currentUser.getRole().name())) {
                return requisitionRepository.findAllApprovedBySupplierUserId(currentUser.getId()).stream()
                        .map(requisitionMapper::convertTOResponseDTO)
                        .collect(Collectors.toList());
            }
        }

        else if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
            String email = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
            Optional<User> userOpt = userRepository.findByEmail(email);

            if (userOpt.isPresent() && "SUPPLIER".equalsIgnoreCase(userOpt.get().getRole().name())) {
                return requisitionRepository.findAllApprovedBySupplierUserId(userOpt.get().getId()).stream()
                        .map(requisitionMapper::convertTOResponseDTO)
                        .collect(Collectors.toList());
            }
        }

        // if user ADMIN, MANAGER or PROCUREMENT is officer, global return all requisition
        return requisitionRepository.findAllWithDetails().stream()
                .map(requisitionMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<PurchaseRequisitionResponseDTO> getById(Long id) {
        return requisitionRepository.findByIdWithDetails(id)
                .map(requisitionMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        throw new RuntimeException("Hard-Locked! Executed Procurement Requisitions cannot be deleted from matrix index!");
    }
}