package com.example.SCM.auth;

import com.example.SCM.Util.MailService;
import com.example.SCM.dto.request.ForgotPasswordRequestDTO;
import com.example.SCM.dto.request.LoginRequestDTO;
import com.example.SCM.dto.request.ResetPasswordRequestDTO;
import com.example.SCM.dto.response.LoginResponseDTO;
import com.example.SCM.entity.Customer;
import com.example.SCM.entity.Logistics_Officer;
import com.example.SCM.entity.Manager;
import com.example.SCM.entity.Procurement;
import com.example.SCM.entity.QCInspector;
import com.example.SCM.entity.SalesOfficer;
import com.example.SCM.entity.Supplier;
import com.example.SCM.entity.User;
import com.example.SCM.repository.CustomerRepository;
import com.example.SCM.repository.LogisticsOfficerRepository;
import com.example.SCM.repository.ManagerRepository;
import com.example.SCM.repository.ProcurementRepository;
import com.example.SCM.repository.QCInspectorRepository;
import com.example.SCM.repository.SalesOfficerRepository;
import com.example.SCM.repository.SupplierRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.security.JwtUtil;
import com.example.SCM.service.CustomerService;
import com.example.SCM.service.LogisticsOfficerService;
import com.example.SCM.service.ManagerService;
import com.example.SCM.service.ProcurementService;
import com.example.SCM.service.QCInspectorService;
import com.example.SCM.service.SalesOfficerService;
import com.example.SCM.service.SupplierService;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    private final MailService mailService;
//    private final QCInspectorRepository qCInspectorRepository;




    public LoginResponseDTO login(LoginRequestDTO dto) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            dto.getEmail(),
                            dto.getPassword()
                    )
            );
        } catch (Exception e) {
            System.out.println("Exception Class = " + e.getClass().getName());
            System.out.println("Exception Message = " + e.getMessage());
            e.printStackTrace();
            throw e;
        }

        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String token = jwtUtil.generateToken(
                user.getEmail(),
                user.getRole().name()
        );

        LoginResponseDTO response = new LoginResponseDTO();
        response.setToken(token);
        response.setTokenType("Bearer");
        response.setUserId(user.getId());
        response.setName(user.getName());
        response.setEmail(user.getEmail());
        response.setPhone(user.getPhoneNumber());
        response.setRole(user.getRole().name());

        return response;
    }

    public void sendVerificationEmail(String mail) {
        User user = userRepository.findByEmail(mail)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + mail));

        if (user.isActive()) {
            throw new RuntimeException("Account is already verified");
        }

        String token = jwtUtil.generateVerificationToken(user.getEmail());

        try {
            mailService.sendVerificationEmail(user.getEmail(), user.getName(), token);
        } catch (MessagingException e) {
            throw new RuntimeException("Failed to send verification email: " + e.getMessage());
        }
    }

    @Transactional
    public void verifyEmail(String token) {

        if (!jwtUtil.isValidForPurpose(token, "EMAIL_VERIFICATION")) {
            throw new RuntimeException("Invalid or expired verification link");
        }




        String email = jwtUtil.extractEmail(token);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

//        QCInspector inspector = qCInspectorRepository.findByUserId(user.getId())
//                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.isActive()) {
            throw new RuntimeException("Account is already verified.Please log in to your dashboard.");
        }

        user.setActive(true);

//        inspector.setActive(true);
//
//        qCInspectorRepository.save(inspector);

        userRepository.save(user);

        //com.example.SCM.role.Role userRole = user.getRole();

        mailService.sendCustomerWelcomeEmail(user.getName(), user.getEmail(), user.getPhoneNumber(), user.getRole().name());



    }

    @Transactional
    public void forgotPassword(ForgotPasswordRequestDTO dto) {
        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new RuntimeException("No account found with email: " + dto.getEmail()));

        String token = jwtUtil.generateResetToken(user.getEmail());

        try {
            mailService.sendPasswordResetEmail(user.getEmail(), user.getName(), token);
        } catch (MessagingException e) {
            throw new RuntimeException("Failed to send reset email: " + e.getMessage());
        }
    }

    @Transactional
    public void resetPassword(ResetPasswordRequestDTO dto) {
        if (!jwtUtil.isValidForPurpose(dto.getToken(), "PASSWORD_RESET")) {
            throw new RuntimeException("Invalid or expired reset link");
        }

        if (dto.getNewPassword() == null || dto.getNewPassword().length() < 6 || dto.getNewPassword().length() > 20) {
            throw new RuntimeException("Password must be between 6 and 20 characters");
        }

        String email = jwtUtil.extractEmail(dto.getToken());

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        userRepository.save(user);
    }

    @Transactional
    public void changePassword(String userId, com.example.SCM.dto.request.ChangePasswordRequestDTO dto) {
        User user = userRepository.findById(Long.parseLong(userId))
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(dto.getCurrentPassword(), user.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }

        if (dto.getNewPassword() == null || dto.getNewPassword().length() < 6 || dto.getNewPassword().length() > 20) {
            throw new RuntimeException("Password must be between 6 and 20 characters");
        }

        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        userRepository.save(user);
    }
}