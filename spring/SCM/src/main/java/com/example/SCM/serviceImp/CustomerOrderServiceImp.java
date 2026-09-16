package com.example.SCM.serviceImp;

import com.example.SCM.Util.MailService;
import com.example.SCM.dto.mapper.CustomerOrderMapper;
import com.example.SCM.dto.mapper.OrderLineItemMapper;
import com.example.SCM.dto.request.CustomerOrderRequestDTO;
import com.example.SCM.dto.response.CustomerOrderResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.enumClass.CustomerOrderStatus;
import com.example.SCM.enumClass.PaymentMethod;
import com.example.SCM.enumClass.ServiceType;
import com.example.SCM.repository.*;
import com.example.SCM.service.CustomerOrderService;
import com.example.SCM.service.ActivityLogService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import java.time.LocalDate;
import java.time.Year;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerOrderServiceImp implements CustomerOrderService {

    private final CustomerOrderRepository orderRepository;
    private final CustomerOrderMapper orderMapper;
    private final OrderLineItemMapper lineItemMapper;
    private final MailService mailService;
    private final ActivityLogService activityLogService;
    private final HttpServletRequest request;
    private final CustomerRepository customerRepository;

    @Value("${image.upload.dir}")
    private String uploadDir;

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

    @Transactional
    @Override
    public CustomerOrderResponseDTO save(CustomerOrderRequestDTO dto, MultipartFile image) {
        Customer customerProfile = customerRepository.findById(dto.getCustomerId())
                .orElseThrow(() -> new RuntimeException("Target customer profile missing! ID: " + dto.getCustomerId()));

        User customerUser = customerProfile.getUser();
        if (customerUser == null) {
            throw new RuntimeException("Customer profile has no linked User account.");
        }

        CustomerOrder order = orderMapper.toEntity(dto, customerUser);
        order.executeCalculations();

        double inputPaid = dto.getCodAmount();
        if (inputPaid > order.getTotalAmount()) {
            throw new IllegalArgumentException("Error: Provided amount cannot be greater than Total Order Value (" + order.getTotalAmount() + " BDT)!");
        }

        if (image != null && !image.isEmpty()) {
            String uploadedFileName = uploadImage(image, order.getOrderNumber());
            order.setPaymentCheckImage(uploadedFileName);
        }

        CustomerOrder savedOrder = orderRepository.save(order);

        if (savedOrder.getPaymentMethod() == PaymentMethod.CASH) {
            sendOrderConfirmationEmail(savedOrder);
        } else {
            sendInitPaymentVerificationEmail(savedOrder, inputPaid);
        }

        //  ACTIVITY LOG: CREATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "CREATE",
                "CUSTOMER_ORDER",
                savedOrder.getId().toString(),
                "Customer Order created successfully. Order Number: " + savedOrder.getOrderNumber() + " for Customer: " + savedOrder.getCustomerName(),
                null,
                "{\"orderNumber\":\"" + savedOrder.getOrderNumber() + "\", \"totalAmount\":" + savedOrder.getTotalAmount() + ", \"paymentMethod\":\"" + savedOrder.getPaymentMethod() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return orderMapper.convertTOResponseDTO(savedOrder);
    }

    @Transactional
    @Override
    public void processFinalPaymentConfirmation(Long orderId, double amountPaid, String method) {
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order matrix record missing for ID: " + orderId));

        double oldPaid = Double.parseDouble(order.getPaidAmount() != null ? order.getPaidAmount() : "0");

        if (amountPaid > order.getTotalAmount()) {
            throw new IllegalArgumentException("Error: Confirmed payment amount exceeds grand total order limit.");
        }

        order.setPaymentMethod(PaymentMethod.valueOf(method.toUpperCase()));
        order.setPaidAmount(String.valueOf(amountPaid));
        order.executeCalculations();

        CustomerOrder updatedOrder = orderRepository.save(order);

        sendOrderConfirmationEmail(updatedOrder);

        //  ACTIVITY LOG: PAYMENT_CONFIRMATION
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE",
                "CUSTOMER_ORDER",
                updatedOrder.getId().toString(),
                "Payment confirmed for Order Number: " + updatedOrder.getOrderNumber() + " via " + method,
                "{\"paidAmount\":" + oldPaid + "}",
                "{\"paidAmount\":" + amountPaid + ", \"paymentMethod\":\"" + method + "\", \"paymentStatus\":\"" + updatedOrder.getPaymentStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );
    }

    @Transactional
    @Override
    public CustomerOrderResponseDTO update(Long id, CustomerOrderRequestDTO dto, MultipartFile image) {
        CustomerOrder order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Customer order row missing for ID: " + id));

        double oldTotal = order.getTotalAmount();

        if (dto.getDeliveryAddress() != null) order.setDeliveryAddress(dto.getDeliveryAddress());
        if (dto.getDeliveryPhone() != null) order.setDeliveryPhone(dto.getDeliveryPhone());
        if (dto.getRemarks() != null) order.setRemarks(dto.getRemarks());
        if (dto.getEstimatedDelivery() != null) order.setEstimatedDelivery(LocalDate.parse(dto.getEstimatedDelivery()));
        if (dto.getServiceType() != null) order.setServiceType(ServiceType.valueOf(dto.getServiceType().toUpperCase()));
        order.setCodAmount(dto.getCodAmount());

        if (image != null && !image.isEmpty()) {
            String uploadedFileName = uploadImage(image, order.getOrderNumber());
            order.setPaymentCheckImage(uploadedFileName);
        }

        if (dto.getItems() != null && !dto.getItems().isEmpty()) {
            order.getLineItems().clear();
            dto.getItems().forEach(itemDto -> {
                OrderLineItem item = lineItemMapper.toEntity(itemDto);
                if (item != null) order.addLineItem(item);
            });
        }
        order.executeCalculations();
        CustomerOrder updatedOrder = orderRepository.save(order);

        //  ACTIVITY LOG: UPDATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE",
                "CUSTOMER_ORDER",
                updatedOrder.getId().toString(),
                "Customer Order details updated for Order Number: " + updatedOrder.getOrderNumber(),
                "{\"totalAmount\":" + oldTotal + "}",
                "{\"totalAmount\":" + updatedOrder.getTotalAmount() + ", \"deliveryAddress\":\"" + updatedOrder.getDeliveryAddress() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return orderMapper.convertTOResponseDTO(updatedOrder);
    }

    @Transactional
    @Override
    public CustomerOrderResponseDTO updateOrderStatus(Long id, String status) {
        CustomerOrder order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Customer order row missing for ID: " + id));

        String oldStatus = order.getStatus() != null ? order.getStatus().name() : "N/A";

        try {
            CustomerOrderStatus newStatus = CustomerOrderStatus.valueOf(status.toUpperCase());
            order.setStatus(newStatus);

            if (newStatus == CustomerOrderStatus.DELIVERED) {
                // if paid full amount than Paid Amount update
                double total = order.getTotalAmount();
                order.setPaidAmount(String.valueOf(total));
                // executeCalculations() if call it automatic Paid, Due = 0 and PaymentStatus = PAID that
                order.executeCalculations();
            }
            else if (newStatus == CustomerOrderStatus.CANCELLED) {
                if (order.getRemarks() == null || order.getRemarks().isEmpty()) {
                    order.setRemarks("Order lifecycle cancelled by management node.");
                }
            }
            else if (newStatus == CustomerOrderStatus.RETURNED) {
                // for return
                order.setRemarks("Consignment returned back to logistics hub.");
            }

        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid lifecycle status value: " + status);
        }

        CustomerOrder updatedOrder = orderRepository.save(order);

        //  ACTIVITY LOG: STATUS_UPDATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE_STATUS",
                "CUSTOMER_ORDER",
                updatedOrder.getId().toString(),
                "Order status updated to " + updatedOrder.getStatus() + " for Order Number: " + updatedOrder.getOrderNumber(),
                "{\"status\":\"" + oldStatus + "\"}",
                "{\"status\":\"" + updatedOrder.getStatus() + "\", \"paymentStatus\":\"" + updatedOrder.getPaymentStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return orderMapper.convertTOResponseDTO(updatedOrder);
    }

    @Transactional(readOnly = true)
    public List<CustomerOrderResponseDTO> findAll() {
        return orderRepository.findAllOrdersWithDetails().stream().map(orderMapper::convertTOResponseDTO).collect(Collectors.toList());
    }

    @Override
    public List<CustomerOrderResponseDTO> findByCustomerUsername(String username) {
        // 1. রিপোজিটরি থেকে ইউজারের নাম দিয়ে অর্ডারগুলো কুয়েরি করে আনা
        List<CustomerOrder> orders = orderRepository.findByCustomerEmail(username);

        // 2. অর্ডার লিস্টকে DTO-তে রূপান্তর করে রিটার্ন করা
        return orders.stream()
                .map(orderMapper::convertTOResponseDTO) // আপনার প্রজেক্টের সঠিক ম্যাপার মেথড এখানে ব্যবহার করবেন
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<CustomerOrderResponseDTO> getById(Long id) {
        return orderRepository.findByIdWithDetails(id).map(orderMapper::convertTOResponseDTO);
    }

    @Transactional
    public void delete(Long id) {
        CustomerOrder order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Customer order row missing for ID: " + id));

        String orderNumber = order.getOrderNumber();

        orderRepository.delete(order);

        //  ACTIVITY LOG: DELETE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "DELETE",
                "CUSTOMER_ORDER",
                id.toString(),
                "Customer Order deleted for Order Number: " + orderNumber,
                "{\"orderNumber\":\"" + orderNumber + "\"}",
                null,
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );
    }

    @Transactional(readOnly = true)
    public Optional<CustomerOrderResponseDTO> trackOrder(String orderNumber) {
        return orderRepository.findByOrderNumberWithDetails(orderNumber).map(orderMapper::convertTOResponseDTO);
    }

    private void sendInitPaymentVerificationEmail(CustomerOrder order, double amountPaid) {
        if (order.getCustomerEmail() == null || order.getCustomerEmail().contains("no-email")) return;

        String subject = "Action Required: Verify Your Payment for Order #" + order.getOrderNumber();

        String targetVerificationUrl = "http://localhost:8085/api/customerOrders/verify-link?orderId="
                + order.getId() + "&amountPaid=" + amountPaid + "&method=" + order.getPaymentMethod().name();

        String mailContent = """
        <!DOCTYPE html>
        <html>
        <body style='font-family: Arial; line-height: 1.6; color: #333;'>
            <div style='max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px;'>
                <h3 style='color: #1A365D;'>Payment Initialization Verification</h3>
                <p>Dear <b>%s</b>,</p>
                <p>We received a payment request via <b>%s</b> for your order.</p>
                <table style='width: 100%%; margin: 15px 0; border-collapse: collapse;'>
                    <tr><td>Order Number:</td><td><b>%s</b></td></tr>
                    <tr><td>Initiated Amount:</td><td><b>%.2f %s</b></td></tr>
                    <tr><td>Grand Total Bill:</td><td><b>%.2f %s</b></td></tr>
                </table>
                <p>Please click the button below to authorize and confirm this transaction:</p>
                <div style='text-align: center; margin: 30px 0;'>
                    <a href='%s' style='background-color: #2B6CB0; color: white; padding: 12px 30px; text-decoration: none; font-weight: bold; border-radius: 5px; display: inline-block;'>Confirm My Payment</a>
                </div>
                <p style='font-size: 12px; color: #718096;'>If you did not initiate this transaction, please contact support immediately.</p>
            </div>
        </body>
        </html>
        """.formatted(order.getCustomerName(), order.getPaymentMethod().name(), order.getOrderNumber(),
                amountPaid, order.getCurrency(), order.getTotalAmount(), order.getCurrency(), targetVerificationUrl);

        try {
            mailService.senderGeneralMail(order.getCustomerEmail(), subject, mailContent);
        } catch (Exception e) {
            System.err.println("Init Mail Error: " + e.getMessage());
        }
    }

    private void sendOrderConfirmationEmail(CustomerOrder order) {
        if (order.getCustomerEmail() == null || order.getCustomerEmail().contains("no-email")) return;

        String subject = "Your SCM Order is Confirmed! Invoice #" + order.getOrderNumber();
        StringBuilder itemRows = new StringBuilder();

        if (order.getLineItems() != null) {
            for (OrderLineItem item : order.getLineItems()) {
                itemRows.append(String.format("""
                <tr>
                    <td><b>%s</b></td>
                    <td style='text-align: center;'>%d</td>
                    <td style='text-align: right;'>%s %.2f</td>
                </tr>
            """, item.getProduct().getName(), item.getQuantity(), order.getCurrency(), item.getLineTotal()));
            }
        }

        String mailText = """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #333333; background-color: #f4f6f9; margin: 0; padding: 0; }
            .container { max-width: 600px; margin: 30px auto; padding: 0; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
            .header { background-color: #2E7D32; color: white; padding: 30px; text-align: center; }
            .header h2 { margin: 0; font-size: 26px; font-weight: 600; }
            .content { padding: 30px; }
            .tracking-box { background-color: #E8F5E9; border-left: 5px solid #2E7D32; padding: 15px; margin: 20px 0; border-radius: 4px; }
            .tracking-code { font-family: 'Courier New', Courier, monospace; font-size: 18px; font-weight: bold; color: #1B5E20; letter-spacing: 1px; }
            .invoice-table { width: 100%%; border-collapse: collapse; margin: 20px 0; }
            .invoice-table th { background-color: #f8fafc; padding: 10px; border-bottom: 2px solid #e2e8f0; text-align: left; font-size: 13px; color: #64748b; }
            .invoice-table td { padding: 12px 10px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
            .total-row { font-weight: bold; color: #2E7D32; font-size: 16px; background-color: #f8fafc; }
            .btn-container { text-align: center; margin: 30px 0; }
            .btn { background-color: #2E7D32; color: white !important; padding: 12px 35px; text-decoration: none; font-weight: bold; border-radius: 6px; display: inline-block; }
            .footer { font-size: 12px; color: #64748b; background-color: #f8fafc; padding: 15px; text-align: center; border-top: 1px solid #e2e8f0; }
        </style>
    </head>
    <body>
        <div class='container'>
            <div class='header'>
                <h2>Order Confirmed Successfully</h2>
            </div>
            <div class='content'>
                <p>Dear <b>%s</b>,</p>
                <p>Your purchase order has been logged into our logistics cluster node.</p>
                <p>Payment Method: <b>%s</b> | Payment Status: <span style='color:blue;'><b>%s</b></span></p>
                
                <div class='tracking-box'>
                    <p style='margin: 0 0 5px 0; font-size: 13px; color: #555;'>YOUR UNIQUE LIVE TRACKING CODE:</p>
                    <span class='tracking-code'>%s</span>
                </div>

                <table class='invoice-table'>
                    <thead><tr><th>Product Name</th><th style='text-align:center;'>Qty</th><th style='text-align:right;'>Total</th></tr></thead>
                    <tbody>
                        %s
                        <tr><td colspan='2' style='text-align:right; color:#64748b;'>Subtotal:</td><td style='text-align:right;'>%s %.2f</td></tr>
                        <tr><td colspan='2' style='text-align:right; color:#64748b;'>Delivery Charge:</td><td style='text-align:right;'>%s %.2f</td></tr>
                        <tr class='total-row'><td colspan='2' style='text-align:right;'>Net Aggregate:</td><td style='text-align:right;'>%s %.2f</td></tr>
                        <tr><td colspan='2' style='text-align:right; color:red;'>Due Amount:</td><td style='text-align:right; color:red;'>%s %s</td></tr>
                    </tbody>
                </table>
                
                <p><b>Shipping Target:</b> %s (Phone: %s)</p>
                
                <div class='btn-container'>
                    <a href='http://localhost:4200/track-order?code=%s' class='btn'>Track Package Live</a>
                </div>
            </div>
            <div class='footer'>&copy; %d SCM Global Logistics Network. All rights reserved.</div>
        </div>
    </body>
    </html>
    """.formatted(
                order.getCustomerName(),
                order.getPaymentMethod().name(),
                order.getPaymentStatus().name(),
                order.getOrderNumber(),
                itemRows.toString(),
                order.getCurrency(), order.getItemSubtotal(),
                order.getCurrency(), order.getDeliveryCharge(),
                order.getCurrency(), order.getTotalAmount(),
                order.getCurrency(), order.getDueAmount(),
                order.getDeliveryAddress(), order.getDeliveryPhone(),
                order.getOrderNumber(),
                Year.now().getValue()
        );

        try {
            mailService.senderGeneralMail(order.getCustomerEmail(), subject, mailText);
        } catch (Exception e) {
            System.err.println("Final Mail Error: " + e.getMessage());
        }
    }

    private String uploadImage(MultipartFile file, String orderNumber) {
        try {
            Path path = Paths.get(uploadDir, "customer_orders");

            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = (orderNumber != null ? orderNumber : "order")
                    .trim()
                    .replaceAll("[\\\\/:*?\"<>|]", "_")
                    .replaceAll("\\s+", "_");
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;

        } catch (Exception e) {
            throw new RuntimeException("Order payment check image upload failed: " + e.getMessage());
        }
    }
}