package com.example.SCM.exception;

import com.example.SCM.dto.response.ApiResponse;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;

/**
 * Global Exception Handler for SCM Enterprise Application.
 * Intercepts exceptions across all REST controllers and returns unified ApiResponse payload.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Handles authorization and access denied errors (403 Forbidden).
     *
     * @param ex AccessDeniedException instance
     * @return Unified ApiResponse with 403 Forbidden status
     */
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<Object>> handleAccessDeniedException(AccessDeniedException ex) {
        return buildErrorResponse(HttpStatus.FORBIDDEN, ex.getMessage());
    }

    /**
     * Handles database entity not found exceptions (404 Not Found).
     *
     * @param ex EntityNotFoundException instance
     * @return Unified ApiResponse with 404 Not Found status
     */
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ApiResponse<Object>> handleEntityNotFoundException(EntityNotFoundException ex) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, ex.getMessage());
    }

    /**
     * Handles general business logic and runtime exceptions (400 Bad Request).
     *
     * @param ex RuntimeException instance
     * @return Unified ApiResponse with 400 Bad Request status
     */
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiResponse<Object>> handleRuntimeException(RuntimeException ex) {
        return buildErrorResponse(HttpStatus.BAD_REQUEST, ex.getMessage());
    }

    /**
     * Fallback handler for all unexpected system exceptions (500 Internal Server Error).
     *
     * @param ex Exception instance
     * @return Unified ApiResponse with 500 Internal Server Error status
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Object>> handleGenericException(Exception ex) {
        return buildErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR, ex.getMessage() != null ? ex.getMessage() : "Internal server error occurred");
    }

    private ResponseEntity<ApiResponse<Object>> buildErrorResponse(HttpStatus status, String message) {
        ApiResponse<Object> response = ApiResponse.builder()
                .success(false)
                .status(status.value())
                .message(message != null ? message : status.getReasonPhrase())
                .timestamp(LocalDateTime.now())
                .build();
        return new ResponseEntity<>(response, status);
    }
}
