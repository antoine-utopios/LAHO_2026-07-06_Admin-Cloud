package com.m2i.logsapi.services;

import com.m2i.logsapi.dtos.LogRequestPayload;
import com.m2i.logsapi.dtos.LogResponsePayload;

import java.util.Collection;

public interface LogService {
    public Collection<LogResponsePayload> findAll();
    public LogResponsePayload create(LogRequestPayload payload);
}
