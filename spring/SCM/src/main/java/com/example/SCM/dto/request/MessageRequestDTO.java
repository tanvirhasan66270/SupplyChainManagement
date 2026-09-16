package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class MessageRequestDTO {
    private String recipientId;
    private String subject;
    private String body;
    private String priority;
}