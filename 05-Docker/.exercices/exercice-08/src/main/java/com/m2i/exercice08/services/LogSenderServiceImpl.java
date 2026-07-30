package com.m2i.exercice08.services;

import com.m2i.exercice08.dtos.LogRequestPayload;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
public class LogSenderServiceImpl implements LogSenderService {

    @Value("${logs.api.endpoint}")
    private String logsApiEndpoint;

    @Override
    public boolean sendErrorLogToLogsApi(LogRequestPayload log) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            restTemplate.postForEntity(logsApiEndpoint, log, Void.class);
            return true;
        } catch (Exception e) {
            System.out.println("Erreur lors de l'envoi des logs à LogsAPI: " + e.getMessage());
            return false;
        }
    }
}
