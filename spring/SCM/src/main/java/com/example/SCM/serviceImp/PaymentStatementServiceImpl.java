package com.example.SCM.serviceImp;



import com.example.SCM.dto.mapper.PaymentStatementMapper;
import com.example.SCM.dto.request.PaymentStatementRequestDTO;
import com.example.SCM.dto.response.PaymentStatementResponseDTO;
import com.example.SCM.entity.CustomerOrder;
import com.example.SCM.entity.PaymentStatement;
import com.example.SCM.enumClass.PaymentIssueStatus;

import com.example.SCM.repository.CustomerOrderRepository;
import com.example.SCM.repository.PaymentStatementRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.service.PaymentStatementService;
import com.example.SCM.service.NotificationService;
import com.example.SCM.entity.User;
import com.example.SCM.role.Role;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PaymentStatementServiceImpl implements PaymentStatementService {

    @Autowired
    private PaymentStatementRepository paymentStatementRepository;

    @Autowired
    private CustomerOrderRepository customerOrderRepository;

    @Autowired
    private PaymentStatementMapper paymentStatementMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NotificationService notificationService;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Override
    @Transactional
    public PaymentStatementResponseDTO addPayment(PaymentStatementRequestDTO requestDTO, MultipartFile image) {
        CustomerOrder order = customerOrderRepository.findById(requestDTO.getCustomerOrderId())
                .orElseThrow(() -> new EntityNotFoundException("Customer order not found with id: " + requestDTO.getCustomerOrderId()));

        if (requestDTO.getPaymentMethod() == null) {
            throw new IllegalArgumentException("Payment method must be selected.");
        }
        if (image == null || image.isEmpty()) {
            throw new IllegalArgumentException("Payment check image is required.");
        }

        PaymentStatement payment = new PaymentStatement();
        payment.setPaidAmount(requestDTO.getPaidAmount());
        payment.setPaymentMethod(requestDTO.getPaymentMethod());
        payment.setTransactionId(requestDTO.getTransactionId());
        payment.setCustomerAccountNumber(requestDTO.getCustomerAccountNumber());
        
        String uploadedFileName = uploadImage(image, order.getOrderNumber());
        payment.setPaymentCheckImage(uploadedFileName);

        if (requestDTO.getIssueStatus() != null) {
            payment.setIssueStatus(requestDTO.getIssueStatus());
        }

        order.addPaymentStatement(payment);
        customerOrderRepository.save(order);

        try {
            notificationService.send(
                    "COMMERCIAL_OFFICER",
                    "PAYMENT",
                    "New Payment Added: Order #" + order.getOrderNumber(),
                    "A new payment of " + requestDTO.getPaidAmount() + " has been added for Customer Order: " + order.getOrderNumber()
            );

            List<User> officers = userRepository.findByRole(Role.COMMERCIAL_OFFICER);
            for (User officer : officers) {
                if (officer.getId() != null) {
                    notificationService.send(
                            officer.getId().toString(),
                            "PAYMENT",
                            "New Payment Added: Order #" + order.getOrderNumber(),
                            "A new payment of " + requestDTO.getPaidAmount() + " has been added for Customer Order: " + order.getOrderNumber()
                    );
                }
            }
        } catch (Exception e) {
            System.err.println("Error sending payment notification: " + e.getMessage());
        }

        return paymentStatementMapper.toResponseDTO(payment);
    }

    @Override
    @Transactional
    public PaymentStatementResponseDTO updatePayment(Long id, PaymentStatementRequestDTO requestDTO, MultipartFile image) {
        PaymentStatement payment = paymentStatementRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Payment statement not found with id: " + id));

        if (requestDTO.getPaymentMethod() == null) {
            throw new IllegalArgumentException("Payment method must be selected.");
        }

        payment.setPaidAmount(requestDTO.getPaidAmount());
        payment.setPaymentMethod(requestDTO.getPaymentMethod());
        payment.setTransactionId(requestDTO.getTransactionId());
        payment.setCustomerAccountNumber(requestDTO.getCustomerAccountNumber());

        if (image != null && !image.isEmpty()) {
            String uploadedFileName = uploadImage(image, payment.getCustomerOrder().getOrderNumber());
            payment.setPaymentCheckImage(uploadedFileName);
        } else if (payment.getPaymentCheckImage() == null || payment.getPaymentCheckImage().isEmpty()) {
            throw new IllegalArgumentException("Payment check image is required.");
        }

        paymentStatementRepository.save(payment);

        CustomerOrder order = payment.getCustomerOrder();
        order.executeCalculations();
        customerOrderRepository.save(order);

        return paymentStatementMapper.toResponseDTO(payment);
    }

    @Override
    @Transactional
    public PaymentStatementResponseDTO updatePaymentStatus(Long paymentId, PaymentIssueStatus newStatus) {
        PaymentStatement payment = paymentStatementRepository.findById(paymentId)
                .orElseThrow(() -> new EntityNotFoundException("Payment statement not found with id: " + paymentId));

        payment.setIssueStatus(newStatus);
        paymentStatementRepository.save(payment);

        CustomerOrder order = payment.getCustomerOrder();
        order.executeCalculations();
        customerOrderRepository.save(order);

        return paymentStatementMapper.toResponseDTO(payment);
    }

    @Override
    public List<PaymentStatementResponseDTO> getPaymentsByOrderId(Long orderId) {
        List<PaymentStatement> payments = paymentStatementRepository.findByCustomerOrderId(orderId);
        return payments.stream()
                .map(paymentStatementMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<PaymentStatementResponseDTO> getPaymentsByOrderNumber(String orderNumber) {
        List<PaymentStatement> payments = paymentStatementRepository.findByCustomerOrderOrderNumber(orderNumber);
        return payments.stream()
                .map(paymentStatementMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<PaymentStatementResponseDTO> getPaymentsByStatus(PaymentIssueStatus status) {
        List<PaymentStatement> payments = paymentStatementRepository.findByIssueStatus(status);
        return payments.stream()
                .map(paymentStatementMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    public PaymentStatementResponseDTO getPaymentById(Long id) {
        PaymentStatement payment = paymentStatementRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Payment statement not found with id: " + id));
        return paymentStatementMapper.toResponseDTO(payment);
    }

    @Override
    @Transactional
    public void deletePayment(Long id) {
        PaymentStatement payment = paymentStatementRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Payment statement not found with id: " + id));

        CustomerOrder order = payment.getCustomerOrder();
        order.getPaymentStatements().remove(payment);
        paymentStatementRepository.delete(payment);

        order.executeCalculations();
        customerOrderRepository.save(order);
    }

    private String uploadImage(MultipartFile file, String orderNumber) {
        try {
            Path path = Paths.get(uploadDir, "payment");

            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = (orderNumber != null ? orderNumber : "payment")
                    .trim()
                    .replaceAll("[\\\\/:*?\"<>|]", "_")
                    .replaceAll("\\s+", "_");
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;

        } catch (Exception e) {
            throw new RuntimeException("Payment check image upload failed: " + e.getMessage());
        }
    }
}