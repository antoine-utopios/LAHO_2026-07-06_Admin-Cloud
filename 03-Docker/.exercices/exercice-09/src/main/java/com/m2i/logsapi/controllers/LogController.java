package com.m2i.logsapi.controllers;

import com.m2i.logsapi.dtos.LogRequestPayload;
import com.m2i.logsapi.dtos.LogResponsePayload;
import com.m2i.logsapi.services.LogService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.Set;

@RestController
@RequestMapping("api/v1/logs")
@RequiredArgsConstructor
public class LogController {
    private final LogService logService;

    @Value("${server.port}")
    private String serverPort;

    @GetMapping
    public ResponseEntity<Set<LogResponsePayload>> getAllLogs() {
        return ResponseEntity.ok(new HashSet<LogResponsePayload>(logService.findAll()));
    }

    @PostMapping
    public ResponseEntity<LogResponsePayload> createLog(@RequestBody LogRequestPayload logRequestPayload) throws URISyntaxException {
        LogResponsePayload logResponsePayload = logService.create(logRequestPayload);

        URI createdLocation = new URI(String.format("http://localhost:%s/api/v1/dogs/%s", serverPort, logResponsePayload.id()));

        return ResponseEntity.created(createdLocation).build();
    }
}
