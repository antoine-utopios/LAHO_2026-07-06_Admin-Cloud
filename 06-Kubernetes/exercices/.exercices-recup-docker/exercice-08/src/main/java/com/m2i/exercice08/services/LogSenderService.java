package com.m2i.exercice08.services;

import com.m2i.exercice08.dtos.LogRequestPayload;

import java.util.Map;

public interface LogSenderService {
    public boolean sendErrorLogToLogsApi(LogRequestPayload log);
}
