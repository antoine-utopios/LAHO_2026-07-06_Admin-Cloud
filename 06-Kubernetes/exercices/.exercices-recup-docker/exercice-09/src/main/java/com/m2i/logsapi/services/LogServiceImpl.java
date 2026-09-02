package com.m2i.logsapi.services;

import com.m2i.logsapi.dtos.LogRequestPayload;
import com.m2i.logsapi.dtos.LogResponsePayload;
import com.m2i.logsapi.entities.Log;
import com.m2i.logsapi.repositories.LogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LogServiceImpl implements LogService {
    private final LogRepository logRepository;

    @Override
    public Collection<LogResponsePayload> findAll() {
        return logRepository.findAll().stream().map(this::toDto).collect(Collectors.toSet());
    }

    @Override
    public LogResponsePayload create(LogRequestPayload payload) {
        return toDto(logRepository.save(toEntity(payload)));
    }

    private Log toEntity(LogRequestPayload payload) {
        return Log.builder()
                .status(payload.status())
                .message(payload.message())
                .timestamp(payload.timestamp())
                .httpMethod(payload.httpMethod())
                .endpoint(payload.endpoint())
                .service(payload.service())
                .build();
    }

    private LogResponsePayload toDto(Log entity) {
        return new LogResponsePayload(entity.getId(), entity.getStatus(), entity.getMessage(), entity.getEndpoint(), entity.getHttpMethod(), entity.getTimestamp(), entity.getService());
    }
}
