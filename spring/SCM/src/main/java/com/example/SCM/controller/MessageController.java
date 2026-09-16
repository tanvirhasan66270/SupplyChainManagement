package com.example.SCM.controller;

import com.example.SCM.dto.request.MessageRequestDTO;
import com.example.SCM.dto.response.MessageResponseDTO;
import com.example.SCM.entity.User;
import com.example.SCM.serviceImp.MessageServiceImp;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import com.example.SCM.dto.response.ChatContactDTO;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageServiceImp service;

    @PostMapping
    public ResponseEntity<List<MessageResponseDTO>> composeMessage(
            @RequestBody MessageRequestDTO dto,
            @AuthenticationPrincipal User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId) {

        String finalUserId = resolveUserId(currentUser, backupUserId);
        if (finalUserId == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.sendMessage(dto, currentUser));
    }

    @GetMapping("/inbox")
    public ResponseEntity<List<MessageResponseDTO>> getInbox(
            @AuthenticationPrincipal User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId) {

        String finalUserId = resolveUserId(currentUser, backupUserId);
        if (finalUserId == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.getInbox(finalUserId));
    }

    @GetMapping("/chatlist")
    public ResponseEntity<List<ChatContactDTO>> getChatlist(
            @AuthenticationPrincipal User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId) {

        String finalUserId = resolveUserId(currentUser, backupUserId);
        if (finalUserId == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.getChatlist(finalUserId));
    }

    @GetMapping("/history")
    public ResponseEntity<List<MessageResponseDTO>> getChatHistory(
            @RequestParam String contactId,
            @AuthenticationPrincipal User currentUser,
            @RequestHeader(value = "X-User-Id", required = false) String backupUserId) {

        String finalUserId = resolveUserId(currentUser, backupUserId);
        if (finalUserId == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.getChatHistory(finalUserId, contactId));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> toggleReadStatus(@PathVariable Long id) {
        service.markAsRead(id);
        return ResponseEntity.ok().build();
    }

    private String resolveUserId(User currentUser, String backupUserId) {
        if (currentUser != null && currentUser.getId() != null) {
            return currentUser.getId().toString();
        }
        if (backupUserId != null && !backupUserId.trim().isEmpty() && !"null".equalsIgnoreCase(backupUserId)) {
            return backupUserId;
        }
        return null;
    }
}
