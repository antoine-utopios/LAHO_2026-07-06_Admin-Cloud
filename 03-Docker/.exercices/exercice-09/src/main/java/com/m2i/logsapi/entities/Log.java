package com.m2i.logsapi.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "logs")
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Log {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    @Column(name = "log_id")
    private UUID id;

    @Column(name = "log_status", nullable = false)
    private Integer status;

    @Column(name = "log_message", length = 200, nullable = false)
    private String message;

    @Column(name = "log_endpoint", length = 200, nullable = false)
    private String endpoint;

    @Column(name = "log_http_method", length = 10, nullable = false)
    private String httpMethod;

    @Column(name = "log_timestamp", nullable = false)
    private LocalDateTime timestamp;

    @Column(name = "log_service", length = 50, nullable = false)
    private String service;

}
