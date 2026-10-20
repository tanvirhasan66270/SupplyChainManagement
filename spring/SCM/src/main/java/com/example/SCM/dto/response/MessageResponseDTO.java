package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class MessageResponseDTO {
    private Long id;
    private String senderId;
    private String senderName;
    private String subject;
    private String body;
    private String priority;
    private String status;
    private String createdAt;
}