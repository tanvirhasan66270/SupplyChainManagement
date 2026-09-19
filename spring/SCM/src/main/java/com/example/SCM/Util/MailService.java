package com.example.SCM.Util;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring6.SpringTemplateEngine;

import java.time.Year;

@Service
@RequiredArgsConstructor
public class MailService {

    private final JavaMailSender javaMailSender;
    private final SpringTemplateEngine templateEngine;

    @Value("${app.frontend-url}")
    private String frontendUrl;

    public void senderGeneralMail(String to, String subject, String body) throws MessagingException {
        MimeMessage message = javaMailSender.createMimeMessage();
        MimeMessageHelper messageHelper = new MimeMessageHelper(message, true, "UTF-8");
        messageHelper.setTo(to);
        messageHelper.setSubject(subject);
        messageHelper.setText(body, true);

        javaMailSender.send(message);
    }

    // Reset Password
    public void sendPasswordResetEmail(String to, String name, String token) throws MessagingException {
        String link = frontendUrl + "/reset-password?token=" + token;

        Context context = new Context();
        context.setVariable("name", name != null ? name : "User");
        context.setVariable("link", link);

        String htmlContent = templateEngine.process("email/password-reset", context);
        senderGeneralMail(to, "Reset your SCM portal password", htmlContent);
    }

    // Email Verification
    public void sendVerificationEmail(String to, String name, String token) throws MessagingException {
        String link = frontendUrl + "/api/auth/verify-email?token=" + token;

        Context context = new Context();
        context.setVariable("name", name != null ? name : "User");
        context.setVariable("link", link);

        String htmlContent = templateEngine.process("email/email-verification", context);
        senderGeneralMail(to, "Verify your SCM account", htmlContent);
    }

    // Customer Welcome Email
    public void sendCustomerWelcomeEmail(String name, String email, String phone, String role) {
        if (name == null || email == null || phone == null || role == null) return;

        String subject = "Welcome to SCM Enterprise! Your Account is Ready";

        Context context = new Context();
        context.setVariable("customerName", name);
        context.setVariable("userEmail", email);
        context.setVariable("customerPhone", phone);
        context.setVariable("userRole", role);
        context.setVariable("currentYear", Year.now().getValue());
        context.setVariable("loginUrl", frontendUrl + "/login");

        try {
            String htmlContent = templateEngine.process("email/welcome-email", context);
            senderGeneralMail(email, subject, htmlContent);
        } catch (Exception ignored) {
        }
    }
}