package com.m2i.logsapi.dtos;

import java.time.LocalDateTime;

public record LogRequestPayload(Integer status, String message, String endpoint, String httpMethod, LocalDateTime timestamp, String service) {
}
