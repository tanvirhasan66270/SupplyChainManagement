package com.example.SCM.auth;


import com.example.SCM.dto.request.ForgotPasswordRequestDTO;
import com.example.SCM.dto.request.LoginRequestDTO;
import com.example.SCM.dto.request.ResetPasswordRequestDTO;
import com.example.SCM.dto.response.LoginResponseDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;


    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@RequestBody LoginRequestDTO dto) {
        return ResponseEntity.ok(authService.login(dto));
    }

    @GetMapping("/verify-email")
    public ResponseEntity<String> verifyEmail(@RequestParam String token) {
        authService.verifyEmail(token);
        return ResponseEntity.ok("Email verified successfully. You can now log in.");
    }


    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestBody ForgotPasswordRequestDTO dto) {
        authService.forgotPassword(dto);
        return ResponseEntity.ok("Password reset link sent to " + dto.getEmail());
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequestDTO dto) {
        authService.resetPassword(dto);
        return ResponseEntity.ok("Password reset successful. You can now log in with your new password.");
    }

    @PostMapping("/change-password")
    public ResponseEntity<String> changePassword(
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.example.SCM.entity.User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId,
            @RequestBody com.example.SCM.dto.request.ChangePasswordRequestDTO dto) {
        
        String userId = null;
        if (currentUser != null && currentUser.getId() != null) {
            userId = currentUser.getId().toString();
            if (backupUserId != null && !backupUserId.isEmpty() && !"null".equalsIgnoreCase(backupUserId)) {
                if (!userId.equals(backupUserId)) {
                    return ResponseEntity.status(403).body("Error: You can only change your own password.");
                }
            }
        } else if (backupUserId != null && !backupUserId.isEmpty() && !"null".equalsIgnoreCase(backupUserId)) {
            userId = backupUserId;
        }
        
        if (userId == null) {
            return ResponseEntity.badRequest().body("User ID is missing");
        }
        
        authService.changePassword(userId, dto);
        return ResponseEntity.ok("Password changed successfully.");
    }
    //    @GetMapping("/verify-email")
//    public ResponseEntity<String> verifyEmail(@RequestParam String token) {
//        String result = customerService.verifyEmailToken(token);
//        return ResponseEntity.ok(result);
//    }





}
