package com.example.SCM.serviceImp;

import com.example.SCM.Util.MailService;
import com.example.SCM.Util.TrakingCode.TrackingCodeGenerator;
import com.example.SCM.dto.mapper.InvoiceMapper;
import com.example.SCM.dto.request.InvoiceRequestDTO;
import com.example.SCM.dto.response.InvoiceResponseDTO;
import com.example.SCM.entity.CustomerOrder;
import com.example.SCM.entity.Invoice;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.enumClass.InvoiceStatus;
import com.example.SCM.repository.InvoiceRepository;
import com.example.SCM.repository.CustomerOrderRepository;
import com.example.SCM.service.ActivityLogService;
import com.example.SCM.service.InvoiceService;
import com.example.SCM.service.NotificationService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InvoiceServiceImp implements InvoiceService {

    private final InvoiceRepository repository;
    private final CustomerOrderRepository orderRepository;
    private final InvoiceMapper mapper;
    private final TrackingCodeGenerator codeGenerator;
    private final MailService mailService;

    // Activity Log & Request Context Dependencies
    private final ActivityLogService activityLogService;
    private final HttpServletRequest request;
    private final NotificationService notificationService;

    // Dynamically resolves current active user or system actor

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
    public InvoiceResponseDTO save(InvoiceRequestDTO dto) {
        Invoice invoice = mapper.toEntity(dto);

        invoice.setInvoiceNumber(codeGenerator.generateTrackingCode());

        CustomerOrder order = orderRepository.findByIdWithDetails(dto.getCustomerOrderId())
                .orElseThrow(() -> new RuntimeException("Customer Order linkage missing for verification ID: " + dto.getCustomerOrderId()));

        if (order.getCustomer() != null) {
            invoice.setIssuedToName(order.getCustomer().getName());
            invoice.setCustomerEmail(order.getCustomer().getEmail());
        } else {
            invoice.setIssuedToName("Walk-in Customer");
            invoice.setCustomerEmail("no-email@scmlogistics.com");
        }

        Invoice savedInvoice = repository.save(invoice);

        // Send notification to the customer
        try {
            if (order.getCustomer() != null && order.getCustomer().getId() != null) {
                String recipientId = order.getCustomer().getId().toString();
                String title = "New Invoice Generated: " + savedInvoice.getInvoiceNumber();
                String message = String.format(
                        "An invoice (#%s) has been generated for your order (#%d). Total Amount: %s %.2f.",
                        savedInvoice.getInvoiceNumber(),
                        order.getId(),
                        savedInvoice.getCurrency(),
                        savedInvoice.getTotalAmount()
                );
                notificationService.send(recipientId, "INVOICE", title, message);
            }
        } catch (Exception e) {
            System.err.println("Customer Invoice Notification Error: " + e.getMessage());
        }

        if (savedInvoice.getInvoiceStatus() == InvoiceStatus.ISSUED && !savedInvoice.getCustomerEmail().contains("no-email")) {
            sendInvoiceEmail(savedInvoice, savedInvoice.getCustomerEmail());
        }

        //  ACTIVITY LOG: CREATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "CREATE",
                "INVOICE",
                savedInvoice.getId().toString(),
                "New Invoice generated successfully. Invoice Number: " + savedInvoice.getInvoiceNumber() + " for Customer: " + savedInvoice.getIssuedToName(),
                null,
                "{\"totalAmount\":" + savedInvoice.getTotalAmount() + ", \"paymentStatus\":\"" + savedInvoice.getPaymentStatus() + "\", \"invoiceStatus\":\"" + savedInvoice.getInvoiceStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return mapper.toResponseDTO(savedInvoice);
    }

    @Override
    @Transactional
    public InvoiceResponseDTO update(Long id, InvoiceRequestDTO dto) {
        Invoice invoice = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Invoice dataset node not found at ID: " + id));

        double oldTotalAmount = invoice.getTotalAmount();
        String oldPaymentStatus = invoice.getPaymentStatus() != null ? invoice.getPaymentStatus().name() : "N/A";
        String oldInvoiceStatus = invoice.getInvoiceStatus() != null ? invoice.getInvoiceStatus().name() : "N/A";

        mapper.updateEntityFromDTO(dto, invoice);

        // customer repository method vereficasion
        CustomerOrder order = orderRepository.findByIdWithDetails(dto.getCustomerOrderId())
                .orElseThrow(() -> new RuntimeException("Customer Order node structural integrity broken."));

        if (order.getCustomer() != null) {
            invoice.setIssuedToName(order.getCustomer().getName());
            invoice.setCustomerEmail(order.getCustomer().getEmail());
        } else {
            invoice.setIssuedToName("Walk-in Customer");
            invoice.setCustomerEmail("no-email@scmlogistics.com");
        }

        Invoice updatedInvoice = repository.save(invoice);

        // if ISSUE realtime mail notification is treggred
        if (updatedInvoice.getInvoiceStatus() == InvoiceStatus.ISSUED && !updatedInvoice.getCustomerEmail().contains("no-email")) {
            sendInvoiceEmail(updatedInvoice, updatedInvoice.getCustomerEmail());
        }

        //  ACTIVITY LOG: UPDATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE",
                "INVOICE",
                updatedInvoice.getId().toString(),
                "Invoice financial metadata updated for Invoice Number: " + updatedInvoice.getInvoiceNumber(),
                "{\"totalAmount\":" + oldTotalAmount + ", \"paymentStatus\":\"" + oldPaymentStatus + "\", \"invoiceStatus\":\"" + oldInvoiceStatus + "\"}",
                "{\"totalAmount\":" + updatedInvoice.getTotalAmount() + ", \"paymentStatus\":\"" + updatedInvoice.getPaymentStatus() + "\", \"invoiceStatus\":\"" + updatedInvoice.getInvoiceStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return mapper.toResponseDTO(updatedInvoice);
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvoiceResponseDTO> findAll() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        boolean isCustomer = authentication != null && authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_CUSTOMER"));

        List<Invoice> invoices;
        if (isCustomer) {
            invoices = repository.findByCustomerEmail(authentication.getName());
        } else {
            invoices = repository.findAll();
        }

        return invoices.stream()
                .map(mapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<InvoiceResponseDTO> getById(Long id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        boolean isCustomer = authentication != null && authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_CUSTOMER"));

        Optional<Invoice> invoiceOpt = repository.findById(id);

        if (isCustomer && invoiceOpt.isPresent()) {
            String customerEmail = authentication.getName();
            if (!customerEmail.equals(invoiceOpt.get().getCustomerEmail())) {
                return Optional.empty();
            }
        }

        return invoiceOpt.map(mapper::toResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Invoice invoice = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target Invoice lifecycle instance missing in datastore layer ID: " + id));

        String invoiceNumber = invoice.getInvoiceNumber();
        double totalAmount = invoice.getTotalAmount();

        repository.delete(invoice);

        //  ACTIVITY LOG: DELETE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "DELETE",
                "INVOICE",
                id.toString(),
                "Invoice record purged permanently. Invoice Number was: " + invoiceNumber,
                "{\"invoiceNumber\":\"" + invoiceNumber + "\", \"totalAmount\":" + totalAmount + "}",
                null,
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );
    }

    private void sendInvoiceEmail(Invoice invoice, String customerEmail) {
        String subject = "SCM Official Invoice Bill - " + invoice.getInvoiceNumber();

        String mailText = """
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #333333; background-color: #f4f6f9; margin: 0; padding: 0; }
                    .invoice-box { max-width: 650px; margin: 25px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.08); border: 1px solid #e2e8f0; }
                    .header { background-color: #1A365D; color: white; padding: 30px; }
                    .header h2 { margin: 0; font-size: 26px; font-weight: 600; letter-spacing: 0.5px; }
                    .header p { margin: 5px 0 0 0; opacity: 0.8; font-size: 14px; }
                    .content { padding: 30px; }
                    .meta-table { width: 100%%; margin-bottom: 25px; border-collapse: collapse; }
                    .meta-table td { padding: 6px 0; font-size: 14px; }
                    .meta-title { font-weight: bold; color: #4A5568; width: 30%%; }
                    .financial-table { width: 100%%; border-collapse: collapse; margin-top: 15px; }
                    .financial-table th { background-color: #EDF2F7; color: #2D3748; text-align: left; padding: 12px; font-size: 14px; font-weight: 600; border-bottom: 2px solid #CBD5E0; }
                    .financial-table td { padding: 12px; font-size: 14px; border-bottom: 1px solid #E2E8F0; }
                    .total-row { font-weight: bold; background-color: #F7FAFC; color: #1A365D; }
                    .status-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; text-transform: uppercase; }
                    .status-paid { background-color: #C6F6D5; color: #22543D; }
                    .status-partial { background-color: #FEFCBF; color: #744210; }
                    .status-unpaid { background-color: #FED7D7; color: #742A2A; }
                    .footer { font-size: 12px; color: #718096; padding: 20px; background-color: #EDF2F7; text-align: center; border-top: 1px solid #E2E8F0; }
                    .notes-box { background-color: #FFFAF0; border-left: 4px solid #DD6B20; padding: 15px; margin-top: 20px; border-radius: 0 4px 4px 0; font-size: 13px; }
                </style>
            </head>
            <body>
                <div class='invoice-box'>
                    <div class='header'>
                        <h2>INVOICE BILL DETAILED</h2>
                        <p>Invoice No: <b>%s</b></p>
                    </div>
                    <div class='content'>
                        <p style='font-size: 16px; margin-top: 0;'>Dear <b>%s</b>,</p>
                        <p>Thank you for your business. Your commercial invoice has been issued officially. Please review the financial breakdown settlement summary below:</p>
                        
                        <table class='meta-table'>
                            <tr><td class='meta-title'>Order Reference</td><td>#%d</td></tr>
                            <tr><td class='meta-title'>Billing Currency</td><td><b>%s</b></td></tr>
                            <tr><td class='meta-title'>Delivery Address</td><td>%s</td></tr>
                            <tr><td class='meta-title'>Payment Status</td><td><span class='status-badge %s'>%s</span></td></tr>
                        </table>

                        <table class='financial-table'>
                            <thead>
                                <tr><th>Financial Component</th><th style='text-align: right;'>Amount</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>Item Subtotal</td><td style='text-align: right;'>%.2f</td></tr>
                                <tr><td>Tax Amount (Rate: %.2f)</td><td style='text-align: right;'>+ %.2f</td></tr>
                                <tr><td>Shipping & Logistics Fees</td><td style='text-align: right;'>+ %.2f</td></tr>
                                <tr><td>Discount Allowed (Percentage: %.1f%%)</td><td style='text-align: right; color: #E53E3E;'>- %.2f</td></tr>
                                <tr class='total-row'><td>Grand Total Amount</td><td style='text-align: right;'>%.2f</td></tr>
                                <tr><td style='color: #38A169;'>Total Paid Balance</td><td style='text-align: right; color: #38A169;'>%.2f</td></tr>
                                <tr style='font-weight: bold; color: #E53E3E;'><td>Total Due Balance</td><td style='text-align: right;'>%.2f</td></tr>
                            </tbody>
                        </table>

                        %s
                    </div>
                    <div class='footer'>
                        &copy; %d SCM Global Corporate Logistic Control. All rights reserved.<br>
                        This is an automated system-generated billing invoice ledger.
                    </div>
                </div>
            </body>
            </html>
            """.formatted(
                invoice.getInvoiceNumber(),
                invoice.getIssuedToName(),
                invoice.getCustomerOrderId(),
                invoice.getCurrency(),
                invoice.getDeliveryAddress(),
                invoice.getPaymentStatus().name().equals("PAID") ? "status-paid" :
                        invoice.getPaymentStatus().name().equals("PARTIALLY_PAID") ? "status-partial" : "status-unpaid",
                invoice.getPaymentStatus().name(),
                invoice.getSubtotal(),
                invoice.getTaxRate(),
                invoice.getTaxAmount(),
                invoice.getShippingFees(),
                invoice.getDiscountPercentage(),
                invoice.getDiscountAmount(),
                invoice.getTotalAmount(),
                invoice.getPaidAmount(),
                invoice.getDueAmount(),
                (invoice.getNotes() != null && !invoice.getNotes().isBlank()) ?
                        "<div class='notes-box'><b>Terms & Notes:</b> " + invoice.getNotes() + "</div>" : "",
                java.time.Year.now().getValue()
        );

        try {
            mailService.senderGeneralMail(customerEmail, subject, mailText);
        } catch (Exception e) {
            System.err.println("Invoice Notification Dispatch engine error: " + e.getMessage());
        }
    }
}