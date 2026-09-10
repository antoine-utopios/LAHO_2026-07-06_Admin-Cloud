package fr.gharrowbm.springapitestingnosecurity.controllers;

import fr.gharrowbm.springapitestingnosecurity.payloads.LoginRequest;
import fr.gharrowbm.springapitestingnosecurity.payloads.LoginResponse;
import fr.gharrowbm.springapitestingnosecurity.payloads.RegisterRequest;
import fr.gharrowbm.springapitestingnosecurity.services.AuthService;
import fr.gharrowbm.springapitestingnosecurity.services.BruteForceService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
    private final BruteForceService bruteForceService;
    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request, HttpServletRequest httpRequest) {
        String key = request.email() + "@" + httpRequest.getRemoteAddr();

        if (bruteForceService.isBlocked(key)) {
            return ResponseEntity.status(HttpStatus.LOCKED).body("Account locked, too many attempts.");
        }

        try {
            LoginResponse loginResponse = authService.login(request);
            bruteForceService.loginSuccess(key);
            return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
        } catch (Exception e) {
            bruteForceService.loginFailed(key);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid username or password.");
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) throws Exception {
        if (authService.register(request)) {
            return ResponseEntity.ok(Map.of("message", "User registered successfully"));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Something went wrong when registering a new user.");
        }
    }
}
