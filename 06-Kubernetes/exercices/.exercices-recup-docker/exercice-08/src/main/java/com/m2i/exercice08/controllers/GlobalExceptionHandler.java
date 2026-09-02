package com.m2i.exercice08.controllers;

import com.m2i.exercice08.dtos.LogRequestPayload;
import com.m2i.exercice08.exceptions.DogNotFoundException;
import com.m2i.exercice08.services.LogSenderService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {
    private final LogSenderService logSenderService;

    @ExceptionHandler(DogNotFoundException.class)
    public ResponseEntity<Object> handleDogNotFoundException(DogNotFoundException e, HttpServletRequest request) {
        String endpoint = request.getRequestURI();
        String httpMethod = request.getMethod();
        String errorMessage = e.getMessage();
        LocalDateTime now = LocalDateTime.now();
        int status = HttpStatus.NOT_FOUND.value();

        logSenderService.sendErrorLogToLogsApi(new LogRequestPayload(status, errorMessage, endpoint, httpMethod, now, "Dogs"));

        Map<String, Object> response = new HashMap<>();
        response.put("status", status);
        response.put("error", "Not Found");
        response.put("timestamp", now);
        response.put("path", endpoint);

        return ResponseEntity.status(status).body(response);
    }
}
