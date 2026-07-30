package com.m2i.logsapi.dtos;

import java.time.LocalDateTime;
import java.util.UUID;

public record LogResponsePayload(UUID id, Integer status, String message, String endpoint, String httpMethod, LocalDateTime timestamp, String service) {
}
