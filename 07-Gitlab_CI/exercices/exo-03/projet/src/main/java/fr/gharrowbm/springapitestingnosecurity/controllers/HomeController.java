package fr.gharrowbm.springapitestingnosecurity.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/v1/home")
public class HomeController {
    @GetMapping
    public ResponseEntity<Map<String, Object>> home() {
        return ResponseEntity.ok(Map.of("message", "Hello World"));
    }
}
