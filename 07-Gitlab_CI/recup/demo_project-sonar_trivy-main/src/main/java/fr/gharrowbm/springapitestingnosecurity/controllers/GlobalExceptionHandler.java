package fr.gharrowbm.springapitestingnosecurity.controllers;

import fr.gharrowbm.springapitestingnosecurity.exceptions.ElementNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.ServletWebRequest;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleMethodArgumentNotValidException(MethodArgumentNotValidException ex, ServletWebRequest request) {
        Map<String, Object> response = new HashMap<>();
        Map<String, String> errors = new HashMap<>();

        ex.getBindingResult().getFieldErrors().forEach((error) -> errors.put(error.getField(), error.getDefaultMessage()));

        response.put("message", "It appears that some fields were not valid");
        response.put("status", HttpStatus.BAD_REQUEST.value());
        response.put("timestamp", Instant.now());
        response.put("errors", errors);
        response.put("method", request.getRequest().getMethod());
        response.put("path", request.getRequest().getRequestURI());

        return ResponseEntity.badRequest().body(response);
    }


    @ExceptionHandler(ElementNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleElementNotFoundException(ElementNotFoundException ex, ServletWebRequest request) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", Instant.now());
        response.put("status", HttpStatus.NOT_FOUND.value());
        response.put("message", ex.getMessage());
        response.put("method", request.getRequest().getMethod());
        response.put("path", request.getRequest().getRequestURI());

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleException(Exception exception, ServletWebRequest request) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", exception.getMessage());
        response.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        response.put("timestamp", Instant.now());
        response.put("method", request.getRequest().getMethod());
        response.put("path", request.getRequest().getRequestURI());

        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(response);
    }


}
