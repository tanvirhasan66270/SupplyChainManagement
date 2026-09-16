package com.example.SCM.Util;

import com.example.SCM.entity.Customer;
import com.example.SCM.entity.User;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MailService {

    private final JavaMailSender javaMailSender;

    @Value("${app.frontend-url}")
    private String frontendUrl;



    public void  senderGeneralMail(String to , String subject, String body) throws MessagingException {

        MimeMessage message=javaMailSender.createMimeMessage();
        MimeMessageHelper messageHelper=new MimeMessageHelper(message,true);
        messageHelper.setTo(to);
        messageHelper.setSubject(subject);
        messageHelper.setText(body,true);

        javaMailSender.send(message);


    }

    //Reset Password
    public void sendPasswordResetEmail(String to, String name, String token) throws MessagingException {

        String link = frontendUrl + "/reset-password?token=" + token;

        String body = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body style="margin:0; padding:0; background-color:#f8fafc; font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; -webkit-font-smoothing:antialiased;">
                
                <table width="100%%" cellpadding="0" cellspacing="0" style="background-color:#f8fafc; padding:50px 0;">
                    <tr>
                        <td align="center">
                            
                            <table width="550" cellpadding="0" cellspacing="0" style="background:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.05); border:1px solid #e2e8f0;">
                                
                                <tr>
                                    <td height="6" style="background:linear-gradient(90deg, #ef4444, #dc2626, #991b1b);"></td>
                                </tr>

                                <tr>
                                    <td align="left" style="padding:35px 40px 20px 40px;">
                                        <table width="100%%" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td>
                                                    <span style="font-size:24px; font-weight:800; color:#1e3a8a; letter-spacing:-0.5px;">SCM<span style="color:#2563eb;">Enterprise</span></span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr>
                                    <td style="padding:0 40px 40px 40px;">
                                        <h2 style="margin:0 0 16px 0; color:#0f172a; font-size:22px; font-weight:700; letter-spacing:-0.3px;">
                                            Password Reset Request
                                        </h2>
                                        
                                        <p style="font-size:15px; line-height:1.6; color:#475569; margin:0 0 24px 0;">
                                            Hello %s, we received an administrative request to reset the account credentials associated with your SCM portal gateway. If you generated this transaction, please initialize your security updates using the secure link below:
                                        </p>

                                        <table width="100%%" cellpadding="0" cellspacing="0" style="margin:30px 0;">
                                            <tr>
                                                <td align="center">
                                                    <a href="%s" style="display:inline-block; background-color:#ef4444; color:#ffffff; text-decoration:none; padding:14px 40px; border-radius:10px; font-size:15px; font-weight:600; box-shadow:0 4px 14px 0 rgba(239,68,68,0.35); transition:background 0.2s ease;">
                                                        Reset Secure Password
                                                    </a>
                                                </td>
                                            </tr>
                                        </table>

                                        <div style="background-color:#fff1f2; border-radius:12px; padding:16px 20px; border-left:4px solid #ef4444; margin-bottom:24px;">
                                            <p style="margin:0; font-size:13px; line-height:1.5; color:#991b1b;">
                                                <strong>TTL Expiration Alert:</strong> This security token handshake is temporary and expires automatically in <strong>15 minutes</strong>. If you did not initialize this request, you can safely disregard this message—your active credentials remain untouched.
                                            </p>
                                        </div>

                                        <p style="margin:0; font-size:14px; color:#475569;">
                                            Best regards,<br>
                                            <span style="font-weight:600; color:#1e3a8a;">SCM Cyber Security Infrastructure</span>
                                        </p>
                                    </td>
                                </tr>

                                <tr>
                                    <td align="center" style="background-color:#f8fafc; padding:30px 40px; border-top:1px solid #f1f5f9;">
                                        <p style="margin:0 0 6px 0; color:#94a3b8; font-size:12px; font-weight:500; letter-spacing:0.5px; text-transform:uppercase;">
                                            SCM Security Operations Control Center
                                        </p>
                                        <p style="margin:0; color:#94a3b8; font-size:12px;">
                                            © 2026 SCM Global Logistics Network. All rights reserved.
                                        </p>
                                    </td>
                                </tr>

                            </table>
                            
                        </td>
                    </tr>
                </table>
                
            </body>
            </html>
            """.formatted(name, link);

        senderGeneralMail(to, "Reset your SCM portal password", body);
    }



    //Email Verification
    public void sendVerificationEmail(String to, String name, String token) throws MessagingException {

        String link = frontendUrl + "/api/auth/verify-email?token=" + token;

        String body = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body style="margin:0; padding:0; background-color:#f8fafc; font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; -webkit-font-smoothing:antialiased;">
                
                <table width="100%%" cellpadding="0" cellspacing="0" style="background-color:#f8fafc; padding:50px 0;">
                    <tr>
                        <td align="center">
                            
                            <table width="550" cellpadding="0" cellspacing="0" style="background:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.05); border:1px solid #e2e8f0;">
                                
                                <tr>
                                    <td height="6" style="background:linear-gradient(90deg, #3b82f6, #1d4ed8, #1e3a8a);"></td>
                                </tr>

                                <tr>
                                    <td align="left" style="padding:35px 40px 20px 40px;">
                                        <table width="100%%" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td>
                                                    <span style="font-size:24px; font-weight:800; color:#1e3a8a; letter-spacing:-0.5px;">SCM<span style="color:#2563eb;">Enterprise</span></span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr>
                                    <td style="padding:0 40px 40px 40px;">
                                        <h2 style="margin:0 0 16px 0; color:#0f172a; font-size:22px; font-weight:700; letter-spacing:-0.3px;">
                                            Welcome onboard, %s!
                                        </h2>
                                        
                                        <p style="font-size:15px; line-height:1.6; color:#475569; margin:0 0 24px 0;">
                                            Thank you for creating an account with SCM Enterprise—your central node for fast, secure, and reliable supply chain logistics management. To initialize your dashboard and activate your administrative access, please verify your endpoint email.
                                        </p>

                                        <table width="100%%" cellpadding="0" cellspacing="0" style="margin:30px 0;">
                                            <tr>
                                                <td align="center">
                                                    <a href="%s" style="display:inline-block; background-color:#2563eb; color:#ffffff; text-decoration:none; padding:14px 40px; border-radius:10px; font-size:15px; font-weight:600; box-shadow:0 4px 14px 0 rgba(37,99,235,0.3); transition:background 0.2s ease;">
                                                        Activate & Verify Account
                                                    </a>
                                                </td>
                                            </tr>
                                        </table>

                                        <div style="background-color:#f1f5f9; border-radius:12px; padding:16px 20px; border-left:4px solid #3b82f6; margin-bottom:24px;">
                                            <p style="margin:0; font-size:13px; line-height:1.5; color:#64748b;">
                                                <strong>TTL Expiration Notice:</strong> This authorization token is secure and will automatically expire in <strong>1 hour</strong>. If this initialization request wasn't triggered by you, this node handshake can be safely ignored.
                                            </p>
                                        </div>

                                        <p style="margin:0; font-size:14px; color:#475569;">
                                            Best regards,<br>
                                            <span style="font-weight:600; color:#1e3a8a;">SCM Global Logistics Team</span>
                                        </p>
                                    </td>
                                </tr>

                                <tr>
                                    <td align="center" style="background-color:#f8fafc; padding:30px 40px; border-top:1px solid #f1f5f9;">
                                        <p style="margin:0 0 6px 0; color:#94a3b8; font-size:12px; font-weight:500; letter-spacing:0.5px; text-transform:uppercase;">
                                            SCM Corporate Cluster Terminal
                                        </p>
                                        <p style="margin:0; color:#94a3b8; font-size:12px;">
                                            © 2026 SCM Global Logistics Network. All rights reserved.
                                        </p>
                                    </td>
                                </tr>

                            </table>
                            
                        </td>
                    </tr>
                </table>
                
            </body>
            </html>
            """.formatted(name, link);

        senderGeneralMail(to, "Verify your SCM account", body);
    }



    public void sendCustomerWelcomeEmail(String name, String email, String phone, String role) {
        if (name == null || email == null || phone == null || role == null) return;


        String subject = "Welcome to SCM Enterprise! Your Account is Ready ";

        String mailText = """
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body { font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #333333; background-color: #f4f6f9; margin: 0; padding: 0; }
                        .container { max-width: 600px; margin: 30px auto; padding: 0; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
                        .header { background-color: #2E7D32; color: white; padding: 35px 25px; text-align: center; }
                        .header h1 { margin: 0; font-size: 28px; font-weight: 600; }
                        .header p { margin: 5px 0 0 0; opacity: 0.9; font-size: 15px; }
                        .content { padding: 30px; }
                        .welcome-box { background-color: #E8F5E9; border-left: 5px solid #2E7D32; padding: 18px; margin: 20px 0; border-radius: 4px; }
                        .profile-details { width: 100%; border-collapse: collapse; margin: 20px 0; }
                        .profile-details td { padding: 10px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
                        .profile-details td.label { font-weight: bold; color: #64748b; width: 30%; }
                        .btn-container { text-align: center; margin: 35px 0; }
                        .btn { background-color: #2E7D32; color: white !important; padding: 12px 35px; text-decoration: none; font-weight: bold; border-radius: 6px; display: inline-block; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
                        .footer { font-size: 0.85em; color: #64748b; padding: 20px; background-color: #f8fafc; text-align: center; border-top: 1px solid #e2e8f0; }
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>Congratulations {{customerName}}!</h1>
                            <p>Your SCM Portal Account is Successfully Activated</p>
                        </div>
                        <div class='content'>
                            <p>Dear <b>{{customerName}}</b>,</p>
                            <p>A warm welcome to <b>SCM Enterprise Cluster</b>! We are absolutely thrilled to have you onboard as a premium partner in our digital global logistics ecosystem.</p>
                
                            <div class='welcome-box'>
                                <p style='margin: 0; font-size: 15px; color: #1B5E20; font-weight: bold;'>Your account onboarding is complete.</p>
                                <p style='margin: 5px 0 0 0; font-size: 13px; color: #475569;'>You can now log into your console node to dispatch customer purchase orders, manage real-time shipments, and monitor your unique delivery lifecycle tracks.</p>
                            </div>
                
                            <p><b>Your Registered SCM Network Credentials:</b></p>
                            <table class='profile-details'>
                                <tr>
                                    <td class='label'>Authorized Name:</td>
                                    <td>{{customerName}}</td>
                                </tr>
                                <tr>
                                    <td class='label'>Primary Email/User:</td>
                                    <td>{{userEmail}}</td>
                                </tr>
                                <tr>
                                    <td class='label'>Contact Phone:</td>
                                    <td>{{customerPhone}}</td>
                                </tr>
                                <tr>
                                    <td class='label'>Registered Node Role:</td>
                                    <td><span style='background-color:#E2E8F0; padding:3px 8px; border-radius:4px; font-size:12px; font-weight:bold;'>{{userRole}}</span></td>
                                </tr>
                            </table>
                
                            <div class='btn-container'>
                                <a href='http://localhost:4200/login' class='btn'>Log Into Your Client Dashboard</a>
                            </div>
                
                            <p>If you have any questions or require administrative assistance setting up your procurement matrix, our central network support desk is here for you 24/7.</p>
                            <p>Best regards,<br><b>SCM Enterprise Administration Team</b></p>
                        </div>
                        <div class='footer'>
                            &copy; {{currentYear}} SCM Global Logistics Network Cluster. All rights reserved.
                        </div>
                    </div>
                </body>
                </html>
                """;

        mailText = mailText
                .replace("{{customerName}}", name.isEmpty() ? "" : name)
                .replace("{{userEmail}}", email)
                .replace("{{customerPhone}}", phone.isEmpty() ? "" : phone)
                .replace("{{userRole}}", role.isEmpty() ? "" : role)
                .replace("{{currentYear}}", String.valueOf(java.time.Year.now().getValue()));

        try {
            senderGeneralMail(email, subject, mailText);
            System.out.println("Customer Registration Congratulation Email successfully dispatched to node: " + email);
        } catch (Exception e) {
            System.err.println("Registration Onboarding Email failed to execute: " + e.getMessage());
        }
    }









}